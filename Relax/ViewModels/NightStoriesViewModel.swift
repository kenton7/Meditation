//
//  NightStoriesViewModel.swift
//  Relax
//
//  Created by Илья Кузнецов on 29.06.2024.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import SwiftUI

struct LikedPlaylistsModel: Codable {
    var id: String?
    var name: String?
    var imageURL: String?
    var color: ButtonColor?
    var duration: String?
    var description: String?
    var listenedCount: Int?
    var type: Types?
    var isDaily: Bool?
    var likes: Int?
    var genre: String?
    var isLiked: Bool?
}

class NightStoriesViewModel: ObservableObject {
    
    @StateObject private var databaseVM = ChangeDataInDatabase()
    @Published var nightStories: [CourseAndPlaylistOfDayModel] = []
    @Published var filteredStories: [CourseAndPlaylistOfDayModel] = []
    private var playerViewModel = PlayerViewModel.shared
    private let databaseRef = Database.database(url: .databaseURL).reference().child("nightStories")
    
    
    init() {
        fetchNightStories()
    }
    
    private func fetchNightStories() {
        databaseRef.observe(.value) { snapshot in
            var newFiles: [CourseAndPlaylistOfDayModel] = []
            for child in snapshot.children {
                
                if let snapshot = child as? DataSnapshot {
                    if let data = snapshot.value as? [String: Any] {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: data)
                            let fileData = try JSONDecoder().decode(CourseAndPlaylistOfDayModel.self, from: jsonData)
                            newFiles.append(fileData)
                        } catch {
                            print("Error decoding snapshot: \(error.localizedDescription)")
                        }
                    } else {
                        print("Failed to convert snapshot to dictionary")
                    }
                }
            }
            self.nightStories = newFiles
            self.filteredStories = newFiles
        }
    }
    
    func filterResults(by genre: String) {
        if genre == "Всё" {
            filteredStories = nightStories
        } else if genre == "Любимое" {
            if let user = Auth.auth().currentUser {
                Database.database(url: .databaseURL).reference().child("users").child(user.uid).child("likedPlaylists").getData { error, snapshot in
                    if let snapshot {
                        if let likedPlaylists = snapshot.value as? [String: Bool] {
                            DispatchQueue.main.async {
                                let likedObjects = self.nightStories.filter { story in
                                    if story.type == .story {
                                        return likedPlaylists.keys.contains(story.name)
                                    } else {
                                        return false
                                    }
                                }
                                self.filteredStories = likedObjects
                            }
                        }
                    }
                }
            }
        } else {
            filteredStories = nightStories.filter { $0.genre == genre }
        }
    }
        
        func playStoryFrom(url: String) {
            playerViewModel.playAudio(from: url, playlist: [])
        }
}
