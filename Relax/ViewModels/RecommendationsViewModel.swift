//
//  RecommendationsViewModel.swift
//  Relax
//
//  Created by Илья Кузнецов on 27.06.2024.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

struct UserSelectedTopicsModel: Codable {
    let name: String
}

class RecommendationsViewModel: ObservableObject {
    @Published var recommendations: [CourseAndPlaylistOfDayModel] = []
    @Published var usersTopics: [UserSelectedTopicsModel] = []
    
    private let databaseRef = Database.database(url: .databaseURL).reference().child("courses")
    private let userSelectedTopicsRef = Database.database(url: .databaseURL).reference().child("users").child(Auth.auth().currentUser!.uid).child("selectedTopics")
    
    init() {
        getTopicsWhichUserSelected()
        //fetchRecommendations()
    }
    
    func getTopicsWhichUserSelected() {
        userSelectedTopicsRef.observe(.value) { snapshot in
            var topics: [UserSelectedTopicsModel] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot {
                    if let data = snapshot.value as? [String: Any] {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: data)
                            let fileData = try JSONDecoder().decode(UserSelectedTopicsModel.self, from: jsonData)
                            topics.append(fileData)
                        } catch {
                            print("Error decoding snapshot: \(error.localizedDescription)")
                        }
                    } else {
                        print("Failed to convert snapshot to dictionary")
                    }
                }
            }
            DispatchQueue.main.async {
                self.usersTopics = topics
            }
            self.fetchRecommendations()
        }
    }
    
    func fetchRecommendations() {
        databaseRef.observe(.value) { snapshot in
            var newFiles: [CourseAndPlaylistOfDayModel] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot {
                    if let data = snapshot.value as? [String: Any] {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: data)
                            let fileData = try JSONDecoder().decode(CourseAndPlaylistOfDayModel.self, from: jsonData)                            
                            self.usersTopics.forEach {
                                if $0.name == fileData.name {
                                    newFiles.append(fileData)
                                }
                            }
                        } catch {
                            print("Error decoding snapshot: \(error.localizedDescription)")
                        }
                    } else {
                        print("Failed to convert snapshot to dictionary")
                    }
                }
            }
            self.recommendations = newFiles
        }
    }
}
