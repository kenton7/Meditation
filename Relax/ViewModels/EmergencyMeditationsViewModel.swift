//
//  EmergencyMeditationsViewModel.swift
//  Relax
//
//  Created by Илья Кузнецов on 14.07.2024.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

final class EmergencyMeditationsViewModel: ObservableObject {
    
    @StateObject private var databaseVM = ChangeDataInDatabase.shared
    @Published var emergencyMeditations: [CourseAndPlaylistOfDayModel] = []
    @Published var userLikedMaterials: [CourseAndPlaylistOfDayModel] = []
    
    private let yandexViewModel = YandexAuthorization.shared
    private let databaseRef = Database.database(url: .databaseURL).reference().child("emergencyMeditation")
    
    init() {
        fetchEmergencyMeditations()
    }
    
    func fetchEmergencyMeditations() {
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
                            print("Error decoding snapshot: \(error)")
                        }
                    } else {
                        print("Failed to convert snapshot to dictionary")
                    }
                }
            }
            self.emergencyMeditations = newFiles
        }
    }
    
    func getCoursesUserLiked() async {
        let snapshot = try? await Database.database(url: .databaseURL).reference().child("users").child(Auth.auth().currentUser?.uid ?? yandexViewModel.yandexUserID).child("likedPlaylists").getData()
        guard let snapshot = snapshot, let likedPlaylists = snapshot.value as? [String: Bool] else { return }
        let likedObjects = self.emergencyMeditations.filter { course in
            return likedPlaylists.keys.contains(course.name)
        }
        self.userLikedMaterials = likedObjects
    }
    
}
