//
//  MeditationScreen.swift
//  Relax
//
//  Created by Илья Кузнецов on 11.07.2024.
//

import SwiftUI
import Kingfisher

struct MeditationScreen: View {
    @StateObject private var emergencyVM = EmergencyMeditationsViewModel()
    @EnvironmentObject private var meditationsVM: CoursesViewModel
    @State private var isShowing = false
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    MeditationHeaderView(isShowing: $isShowing)
                    //StoryGenresView(type: .meditation)
                    EmergencyHelp(isShowing: $isShowing)
                        .environmentObject(emergencyVM)
                    AllMeditationsView(isShowing: $isShowing)
                }
            }
        }
        .padding(.bottom)
        .refreshable {
            Task {
                await meditationsVM.getCoursesNew(isDaily: false, path: .allCourses)
                await meditationsVM.getCoursesNew(isDaily: false, path: .emergencyMeditations)
            }
        }
        .onAppear {
            isShowing = true
        }
        .onDisappear {
            isShowing = false
        }
    }
}

//MARK: - MeditationHeaderView
struct MeditationHeaderView: View {
    
    @Binding var isShowing: Bool
    @AppStorage("toogleDarkMode") private var toogleDarkMode = false
    @AppStorage("activeDarkModel") private var activeDarkModel = false
    
    var body: some View {
        VStack {
            Text("Медитации")
                .padding()
                .foregroundStyle(activeDarkModel ? .white : .black)
                .font(.system(.title, design: .rounded, weight: .bold))
                .offset(y: isShowing ? 0 : -1000)
                .animation(.bouncy, value: isShowing)
            Text("Погрузитесь в мир осознанности и внутреннего спокойствия с нашими подробными уроками медитации, созданными для всех уровней подготовки.")
                .padding()
                .foregroundStyle(activeDarkModel ? .white : Color(uiColor: .init(red: 160/255,
                                                                                 green: 163/255,
                                                                                 blue: 177/255,
                                                                                 alpha: 1)))
                .font(.system(.headline, design: .rounded, weight: .light))
                .multilineTextAlignment(.center)
                .offset(x: isShowing ? 0 : -1000)
                .animation(.bouncy, value: isShowing)
        }
        .padding(.vertical)
    }
}

//MARK: - EmergencyHelp
struct EmergencyHelp: View {
    
    @EnvironmentObject private var emergencyViewModel: EmergencyMeditationsViewModel
    @EnvironmentObject private var coursesViewModel: CoursesViewModel
    @State private var isSelected = false
    @State var selectedCourse: CourseAndPlaylistOfDayModel?
    @AppStorage("toogleDarkMode") private var toogleDarkMode = false
    @AppStorage("activeDarkModel") private var activeDarkModel = false
    @Binding var isShowing: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Если помощь нужна здесь и сейчас")
                    .padding()
                    .foregroundStyle(activeDarkModel ? .white : Color(uiColor: .init(red: 160/255,
                                                                                     green: 163/255,
                                                                                     blue: 177/255,
                                                                                     alpha: 1)))
                    .font(.system(.headline, design: .rounded, weight: .light))
                    .multilineTextAlignment(.center)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20, content: {
                    ForEach(coursesViewModel.emergencyMeditations) { emergencyLesson in
                        Button(action: {
                            isSelected = true
                            selectedCourse = emergencyLesson
                        }, label: {
                            VStack {
                                KFImage(URL(string: emergencyLesson.imageURL))
                                    .resizable()
                                    .placeholder {
                                        LoadingAnimationButton()
                                    }
                                    .scaledToFit()
                                    .clipShape(.rect(cornerRadius: 16))
                                    .padding(.horizontal)
                                Text(emergencyLesson.name)
                                    .foregroundStyle(activeDarkModel ? .white : .black)
                                    .font(.system(size: 15, design: .rounded)).bold()
                            }
                        })
                    }
                })
            }
            .offset(x: isShowing ? 0 : -1000)
            .animation(.bouncy, value: isShowing)
        }
        .navigationDestination(isPresented: $isSelected) {
            if let course = selectedCourse {
                ReadyCourseDetailView(course: course)
            }
        }
        .task {
            await coursesViewModel.getCoursesNew(isDaily: false, path: .emergencyMeditations)
        }
    }
}

//MARK: -  AllMeditationsView
struct AllMeditationsView: View {
    
    @EnvironmentObject var meditationsViewModel: CoursesViewModel
    @State private var isSelected = false
    @State var selectedCourse: CourseAndPlaylistOfDayModel?
    @AppStorage("toogleDarkMode") private var toogleDarkMode = false
    @AppStorage("activeDarkModel") private var activeDarkModel = false
    @Binding var isShowing: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Все медитации")
                    .padding()
                    .foregroundStyle(activeDarkModel ? .white : Color(uiColor: .init(red: 160/255,
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
                        ForEach(meditationsViewModel.allCourses) { course in
                            Button(action: {
                                isSelected = true
                                selectedCourse = course
                            }, label: {
                                VStack {
                                    KFImage(URL(string: course.imageURL))
                                        .resizable()
                                        .placeholder {
                                            LoadingAnimationButton()
                                        }
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
                                                                .foregroundStyle(activeDarkModel ? .white : .black)
                                                                .font(.system(size: 14,
                                                                              weight: .bold,
                                                                              design: .rounded))
                                                                .shadow(color: .gray, radius: 5)
                                                        }
                                                }
                                            }
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
        .offset(x: isShowing ? 0 : -1000)
        .animation(.bouncy, value: isShowing)
        .task {
            //await meditationsViewModel.getCourses(isDaily: false)
            await meditationsViewModel.getCoursesNew(isDaily: false, path: .allCourses)
        }
    }
}

