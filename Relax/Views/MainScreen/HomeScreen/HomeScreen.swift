//
//  HomeScreen.swift
//  Relax
//
//  Created by Илья Кузнецов on 26.06.2024.
//

import SwiftUI
import FirebaseAuth
import FirebaseDatabase
import FirebaseCore
import CoreData
import AVKit
import Kingfisher

struct HomeScreen: View {
    
    @StateObject private var viewModel = CoursesViewModel()
    @StateObject private var nightStoriesViewModel = NightStoriesViewModel()
    @EnvironmentObject var yandexViewModel: YandexAuthorization
    @StateObject private var recommendationsViewModel = RecommendationsViewModel(yandexViewModel: YandexAuthorization.shared)
    @State private var isShowing = false
    @EnvironmentObject var navigationService: NavigationService
    @AppStorage("toogleDarkMode") private var toogleDarkMode = false
    @AppStorage("activeDarkModel") private var activeDarkModel = false
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack {
                    Text("Серотоника")
                        .padding(.vertical)
                        .foregroundStyle(activeDarkModel ? .white : Color(uiColor: .init(red: 63/255,
                                                                                         green: 65/255,
                                                                                         blue: 78/255,
                                                                                         alpha: 1)))
                        .font(.system(.title2, design: .rounded)).bold()
                        .offset(y: isShowing ? 0 : -1000)
                        .animation(.bouncy, value: isShowing)
                    
                    GreetingView(isShowing: $isShowing)
                    DailyRecommendations(isShowing: $isShowing)
                    DailyThoughts(isShowing: $isShowing)
                    RecommendationsScreen(isShowing: $isShowing)
                    NightStories(isShowing: $isShowing)
                }
            }
        }
        .tint(.white)
        .refreshable {
            Task {
                await viewModel.getCoursesNew(isDaily: true, path: .allCourses)
                await viewModel.getCoursesNew(isDaily: false, path: .allCourses)
                await MainActor.run {
                    recommendationsViewModel.fetchRecommendations()
                    nightStoriesViewModel.fetchNightStories()
                }
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

//MARK: - GreetingView
struct GreetingView: View {
    
    @StateObject private var homeScreenViewModel = HomeScreenViewModel()
    @EnvironmentObject var yandexViewModel: YandexAuthorization
    @Binding var isShowing: Bool
    @AppStorage("toogleDarkMode") private var toogleDarkMode = false
    @AppStorage("activeDarkModel") private var activeDarkModel = false
    
    var body: some View {
        VStack {
            HStack {
                Text(homeScreenViewModel.greeting)
                    .foregroundStyle(activeDarkModel ? .white : Color(uiColor: .init(red: 63/255,
                                                                                     green: 65/255,
                                                                                     blue: 78/255,
                                                                                     alpha: 1)))
                    .font(.system(.title, design: .rounded)).bold()
                Spacer()
            }
            
            HStack {
                Text(homeScreenViewModel.secondaryGreeting)
                    .font(.system(size: 13, weight: .light, design: .rounded))
                    .foregroundStyle(activeDarkModel ? .white : Color(uiColor: .init(red: 161/255,
                                                                                     green: 164/255,
                                                                                     blue: 178/255,
                                                                                     alpha: 1)))
                Spacer()
            }
        }
        .padding()
        .offset(y: isShowing ? 0 : -200)
        .animation(.bouncy, value: isShowing)
        .onAppear {
            homeScreenViewModel.updateGreeting()
        }
    }
}

//MARK: - DailyRecommendations
struct DailyRecommendations: View {
    
    @EnvironmentObject var viewModel: CoursesViewModel
    @State private var isCourseTapped: Bool = false
    @State private var selectedCourse: CourseAndPlaylistOfDayModel?
    @State private var navigationPath = NavigationPath()
    @Binding var isShowing: Bool
    @AppStorage("toogleDarkMode") private var toogleDarkMode = false
    @AppStorage("activeDarkModel") private var activeDarkModel = false
    
    var currentDate: String = {
        let date = Date()
        let df = DateFormatter()
        df.dateFormat = "dd.MM"
        return df.string(from: date)
    }()
    
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack {
                Group {
                    HStack {
                        Text("Практика дня")
                            .foregroundStyle(activeDarkModel ? .white : .black)
                            .font(.system(.title2, design: .rounded, weight: .bold))
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                    
                    HStack {
                        Text("Обновляется ежедневно")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(activeDarkModel ? .white : Color(uiColor: .init(red: 161/255,
                                                                                             green: 164/255,
                                                                                             blue: 178/255,
                                                                                             alpha: 1)))
                        Spacer()
                    }
                }
                .padding(.horizontal)
                .offset(y: isShowing ? 0 : -700)
                .animation(.bouncy, value: isShowing)
                
                HStack(spacing: 15) {
                    ForEach(viewModel.dailyCourses, id: \.id) { course in
                        Button(action: {
                            isCourseTapped = true
                            selectedCourse = course
                        }, label: {
                            ZStack {
                                Color(uiColor: .init(red: CGFloat(course.color.red) / 255,
                                                     green: CGFloat(course.color.green) / 255,
                                                     blue: CGFloat(course.color.blue) / 255,
                                                     alpha: 1))
                                .overlay {
                                    VStack {
                                        HStack {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 20)
                                                //Capsule()
                                                    .fill(Color.red)
                                                    .padding(.horizontal)
                                                    .frame(maxWidth: 100, maxHeight: 40)
                                                    .shadow(radius: 5)
                                                Text(currentDate).bold()
                                                    .padding()
                                            }
                                            Spacer()
                                        }
                                        Spacer()
                                    }
                                }
                                VStack {
                                    HStack {
                                        Spacer()
                                        KFImage(URL(string: course.imageURL))
                                            .resizable()
                                            .placeholder {
                                                LoadingAnimation()
                                            }
                                            .scaledToFit()
                                            .frame(width: 200, height: 150)
                                    }
                                    Spacer()
                                    HStack {
                                        Text(course.name)
                                            .padding(.horizontal)
                                            .foregroundStyle(.white)
                                            .font(.system(.title3, design: .rounded)).bold()
                                            .multilineTextAlignment(.leading)
                                        Spacer()
                                    }
                                    HStack {
                                        Spacer()
                                        Text(course.duration + " " + "мин.")
                                            .padding(.horizontal)
                                            .foregroundStyle(.white)
                                            .font(.system(size: 15, design: .rounded))
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.white)
                                            .frame(width: 80, height: 40)
                                            .padding(10)
                                            .overlay {
                                                Text("Начать")
                                                    .foregroundStyle(.black)
                                                    .font(.system(size: 18, design: .rounded))
                                            }
                                    }
                                }
                            }
                        })
                        .clipShape(.rect(cornerRadius: 20))
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, maxHeight: 230)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 230)
                .padding(.vertical)
                .offset(x: isShowing ? 0 : 700)
                .animation(.bouncy, value: isShowing)
            }
        }
        .navigationDestination(isPresented: $isCourseTapped) {
            if let selectedCourse = selectedCourse {
                ReadyCourseDetailView(course: selectedCourse)
            }
        }
        .task {
            //await viewModel.getCourses(isDaily: true)
            await viewModel.getCoursesNew(isDaily: true, path: .allCourses)
        }
    }
}

