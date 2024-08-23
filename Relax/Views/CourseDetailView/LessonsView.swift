//
//  LessonsView.swift
//  Relax
//
//  Created by Илья Кузнецов on 05.07.2024.
//

import SwiftUI

//MARK: - LessonsView
struct LessonsView: View {
    
    @Binding var isFemale: Bool
    @EnvironmentObject private var viewModel: CoursesViewModel
    @State private var isPlaying = false
    @State private var playingURL: String? = nil
    let course: CourseAndPlaylistOfDayModel
    @StateObject private var databaseViewModel = ChangeDataInDatabase.shared
    @State private var isTappedOnName = false
    @State private var lesson: Lesson?
    @State private var url: String = ""
    //@StateObject private var playerVM = PlayerViewModel.shared
    @EnvironmentObject private var playerVM: PlayerViewModel
    @State private var lessons = [Lesson]()
    
    var body: some View {
        NavigationStack {
            VStack {
                ForEach(lessons, id: \.name) { file in
                    HStack(spacing: 10) {
                        Button(action: {
                            url = isFemale ? file.audioFemaleURL : file.audioMaleURL
                            self.lesson = file
                            if viewModel.isPlaying(urlString: url) {
                                viewModel.pause()
                            } else {
                                databaseViewModel.updateListeners(course: course, type: course.type)
                                playerVM.playAudio(from: url,
                                                   playlist: lessons,
                                                   trackIndex: file.trackIndex,
                                                   type: course.type,
                                                   isFemale: isFemale,
                                                   course: course)
                            }
                        }, label: {
                            ZStack {
                                Circle()
                                    .frame(width: 50, height: 50)
                                    .foregroundStyle(Color(uiColor: .init(red: CGFloat(course.color.red) / 255,
                                                                          green: CGFloat(course.color.green) / 255,
                                                                          blue: CGFloat(course.color.blue) / 255,
                                                                          alpha: 1)))
                                Image(systemName: viewModel.isPlaying(urlString: isFemale ? file.audioFemaleURL : file.audioMaleURL) ? "pause.fill" : "play.fill")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 15, design: .rounded)).bold()
                            }
                        })
                        .padding(.vertical)
                        
                        VStack {
                            HStack {
                                Text(file.name)
                                    .bold()
                                    .foregroundStyle(course.type == .story ? .white : .black)
                                    .onTapGesture {
                                        isTappedOnName = true
                                        url = isFemale ? file.audioFemaleURL : file.audioMaleURL
                                        playerVM.playAudio(from: url,
                                                           playlist: lessons,
                                                           trackIndex: file.trackIndex,
                                                           type: course.type,
                                                           isFemale: isFemale,
                                                           course: course)
                                        databaseViewModel.updateListeners(course: course, type: course.type)
                                        self.lesson = file
                                    }
                                Spacer()
                            }
                            HStack {
                                Text("\(file.duration) мин.")
                                    .font(.system(.callout, design: .rounded, weight: .light))
                                    .foregroundStyle(Color(uiColor: .init(red: 161/255,
                                                                          green: 164/255,
                                                                          blue: 178/255,
                                                                          alpha: 1)))
                                Spacer()
                            }
                        }
                        .fullScreenCover(isPresented: $isTappedOnName, content: {
                            if let lesson = lesson {
                                PlayerScreen(lesson: lesson, isFemale: isFemale, course: course, url: isFemale ? lesson.audioFemaleURL : lesson.audioMaleURL)
                            }
                        })
                        Spacer()
                    }
                    Divider()
                }
            }
        }
        .padding()
        .task {
            lessons = await viewModel.fetchCourseDetails(type: course.type, courseID: course.id)
        }
    }
}

