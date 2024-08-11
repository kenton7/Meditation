//
//  UserInterestsTopicScreen.swift
//  Relax
//
//  Created by Илья Кузнецов on 25.06.2024.
//

import SwiftUI
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

struct UserInterestsTopicScreen: View {
    
    @State private var selectedTopics: [CourseAndPlaylistOfDayModel] = []
    @State private var isContinueTapped = false
    private let topicDataService = CoreDataService.shared
    @StateObject private var coursesVM = CoursesViewModel()
    
    private let firebaseUser = Auth.auth().currentUser
    
    var body: some View {
        
        let columns = [GridItem(.flexible(maximum: 250)),
                       GridItem(.flexible(maximum: 250))]
        
        NavigationStack {
            ZStack {
                VStack {
                    Image("TopicsBackground").ignoresSafeArea()
                }
                ScrollView {
                    VStack {
                        HStack {
                            Text("Что вам по душе?")
                                .padding()
                                .foregroundStyle(Color(uiColor: .init(red: 63/255, green: 65/255, blue: 78/255, alpha: 1)))
                                .font(.system(.title2, design: .rounded, weight: .bold))
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            Text("Выберите темы, \nна которых вы хотели бы сфокусироваться:")
                                .padding(.horizontal)
                                .foregroundStyle(Color(uiColor: .init(red: 161/255, green: 164/255, blue: 178/255, alpha: 1)))
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                        ScrollView {
                            LazyVGrid(columns: columns, alignment: .center, spacing: 20, content: {
                                ForEach($coursesVM.allCourses, id: \.id) { $topic in
                                    TopicButton(topic: $topic, selectedTopics: $selectedTopics)
                                }
                            })
                            .padding()
                        }
                        
                        Button(action: {
                            isContinueTapped = true
                        }, label: {
                            Text("Продолжить")
                                .foregroundStyle(.white)
                        })
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(uiColor: .defaultButtonColor))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding()
                        .disabled(selectedTopics.isEmpty)
                    }
                }
            }
        }
        .navigationDestination(isPresented: $isContinueTapped, destination: {
            RemindersScreen(isFromSettings: false)
        })
        .task {
            await coursesVM.getCourses(isDaily: false)
        }
        .navigationBarBackButtonHidden()
    }
}

struct TopicButton: View {
    @Binding var topic: CourseAndPlaylistOfDayModel
    @Binding var selectedTopics: [CourseAndPlaylistOfDayModel]
    private let topicDataService = CoreDataService.shared
    
    var body: some View {
        Button(action: {
            withAnimation {
                if !selectedTopics.contains(where: { $0.name == topic.name }) {
                    selectedTopics.append(topic)
                    topic.isSelected = true
                    let topicDict = ["name": topic.name]
                    Database.database(url: .databaseURL).reference().child("users").child(Auth.auth().currentUser?.uid ?? "").child("selectedTopics").child(topic.name).setValue(topicDict)
                } else {
                    selectedTopics.removeAll(where: { $0.name == topic.name })
                    topic.isSelected = false
                    Database.database(url: .databaseURL).reference().child("users").child(Auth.auth().currentUser?.uid ?? "").child("selectedTopics").child(topic.name).removeValue()
                }
            }
        }, label: {
            ZStack {
                Color(uiColor: .init(red: CGFloat(topic.color.red) / 255,
                                     green: CGFloat(topic.color.green) / 255,
                                     blue: CGFloat(topic.color.blue) / 255,
                                     alpha: 1))
                VStack {
                    AsyncImage(url: URL(string: topic.imageURL)) { image in
                        image.resizable()
                            .scaledToFit()
                            .clipShape(.rect(cornerRadius: 16))
                            .overlay {
                                ZStack {
                                    VStack {
                                        Spacer()
                                        Rectangle()
                                            .fill(Color(uiColor: .init(red: CGFloat(topic.color.red) / 255,
                                                                       green: CGFloat(topic.color.green) / 255,
                                                                       blue: CGFloat(topic.color.blue) / 255,
                                                                       alpha: 1)))
                                            .frame(maxWidth: .infinity, maxHeight: 40)
                                            .clipShape(.rect(bottomLeadingRadius: 16,
                                                             bottomTrailingRadius: 16,
                                                             style: .continuous))
                                    }
                                }
                            }
                    } placeholder: {
                        ProgressView()
                    }
                    .padding()
                }
                VStack {
                    Spacer()
                    HStack {
                        Text(topic.name)
                            .padding()
                            .font(.system(size: 15, design: .rounded))
                            .foregroundStyle(.white).bold()
                            .minimumScaleFactor(2)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(topic.isSelected == true ? Color.green : Color.clear, lineWidth: 3)
            )
        })
        .padding(.horizontal)
//        .onChange(of: topic.isSelected) { newValue in
//            topicDataService.saveTopic(topic)
//        }
    }
}

#Preview {
    UserInterestsTopicScreen()
}
