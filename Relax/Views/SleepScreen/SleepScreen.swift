//
//  SleepScreen.swift
//  Relax
//
//  Created by Илья Кузнецов on 09.07.2024.
//

import SwiftUI

struct SleepScreen: View {
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                ZStack {
                    Color(uiColor: .init(red: 3/255,
                                         green: 23/255,
                                         blue: 76/255,
                                         alpha: 1))
                    .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        HeaderView()
                        StoryGenresView()
                        AllStoriesView()
                    }
                }
            }
            .ignoresSafeArea()
        }
    }
}


//MARK: - HeaderView
struct HeaderView: View {
    var body: some View {
            VStack {
                ZStack {
                    Image("SleepScreenHeaderBackground")
                    Image("OnSleepScreenHeaderLayer")
                    VStack {
                        Text("Истории на ночь")
                            .padding()
                            .foregroundStyle(.white)
                            .font(.system(.title, design: .rounded, weight: .bold))
                        Text("Успокаивающие сказки на ночь помогут вам погрузиться в глубокий и естественный сон")
                            .foregroundStyle(.white)
                            .font(.system(.headline, design: .rounded, weight: .light))
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .ignoresSafeArea()
    }
}

//MARK: - StoryGenresView
struct StoryGenresView: View {
    
    @State private var isSelected = false
    @StateObject private var selectGenreVM = SelectGenreViewModel()
    @EnvironmentObject var nightStoriesVM: NightStoriesViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: [GridItem(.flexible())], content: {
            HStack {
                ForEach(selectGenreVM.genres.indices, id: \.self) { index in
                        Button(action: {
                            withAnimation(.easeInOut) {
                                selectGenreVM.selectGenre(at: index)
                                nightStoriesVM.filterResults(by: selectGenreVM.selectedGenre)
                            }
                        }, label: {
                            VStack {
                                ZStack {
                                    Circle()
                                        .frame(width: 70, height: 70)
                                        .foregroundStyle(selectGenreVM.genres[index].isSelected ? Color(uiColor: .init(red: 142/255,
                                                                                                                       green: 151/255,
                                                                                                                       blue: 253/255
                                                                                                                       , alpha: 1)) : Color(uiColor: .init(red: 88/255, green: 104/255,
                                                                                                                                                           blue: 148/255,
                                                                                                                                                           alpha: 1)))
                                    Image(systemName: selectGenreVM.genres[index].image)
                                        .foregroundStyle(.white)
                                        .font(.system(size: 25))
                                }
                                Text(selectGenreVM.genres[index].genre)
                                    .foregroundStyle(selectGenreVM.genres[index].isSelected ? .white : .gray)
                                    .bold()
                            }
                        })
                        .padding(.horizontal)
                }
            }
            .padding()
            })
            .padding(.horizontal)
            .frame(height: 100)
        }
        .padding(.top, -30)
        .padding(.bottom)
        .onAppear {
            selectGenreVM.selectGenre(at: 0)
        }
    }
}


//MARK: - AllStoriesView
struct AllStoriesView: View {
    
    @EnvironmentObject var nightStoriesVM: NightStoriesViewModel
    @State private var isSelected = false
    @State var selectedStory: CourseAndPlaylistOfDayModel?
    
    var body: some View {
        NavigationStack {
            LazyVGrid(columns: [GridItem(.flexible()),
                                GridItem(.flexible())
                               ], spacing: 20) {
                ForEach(nightStoriesVM.filteredStories) { story in
                    Button(action: {
                        isSelected = true
                        selectedStory = story
                    }, label: {
                        VStack {
                            AsyncImage(url: URL(string: story.imageURL)) { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .clipShape(.rect(cornerRadius: 16))
                            } placeholder: {
                                ProgressView()
                            }
                            
                            VStack {
                                HStack {
                                    Text(story.name)
                                        .padding(10)
                                        .foregroundStyle(.white)
                                        .bold()
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                                
                                HStack {
                                    Text("\(story.duration) мин • \(story.type.rawValue)")
                                        .padding(.horizontal, 10)
                                        .foregroundStyle(Color(uiColor: .init(red: 152/255,
                                                                              green: 161/255,
                                                                              blue: 189/255,
                                                                              alpha: 1)))
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                            }
                        }
                    })
                }
            }
                               .padding(.horizontal, 20)
                               .padding(.bottom, 110)
                               .onAppear {
                                   nightStoriesVM.filterResults(by: "Всё")
                               }
        }
        .navigationDestination(isPresented: $isSelected) {
            if let selectedStory {
                ReadyCourseDetailView(course: selectedStory)
            }
        }
    }
}

#Preview {
    SleepScreen()
}