//MARK: - DailyThoughts
struct DailyThoughts: View {
    
    @State private var isDailyThoughtsTapped = false
    @State private var selectedCourse: CourseAndPlaylistOfDayModel?
    @StateObject private var viewModel = CoursesViewModel()
    @Binding var isShowing: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                Button(action: {
                    selectedCourse = viewModel.allCourses.filter { $0.name == "Ежедневные мысли" }.first
                    isDailyThoughtsTapped = true
                }, label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(uiColor: .init(red: 51/255,
                                                       green: 50/255,
                                                       blue: 66/255,
                                                       alpha: 1)))
                            .padding(.horizontal)
                        
                        Image("DailyThoughtsBackground")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding(.horizontal)
                        
                        VStack {
                            HStack {
                                Text("Ежедневные мысли")
                                    .padding(.horizontal)
                                    .foregroundStyle(.white)
                                    .font(.system(size: 20, design: .rounded)).bold()
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            HStack {
                                Text("МЕДИТАЦИЯ • 10-30 мин")
                                    .padding(.horizontal)
                                    .lineLimit(1)
                                    .foregroundStyle(.white).bold()
                                    .font(.system(.caption, design: .rounded))
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                        
                        HStack {
                            Spacer()
                            Image(systemName: "play.circle.fill")
                                            .foregroundStyle(.white)
                                            .font(.system(size: 35))
                                            .padding()
                        }
                        .padding(.trailing)
                    }
                })
                .clipShape(.rect(cornerRadius: 20))
                .frame(maxWidth: .infinity)
                .offset(x: isShowing ? 0 : -700)
                .animation(.bouncy, value: isShowing)
            }
        }
        .navigationDestination(isPresented: $isDailyThoughtsTapped) {
            if let selectedCourse = selectedCourse {
                ReadyCourseDetailView(course: selectedCourse)
            }
        }
        .task {
            //await viewModel.getCourses(isDaily: false)
            await viewModel.getCoursesNew(isDaily: false, path: .allCourses)
        }
    }
}

//MARK: - RecommendationsScreen
struct RecommendationsScreen: View {
    
    @EnvironmentObject var yandexViewModel: YandexAuthorization
    @StateObject private var recommendationsViewModel = RecommendationsViewModel(yandexViewModel: YandexAuthorization.shared)
    @AppStorage("toogleDarkMode") private var toogleDarkMode = false
    @AppStorage("activeDarkModel") private var activeDarkModel = false
    
