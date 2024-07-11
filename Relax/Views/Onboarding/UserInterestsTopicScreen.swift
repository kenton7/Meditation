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
    
    @State private var topics = TopicsModel.getTopics()
    @State private var selectedTopics: [TopicsModel] = []
    @State private var isContinueTapped = false
    private let topicDataService = CoreDataService.shared
    
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
                        LazyVGrid(columns: columns, alignment: .center, spacing: 20, content: {
                            ForEach($topics, id: \.id) { $topic in
                                TopicButton(topic: $topic, selectedTopics: $selectedTopics)
//                                    .onChange(of: topic.isSelected) { _ in
//                                        print("selected")
//                                        topicDataService.saveTopic(topic)
//                                    }
                            }
                        })
                        .padding()
                        
                        Button(action: {
                            isContinueTapped = true
                        }, label: {
                            Text("Продолжить")
                                .foregroundStyle(.white)
                        })
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor(red: 142/255, green: 151/255, blue: 253/255, alpha: 1)))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding()
                        .disabled(selectedTopics.isEmpty)
                    }
                }
            }
        }
        .navigationDestination(isPresented: $isContinueTapped, destination: {
            RemindersScreen()
        })
        .navigationBarBackButtonHidden()
    }
}

struct TopicButton: View {
    @Binding var topic: TopicsModel
    @Binding var selectedTopics: [TopicsModel]
    private let topicDataService = CoreDataService.shared
    @StateObject private var recommendationsViewModel = RecommendationsViewModel()
    
    var body: some View {
        Button(action: {
            withAnimation {
                if !selectedTopics.contains(where: { $0.topicName == topic.topicName }) {
                    selectedTopics.append(topic)
                    topic.isSelected = true
                    let topicDict = ["name": topic.topicName]
                    Database.database(url: .databaseURL).reference().child("users").child(Auth.auth().currentUser?.uid ?? "").child("selectedTopics").child(topic.topicName).setValue(topicDict)
                    
                    topicDataService.saveTopic(topic)
                } else {
                    selectedTopics.removeAll(where: { $0.topicName == topic.topicName })
                    topic.isSelected = false
                    topicDataService.deleteTopic(topic: topic)
                    do {
                        try topicDataService.viewContext.save()
                    } catch {
                        print(error)
                    }
                }
            }
        }, label: {
            ZStack {
                //topic.color
                Color(uiColor: .init(red: CGFloat(topic.color.red) / 255,
                                     green: CGFloat(topic.color.green) / 255,
                                     blue: CGFloat(topic.color.blue) / 255,
                                     alpha: 1))
                VStack {
                    Image(uiImage: topic.imageView)
                        .padding(.vertical, 0)
                    Spacer()
                }
                VStack {
                    Spacer()
                    HStack {
                        Text(topic.topicName)
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
                    .stroke(topic.isSelected ? Color.green : Color.clear, lineWidth: 3)
            )
        })
        .padding(.horizontal)
        .onAppear {
            print(selectedTopics.isEmpty)
        }
//        .onChange(of: topic.isSelected) { newValue in
//            topicDataService.saveTopic(topic)
//        }
    }
}

#Preview {
    UserInterestsTopicScreen()
}
