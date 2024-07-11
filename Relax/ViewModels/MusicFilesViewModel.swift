//
//  MusicFilesViewModel.swift
//  Relax
//
//  Created by Илья Кузнецов on 27.06.2024.
//

import Foundation
import FirebaseDatabase
import AVFoundation

class MusicFilesViewModel: ObservableObject {
    @Published var files: [MusicFileDataModel] = []
    
    private let databaseRef = Database.database(url: .databaseURL).reference().child("music")
    
    init() {
        fetchFiles()
    }
    
    private func fetchFiles() {
        databaseRef.observe(.value) { snapshot in
            var newFiles: [MusicFileDataModel] = []
            for child in snapshot.children {
                
                if let snapshot = child as? DataSnapshot {
                    if let data = snapshot.value as? [String: Any] {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: data)
                            let fileData = try JSONDecoder().decode(MusicFileDataModel.self, from: jsonData)
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
