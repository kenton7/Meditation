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
    @EnvironmentObject private var premiumViewModel: PremiumViewModel
    @State private var isTappedOnName = false
    @State private var lesson: Lesson?
    @State private var url: String = ""
    //@StateObject private var playerVM = PlayerViewModel.shared
    @EnvironmentObject private var playerVM: PlayerViewModel
    @State private var lessons = [Lesson]()
    @State private var isPressedWithoutPremium = false
    @State private var isErrorWhenPlaying = false
    
    var body: some View {
        NavigationStack {
            VStack {
                ForEach(lessons, id: \.name) { file in
                    HStack(spacing: 20) {
                        Button(action: {
                            if premiumViewModel.hasUnlockedPremuim || file.trackIndex! == 0 {
                                isPressedWithoutPremium = false
                                url = isFemale ? file.audioFemaleURL : file.audioMaleURL
                                self.lesson = file
                                if viewModel.isPlaying(urlString: url) {
                                    viewModel.pause()
                                } else {
                                    //databaseViewModel.updateListeners(course: course, type: course.type)
                                    playerVM.playAudio(from: url,
                                                       playlist: lessons,
                                                       trackIndex: file.trackIndex,
                                                       type: course.type,
                                                       isFemale: isFemale,
                                                       course: course)
                                }
                            } else {
                                guard let trackIndex = file.trackIndex else {
                                    isPressedWithoutPremium = true
                                    return
                                }
                                if trackIndex > 0 {
                                    isPressedWithoutPremium = true
                                }
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
                        
                        Button(action: {
                            if premiumViewModel.hasUnlockedPremuim || file.trackIndex! == 0 {
                                isTappedOnName = true
                                isPressedWithoutPremium = false
                                url = isFemale ? file.audioFemaleURL : file.audioMaleURL
                                if !url.isEmpty {
                                    playerVM.playAudio(from: url,
                                                       playlist: lessons,
                                                       trackIndex: file.trackIndex,
                                                       type: course.type,
                                                       isFemale: isFemale,
                                                       course: course)
                                    //databaseViewModel.updateListeners(course: course, type: course.type)
                                    self.lesson = file
                                } else {
                                    isErrorWhenPlaying = true
                                }
                            } else {
                                guard let trackIndex = file.trackIndex else {
                                    isPressedWithoutPremium = true
                                    return
                                }
                                if trackIndex > 0 {
                                    isPressedWithoutPremium = true
                                }
                            }
                        }, label: {
                            HStack {
                                VStack {
                                    HStack {
                                        Text(file.name).bold()
                                            .padding(.vertical, 2)
                                            .foregroundStyle(course.type == .story ? .white : .black)
                                            .multilineTextAlignment(.leading)
                                        Spacer()
                                    }
                                    HStack {
                                        Text("\(file.duration) мин.")
                                            .foregroundStyle(Color(uiColor: .secondaryTextColor))
                                            .multilineTextAlignment(.leading)
                                        Spacer()
                                    }
                                }
                                Spacer()
                            }
                            .contentShape(.rect)
                            .frame(maxWidth: .infinity)
                        })
                        .fullScreenCover(isPresented: $isTappedOnName, content: {
                            if let lesson = lesson {
                                PlayerScreen(lesson: lesson, isFemale: isFemale, course: course, url: isFemale ? lesson.audioFemaleURL : lesson.audioMaleURL)
                            }
                        })
                        .alert("Ошибка при воспроизведении. Голос для данного материала пока недоступен.",
                               isPresented: $isErrorWhenPlaying) {
                            Button("OK", role: .cancel) {}
                        }
                        Spacer()
                    }
                    Divider()
                }
            }
        }
        .sheet(isPresented: $isPressedWithoutPremium, content: {
            PremiumScreen()
        })
        .padding()
        .task {
            lessons = await viewModel.fetchCourseDetails(type: course.type, courseID: course.id)
        }
    }
}

