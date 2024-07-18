//
//  PlayerScreen.swift
//  Relax
//
//  Created by Илья Кузнецов on 05.07.2024.
//

import SwiftUI
import FirebaseDatabase
import AVFoundation

struct PlayerScreen: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var isLiked = false
    @StateObject private var playerViewModel = PlayerViewModel.shared
    @State private var sliderValue: Double = 0.0
    @StateObject private var fetchDatabaseVM = CoursesViewModel()
    @StateObject private var databaseVM = ChangeDataInDatabase()
    
    let lesson: Lesson?
    let isFemale: Bool
    let course: CourseAndPlaylistOfDayModel
    let url: String
    
    var body: some View {
        ZStack {
            if course.type == .story {
                Color(uiColor: .init(red: 3/255, green: 23/255, blue: 76/255, alpha: 1)).ignoresSafeArea()
            } else {
                Color(uiColor: .init(red: 250/255,
                                     green: 247/255,
                                     blue: 242/255,
                                     alpha: 1))
                .ignoresSafeArea()
            }
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image("CloseButton")
                    })
                    .padding()
                    Spacer()
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            //MARK: - TODO: реализовать проверку лайкнуто или нет и куда-то перемещать лайкнутый урок
                            isLiked.toggle()
                        }, label: {
                            Image(isLiked ? "LikeButton_fill" : "LikeButton")
                        })
                        
                        Button(action: {
                            if let lesson {
                                databaseVM.download(course: course, 
                                                    courseType: course.type,
                                                    isFemale: isFemale,
                                                    lesson: lesson)
                            }
                        }, label: {
                            Image("DownloadButton")
                        })
                        .padding()
                        .overlay {
                            ZStack {
                                Circle()
                                    .stroke(Color.gray, lineWidth: 4)
                                    .padding()
                                Circle()
                                    .trim(from: 0, to: databaseVM.downloadProgress)
                                    .stroke(Color.green, lineWidth: 4)
                                    .padding()
                                    .rotationEffect(.degrees(-90))
                            }
                        }
                    }
                }
                
                Spacer()
                VStack {
                    Spacer()
                    Text(lesson?.name ?? course.name)
                        .foregroundStyle(course.type == .story ? .white : .black)
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .multilineTextAlignment(.center)
                    Text(course.name)
                        .font(.system(.title3, design: .rounded, weight: .light))
                        .foregroundStyle(Color(uiColor: .init(red: 160/255,
                                                              green: 163/255,
                                                              blue: 177/255,
                                                              alpha: 1)))
                        .multilineTextAlignment(.center)
                }
                    .padding()
                
                VStack {
                HStack(spacing: 60) {
                    
                    Button(action: {
                        playerViewModel.seek(by: -15)
                    }, label: {
                        Image(systemName: "gobackward.15")
                            .font(.system(size: 35))
                            .foregroundStyle(course.type == .story ? .white : .gray)
                    })
                    
                    Button(action: {
                        guard let lesson = lesson else { return }
                        if playerViewModel.isPlaying(urlString: isFemale ? lesson.audioFemaleURL : lesson.audioMaleURL) {
                            playerViewModel.pause()
                        } else {
                            playerViewModel.playAudio(from: isFemale ? lesson.audioFemaleURL : lesson.audioMaleURL, playlist: fetchDatabaseVM.lessons)
                        }
                    }, label: {
                            if let lesson {
                                Image(systemName: playerViewModel.isPlaying(urlString: isFemale ? lesson.audioFemaleURL : lesson.audioMaleURL) ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.system(size: 85))
                                    .foregroundStyle(Color(uiColor: .init(red: 63/255,
                                                                                                           green: 65/255,
                                                                                                           blue: 78/255,
                                                                                                           alpha: 1)))
                            }
                    })
                    .overlay {
                        Circle()
                            .stroke(Color(uiColor: .init(red: 160/255,
                                                         green: 163/255,
                                                         blue: 177/255,
                                                         alpha: 1)).opacity(0.7),
                                    lineWidth: 12)
                    }
                    
                    Button(action: {
                        playerViewModel.seek(by: 15)
                    }, label: {
                        Image(systemName: "goforward.15")
                            .foregroundStyle(course.type == .story ? .white : .gray)
                            .font(.system(size: 35))
                    })
                }
                .padding()
                
                    
                    Slider(value: Binding(get: {
                        self.sliderValue
                    }, set: { newValue in
                        sliderValue = newValue
                        let newTime = CMTime(seconds: newValue * self.playerViewModel.duration.seconds, preferredTimescale: 600)
                        playerViewModel.player?.seek(to: newTime)
                        playerViewModel.currentTime = newTime
                    }), in: 0...1)
                    .padding()
                    .tint(course.type == .story ? .white : .black)
                    .onChange(of: playerViewModel.currentTime) { newValue in
                        if playerViewModel.duration.seconds.isFinite && playerViewModel.duration.seconds > 0 {
                            self.sliderValue = newValue.seconds / playerViewModel.duration.seconds
                        }
                        
                        if playerViewModel.currentPlayingURL == nil {
                            dismiss()
                        }
                        
//                        if playerViewModel.currentTime >= playerViewModel.duration {
//                            dismiss()
//                        }
                    }
                    
                    HStack {
                        Text(playerViewModel.formatTime(time: playerViewModel.currentTime))
                            .foregroundStyle(course.type == .story ? .white : .black)
                        Spacer()
                        if playerViewModel.duration != .zero {
                           Text(playerViewModel.formatTime(time: playerViewModel.duration))
                                .foregroundStyle(course.type == .story ? .white : .black)
                        } else {
                            ProgressView()
                                .progressViewStyle(.circular)
                        }
                    }
                    .padding(.horizontal)
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

