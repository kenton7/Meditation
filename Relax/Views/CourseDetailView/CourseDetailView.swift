//
//  CourseDetailView.swift
//  Relax
//
//  Created by Илья Кузнецов on 30.06.2024.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct CourseDetailView: View {
    
    var course: CourseAndPlaylistOfDayModel
    var size: CGSize
    var safeArea: EdgeInsets
    @State private var likesCount: Int?
    @State private var isLiked = false
    @StateObject private var headerViewModel = HeaderDetailCourse()
    @EnvironmentObject private var databaseViewModel: ChangeDataInDatabase
    @EnvironmentObject private var coursesViewModel: CoursesViewModel
    @EnvironmentObject private var playerViewModel: PlayerViewModel
    private let user = Auth.auth().currentUser
    @State private var isFemale = true
    @State private var isSelected = false
    @State private var lessons = [Lesson]()
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                if course.type == .story {
                    Color(uiColor: .init(red: 3/255, green: 23/255, blue: 76/255, alpha: 1)).ignoresSafeArea()
                }
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            headerViewModel.createHeaderView(course: course, size: size, safeArea: safeArea)
                                .zIndex(1)
                            createMainContent()
                        }
                        .id("mainScrollView")
                        .background {
                            ScrollDetector { offset in
                                headerViewModel.offsetY = -offset
                            } onDraggingEnd: { offset, velocity in
                                if headerViewModel.needToScroll(offset: offset,
                                                                velocity: velocity,
                                                                safeArea: safeArea,
                                                                size: size) {
                                    withAnimation {
                                        proxy.scrollTo("mainScrollView", anchor: .top)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            databaseViewModel.getLikesIn(course: course, courseType: course.type)
            databaseViewModel.checkIfUserLiked(user: user!, course: course)
            databaseViewModel.getListenersIn(course: course, courseType: course.type)
            databaseViewModel.storyInfo(course: course, isFemale: isFemale)
        }
        .task {
            lessons = await coursesViewModel.fetchCourseDetails(type: course.type, courseID: course.id)
        }
    }
    
    @ViewBuilder
    func createMainContent() -> some View {
        VStack {
            HStack {
                Text(course.name)
                    .foregroundStyle(course.type == .story ? .white : Color(uiColor: .init(red: 63/255,
                                                                                           green: 65/255,
                                                                                           blue: 78/255,
                                                                                           alpha: 1)))
                    .font(.system(.title2, design: .rounded)).bold()
                
                Spacer()
                
                VStack {
                    HStack(spacing: 30) {
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                isLiked.toggle()
                            }
                            if isLiked {
                                databaseViewModel.userLiked(course: course, 
                                                            type: .increment,
                                                            isLiked: isLiked,
                                                            user: user!,
                                                            courseType: course.type)
                            } else {
                                databaseViewModel.userLiked(course: course, 
                                                            type: .decrement,
                                                            isLiked: isLiked,
                                                            user: user!,
                                                            courseType: course.type)
                            }
                        }, label: {
                            Image(systemName: databaseViewModel.isLiked ? "heart.fill" : "heart")
                                .bold()
                                .foregroundColor(course.type == .story ? .white : Color(uiColor: .init(red: 63/255,
                                                                                                       green: 65/255,
                                                                                                       blue: 78/255,
                                                                                                       alpha: 1)))
                                .frame(width: 50, height: 50)
                                .background(.clear)
                                .overlay(
                                    Circle()
                                        .stroke(course.type == .story ? .white : Color(uiColor: .init(red: 63/255,
                                                                                                      green: 65/255,
                                                                                                      blue: 78/255,
                                                                                                      alpha: 1)),
                                                lineWidth: 2)
                                )
                                .clipShape(.circle)
                        })
                        
                        Button(action: {
                            //MARK: - TODO - Реализовать скачивание
                            //databaseViewModel.download(course: course, courseType: course.type, isFemale: isFemale)
                            Task.detached {
                                try await databaseViewModel.downloadAllCourse(course: course, courseType: course.type, isFemale: isFemale, lessons: lessons)
                            }
                        }, label: {
                            Image(systemName: "arrow.down")
                                .bold()
                                .foregroundStyle(course.type == .story ? .white : .black)
                                .frame(width: 50, height: 50)
                                .background(.clear)
                                .overlay {
                                    Circle()
                                        .stroke(course.type == .story ? .white : Color(uiColor: .init(red: 63/255,
                                                                                                      green: 65/255,
                                                                                                      blue: 78/255,
                                                                                                      alpha: 1)),
                                                lineWidth: 2)
                                }
                                .clipShape(.circle)
                        })
                        .padding(10)
                        .overlay {
                            ZStack {
                                Circle()
                                    .stroke(Color.gray, lineWidth: 4)
                                    .padding(10)
                                Circle()
                                    .trim(from: 0, to: databaseViewModel.downloadProgress)
                                    .stroke(Color.green, lineWidth: 4)
                                    .padding(10)
                                    .rotationEffect(.degrees(-90))
                            }
                        }
                    }
                    Spacer()
                }
            }
            //.padding(.horizontal)
            
            HStack {
                Text(course.description)
                    .padding()
                    .foregroundStyle(Color(uiColor: .init(red: 161/255,
                                                          green: 164/255,
                                                          blue: 178/255,
                                                          alpha: 1)))
                    .font(.system(.callout, design: .rounded, weight: .light))
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            
            HStack {
                HStack {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(uiColor: .init(red: 255/255,
                                                              green: 132/255,
                                                              blue: 162/255,
                                                              alpha: 1)))
                    
                    Text("\(databaseViewModel.likes) нравится")
                        .font(.system(size: 14, design: .rounded)).bold()
                        .foregroundStyle(Color(uiColor: .init(red: 161/255,
                                                              green: 164/255,
                                                              blue: 178/255,
                                                              alpha: 1)))
                }
                .padding(.horizontal)
                
                HStack {
                    Spacer()
                    Image(systemName: "headphones")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(uiColor: .init(red: 103/255,
                                                              green: 200/255,
                                                              blue: 193/255,
                                                              alpha: 1)))
                    Text("\(databaseViewModel.listeners) слушают")
                        .font(.system(size: 14, design: .rounded)).bold()
                        .foregroundStyle(Color(uiColor: .init(red: 161/255,
                                                              green: 164/255,
                                                              blue: 178/255,
                                                              alpha: 1)))
                }
            }
            .padding()
            
            if course.type != .playlist {
                VStack {
                    HStack {
                        Text("Выберите ведущего")
                            .foregroundStyle(course.type == .story ? .white : Color(uiColor: .init(red: 63/255,
                                                                                                   green: 65/255,
                                                                                                   blue: 78/255,
                                                                                                   alpha: 1)))
                            .font(.system(.title2, design: .rounded)).bold()
                        Spacer()
                    }
                    ChangeSpeakersButtons(course: course, isFemale: $isFemale)
                }
            }
            LessonsView(isFemale: $isFemale, course: course)
            Spacer()
        }
        .padding()
    }
}

//#Preview("ReadyCourseDetailView") {
//    ReadyCourseDetailView(course: .init(id: "basicCourse", name: "Основы", imageURL: "https://firebasestorage.googleapis.com/v0/b/relax-8e1d3.appspot.com/o/BasicCourse.png?alt=media&token=08260d35-2207-4bb9-8db8-82944106845f", color: .init(red: 142, green: 151, blue: 253), duration: "8", description: "Этот курс предназначен для тех, кто только начинает свой путь к спокойствию и внутренней гармонии.", listenedCount: 3, type: .meditation, isDaily: false, likes: 5))
//}