    @State private var isSelected = false
    @State private var selectedCourse: CourseAndPlaylistOfDayModel?
    @Binding var isShowing: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Рекомендовано для Вас")
                        .padding(.top)
                        .padding(.horizontal)
                        .foregroundStyle(activeDarkModel ? .white : Color(uiColor: .init(red: 63/255,
                                                                                         green: 65/255,
                                                                                         blue: 78/255,
                                                                                         alpha: 1)))
                        .font(.system(.title2, design: .rounded)).bold()
                    Spacer()
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: [GridItem(.fixed(200))], spacing: 0, content: {
                            ForEach(recommendationsViewModel.recommendations, id: \.name) { course in
                                Button(action: {
                                    selectedCourse = course
                                    isSelected = true
                                }, label: {
                                    VStack(alignment: .leading) {
                                        ZStack {
                                            Color(uiColor: .init(red: CGFloat(course.color.red) / 255,
                                                                 green: CGFloat(course.color.green) / 255,
                                                                 blue: CGFloat(course.color.blue) / 255,
                                                                 alpha: 1))
                                            
                                            KFImage(URL(string: course.imageURL))
                                                .resizable()
                                                .placeholder {
                                                    LoadingAnimationButton()
                                                }
                                                .scaledToFit()
                                                .frame(width: 200, height: 150)
                                        }
                                        .clipShape(.rect(cornerRadius: 10))
                                        Spacer()
                                        
                                        Text(course.name)
                                            .foregroundStyle(activeDarkModel ? .white : Color(uiColor: .init(red: 63/255,
                                                                                                             green: 65/255,
                                                                                                             blue: 78/255,
                                                                                                             alpha: 1)))
                                            .font(.system(.callout, design: .rounded)).bold()
                                        
                                        Text(course.type.rawValue)
                                            .foregroundStyle(activeDarkModel ? .white : Color(uiColor: .init(red: 161/255,
                                                                                                             green: 164/255,
                                                                                                             blue: 178/255,
                                                                                                             alpha: 1)))
                                            .font(.system(.caption, design: .rounded))
                                    }
                                })
                               .padding(.horizontal)
                            }
                    })
                }
            }
            .offset(x: isShowing ? 0 : 700)
            .animation(.bouncy, value: isShowing)
        }
        .navigationDestination(isPresented: $isSelected, destination: {
            if let selectedCourse = selectedCourse {
                ReadyCourseDetailView(course: selectedCourse)
            }
        })
    }
}

//MARK: - NightStories
struct NightStories: View {
    
    @StateObject private var nightStoriesViewModel = NightStoriesViewModel()
    @State private var isSelected = false
    @State private var selectedStory: CourseAndPlaylistOfDayModel?
    @Binding var isShowing: Bool
    @Environment(\.currentTab) private var selectedTab
    @AppStorage("toogleDarkMode") private var toogleDarkMode = false
    @AppStorage("activeDarkModel") private var activeDarkModel = false
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Истории на ночь")
                        .padding(.top)
                        .padding(.horizontal)
                        .foregroundStyle(activeDarkModel ? .white : Color(uiColor: .init(red: 63/255,
                                                                                         green: 65/255,
                                                                                         blue: 78/255,
                                                                                         alpha: 1)))
                        .font(.system(.title2, design: .rounded)).bold()
                    Spacer()
                }
                
                HStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: [GridItem(.fixed(150))], spacing: 0, content: {
                            ForEach(nightStoriesViewModel.nightStories, id: \.name) { nightStory in
                                Button(action: {
                                    isSelected = true
                                    selectedStory = nightStory
                                }, label: {
                                    VStack(alignment: .leading) {
                                        ZStack {
                                            Color(uiColor: .init(red: CGFloat(nightStory.color.red) / 255,
                                                                 green: CGFloat(nightStory.color.green) / 255,
                                                                 blue: CGFloat(nightStory.color.blue) / 255,
                                                                 alpha: 1))
                                            KFImage(URL(string: nightStory.imageURL)!)
                                                .resizable()
                                                .placeholder {
                                                    LoadingAnimationButton()
                                                }
                                                .scaledToFill()
                                                .padding()
                                                .frame(width: 200, height: 150)
                                                .scaleEffect(CGSize(width: 1.5, height: 1.1))
                                        }
                                        .clipShape(.rect(cornerRadius: 10))
                                        Spacer()
                                        Text(nightStory.name)
                                            .foregroundStyle(activeDarkModel ? .white : Color(uiColor: .init(red: 63/255,
                                                                                                             green: 65/255,
                                                                                                             blue: 78/255,
                                                                                                             alpha: 1)))
                                            .font(.system(.callout, design: .rounded)).bold()
                                    }
                                })
                               .padding(.horizontal)
                            }
                            Button {
                                selectedTab.wrappedValue = .sleep
                            } label: {
                                ZStack {
                                    Circle()
                                        .frame(width: 70, height: 70)
                                        .foregroundStyle(Color.indigo)
                                    Text("См. \nвсё")
                                        .foregroundStyle(.white)
                                        .font(.system(size: 15, design: .rounded)).bold()
                                }
                            }
                            .padding(.horizontal)
                        })
                    }
                }
                Spacer()
            }
            .offset(x: isShowing ? 0 : -300)
            .animation(.bouncy, value: isShowing)
        }
        .padding(.bottom)
        .navigationDestination(isPresented: $isSelected) {
            if let selectedStory = selectedStory {
                ReadyCourseDetailView(course: selectedStory)
            }
        }
    }
}

