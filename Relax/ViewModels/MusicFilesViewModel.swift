//
//  MusicFilesViewModel.swift
//  Relax
//
//  Created by Илья Кузнецов on 27.06.2024.
//

import Foundation
import FirebaseDatabase
import AVFoundation
import FirebaseAuth

final class MusicFilesViewModel: ObservableObject {
    @Published var files: [CourseAndPlaylistOfDayModel] = []
    @Published var userLikedMaterials: [CourseAndPlaylistOfDayModel] = []
    private let yandexViewModel = YandexAuthorization.shared
    
    private let databaseRef = Database.database(url: .databaseURL).reference().child("music")
    
    init() {
        fetchFiles()
    }
    
    func fetchFiles() {
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
            self.files = newFiles
        }
    }
    
    func getCoursesUserLiked() async {
        let snapshot = try? await Database.database(url: .databaseURL).reference().child("users").child(Auth.auth().currentUser?.uid ?? yandexViewModel.yandexUserID).child("likedPlaylists").getData()
        guard let snapshot = snapshot, let likedPlaylists = snapshot.value as? [String: Bool] else { return }
        let likedObjects = self.files.filter { course in
            return likedPlaylists.keys.contains(course.name)
        }
        self.userLikedMaterials = likedObjects
    }
    
    func getSongDuration(from urlString: String, completion: @escaping (Double?) -> Void) {
        guard let url = URL(string: urlString) else {
            print("Неверный URL")
            completion(nil)
            return
        }
        
        let asset = AVURLAsset(url: url)
        
        Task {
            do {
                let duration = try await asset.load(.duration)
                let durationInSeconds = CMTimeGetSeconds(duration)
                guard durationInSeconds.isFinite else {
                    completion(nil)
                    return
                }
                let durationInMinutes = durationInSeconds / 60.0
                completion(durationInMinutes)
            } catch {
                print("Ошибка при загрузке длительности: \(error)")
                completion(nil)
            }
        }
    }
}
