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

class RecommendationsViewModel: ObservableObject {
    @Published var recommendations: [CourseAndPlaylistOfDayModel] = []
    @Published var usersTopics: [RecommendationModel] = []
    
    private let databaseRef = Database.database(url: .databaseURL).reference().child("recommendedMeditations")
    
    init() {
        fetchRecommendations()
    }
    
    private func fetchRecommendations() {
        databaseRef.observe(.value) { snapshot in
            var newFiles: [CourseAndPlaylistOfDayModel] = []
            var likesCount: Int = 0
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot {
                    if let data = snapshot.value as? [String: Any] {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: data)
                            let fileData = try JSONDecoder().decode(CourseAndPlaylistOfDayModel.self, from: jsonData)
                            newFiles.append(fileData)
                            likesCount = fileData.listenedCount
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
    
    func uploadTopicData(topic: TopicsModel) {
        guard let imageData = topic.image else {
            print("No image data to upload")
            return
        }
        
        let storageRef = Storage.storage().reference().child("selectedTopicsByUser/\(topic.topicName)")
        
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Failed to upload image: \(error.localizedDescription)")
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Failed to get download URL: \(error.localizedDescription)")
                    return
                }
            }
        }
    }
    
    func getTopicWhichUserSelected(user: User) async throws -> [UserSelectedTopics] {
        
        var topics: [UserSelectedTopics] = []
        
        let topicsSnapshot = try await Database.database(url: .databaseURL).reference().child("users").child(Auth.auth().currentUser?.uid ?? "").child("selectedTopics").getData()
        
        for child in topicsSnapshot.children {
            if let snapshot = child as? DataSnapshot {
                if let topicData = snapshot.value as? [String: Any] {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: topicData)
                        let topicsFile = try JSONDecoder().decode(UserSelectedTopics.self, from: jsonData)
                        topics.append(topicsFile)
                    } catch {
                        print("Error decoding snapshot: \(error.localizedDescription)")
                    }
                } else {
                    print("Failed to convert snapshot to dictionary")
                }
            }
        }
        return topics
    }
}

struct UserSelectedTopics: Codable {
    let name: String
}
