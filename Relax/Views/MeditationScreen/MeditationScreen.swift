//
//  MeditationScreen.swift
//  Relax
//
//  Created by Илья Кузнецов on 11.07.2024.
//

import SwiftUI

struct MeditationScreen: View {
    @StateObject private var emergencyVM = EmergencyMeditationsViewModel()
    @State private var meditationsVM = CoursesViewModel()
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    MeditationHeaderView()
                    //StoryGenresView(type: .meditation)
                    EmergencyHelp()
                    AllMeditationsView()
                }
            }
        }
        .padding(.bottom)
        .refreshable {
            meditationsVM.filteredStories.removeAll()
            emergencyVM.emergencyMeditations.removeAll()
            emergencyVM.fetchEmergencyMeditations()
            Task.detached {
                await meditationsVM.getCourses(isDaily: false)
                //await meditationsVM.filterResults(by: "Всё")
            }
        }
    }
}

//MARK: - MeditationHeaderView
struct MeditationHeaderView: View {
    var body: some View {
        VStack {
            Text("Медитации")
                .padding()
                .foregroundStyle(.black)
                .font(.system(.title, design: .rounded, weight: .bold))
            Text("Погрузитесь в мир осознанности и внутреннего спокойствия с нашими подробными уроками медитации, созданными для всех уровней подготовки.")
                .padding()
                .foregroundStyle(Color(uiColor: .init(red: 160/255,
                                                      green: 163/255,
                                                      blue: 177/255,
                                                      alpha: 1)))
                .font(.system(.headline, design: .rounded, weight: .light))
                .multilineTextAlignment(.center)
        }
        .padding(.vertical)
    }
}

//MARK: - EmergencyHelp
struct EmergencyHelp: View {
    
    @StateObject private var emergencyVM = EmergencyMeditationsViewModel()
    @State private var isSelected = false
    @State var selectedCourse: CourseAndPlaylistOfDayModel?
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Если помощь нужна здесь и сейчас")
                    .padding()
                    .foregroundStyle(Color(uiColor: .init(red: 160/255,
                                                          green: 163/255,
                                                          blue: 177/255,
                                                          alpha: 1)))
                    .font(.system(.headline, design: .rounded, weight: .light))
                    .multilineTextAlignment(.center)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20, content: {
                    ForEach(emergencyVM.emergencyMeditations) { emergencyLesson in
                        Button(action: {
                            isSelected = true
                            selectedCourse = emergencyLesson
                        }, label: {
                            VStack {
                                AsyncImage(url: URL(string: emergencyLesson.imageURL)) { image in
                                    image.resizable()
                                        .scaledToFit()
                                        .clipShape(.rect(cornerRadius: 16))
                                        .padding(.horizontal)
                                } placeholder: {
                                    ProgressView()
                                }
                                Text(emergencyLesson.name)
                                    .foregroundStyle(.black)
                                    .font(.system(size: 15, design: .rounded)).bold()
                            }
                        })
                    }
                })
            }
        }
        .navigationDestination(isPresented: $isSelected) {
            if let course = selectedCourse {
                ReadyCourseDetailView(course: course)
            }
        }
    }
}

//MARK: -  AllMeditationsView
struct AllMeditationsView: View {
    
    @EnvironmentObject var meditationsViewModel: CoursesViewModel
    @State private var isSelected = false
    @State var selectedCourse: CourseAndPlaylistOfDayModel?
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Все медитации")
                    .padding()
                    .foregroundStyle(Color(uiColor: .init(red: 160/255,
                                                          green: 163/255,
                                                          blue: 177/255,
                                                          alpha: 1)))
                    .font(.system(.headline, design: .rounded, weight: .light))
                    .multilineTextAlignment(.center)
                
                
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()),
                                        GridItem(.flexible())
                                       ], spacing: 20,
                              content: {
                        ForEach(meditationsViewModel.filteredStories) { course in
                            Button(action: {
                                isSelected = true
                                selectedCourse = course
                            }, label: {
                                VStack {
                                    AsyncImage(url: URL(string: course.imageURL)) { image in
                                        image.resizable()
                                            .scaledToFit()
                                            .clipShape(.rect(cornerRadius: 16))
                                            .overlay {
                                                ZStack {
                                                    VStack {
                                                        Spacer()
                                                        Rectangle()
                                                            .fill(Color(uiColor: .init(red: CGFloat(course.color.red) / 255,
                                                                                       green: CGFloat(course.color.green) / 255,
                                                                                       blue: CGFloat(course.color.blue) / 255,
                                                                                       alpha: 1)))
                                                            .frame(maxWidth: .infinity, maxHeight: 40)
                                                            .clipShape(.rect(bottomLeadingRadius: 16, 
                                                                             bottomTrailingRadius: 16,
                                                                             style: .continuous))
                                                            .overlay {
                                                                Text(course.name)
                                                                    .foregroundStyle(.white)
                                                                    .font(.system(size: 14, 
                                                                                  weight: .bold,
                                                                                  design: .rounded))
                                                            }
                                                    }
                                                }
                                            }
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .padding()
                                }
                            })
                        }
                    })
                }
            }
        }
        .navigationDestination(isPresented: $isSelected) {
            if let course = selectedCourse {
                ReadyCourseDetailView(course: course)
            }
        }
        .task {
            //await meditationsViewModel.filterResults(by: "Всё")
            await meditationsViewModel.getCourses(isDaily: false)
        }
    }
}

#Preview {
    let vm = CoursesViewModel()
    return MeditationScreen()
        .environmentObject(vm)
}
