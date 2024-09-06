//
//  CoursesViewModel.swift
//  Relax
//
//  Created by Илья Кузнецов on 27.06.2024.
//

import Foundation
import AVKit
import FirebaseDatabase
import FirebaseAuth
import Combine


final class CoursesViewModel: ObservableObject {
    
    enum PathToMaterialOfDay: String {
        case playlist = "playlistOfDay"
        case meditation = "courseOfDay"
    }
    
    enum Paths: String {
        case allCourses = "courses"
        case allPlaylists = "music"
        case nightStories = "nightStories"
        case emergencyMeditations = "emergencyMeditation"
    }
    
    @Published var allCourses: [CourseAndPlaylistOfDayModel] = []
    @Published var emergencyMeditations: [CourseAndPlaylistOfDayModel] = []
    @Published var dailyRecommendations: [CourseAndPlaylistOfDayModel] = []
    @Published var playlists: [CourseAndPlaylistOfDayModel] = []
    @Published var nightStories: [CourseAndPlaylistOfDayModel] = []
    @Published var isPlaying: Bool = false
    @Published var likesCount = 0
    @Published var filteredStories: [CourseAndPlaylistOfDayModel] = []
    @Published var userLikedMaterials: [CourseAndPlaylistOfDayModel] = []
    @Published var dailyCourses: [CourseAndPlaylistOfDayModel] = []
    @Published var isSelected = false
    @Published var lessons: [Lesson] = []
    private var playerViewModel = PlayerViewModel.shared
    private let yandexViewModel = YandexAuthorization.shared
    private var cancellables = Set<AnyCancellable>()
    private var lastUpdate: Date?
    var dailyCourse: CourseAndPlaylistOfDayModel?
    
    init() {
//        playerViewModel.$isPlaying
//            .receive(on: RunLoop.main)
//            .assign(to: \.isPlaying, on: self)
//            .store(in: &cancellables)
//        lastUpdate = UserDefaults.standard.object(forKey: "lastUpdate") as? Date
    }
    
    func fetchCourseDetails(type: Types, courseID: String) async -> [Lesson] {
        var pathToLesson: DatabaseReference = Database.database(url: .databaseURL).reference().child("courses").child(courseID).child("lessons")
        
        switch type {
        case .meditation:
            pathToLesson = Database.database(url: .databaseURL).reference().child("courses").child(courseID).child("lessons")
        case .story:
            pathToLesson = Database.database(url: .databaseURL).reference().child("nightStories").child(courseID).child("lessons")
        case .emergency:
            pathToLesson = Database.database(url: .databaseURL).reference().child("emergencyMeditation").child(courseID).child("lessons")
        case .playlist:
            pathToLesson = Database.database(url: .databaseURL).reference().child("music").child(courseID).child("lessons")
        }
        
        return await withCheckedContinuation { continuation in
            pathToLesson.observeSingleEvent(of: .value) { snapshot in
                var newFiles: [Lesson] = []
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot {
                        if let data = snapshot.value as? [String: Any] {
                            do {
                                let jsonData = try JSONSerialization.data(withJSONObject: data)
                                let fileData = try JSONDecoder().decode(Lesson.self, from: jsonData)
                                newFiles.append(fileData)
                            } catch {
                                print("Error decoding snapshot: \(error)")
                            }
                        } else {
                            print("Failed to convert snapshot to dictionary")
                        }
                    }
                }
                continuation.resume(returning: newFiles)
            }
        }
    }

    @MainActor
    func getCoursesNew(isDaily: Bool, path: Paths) async {
        let databaseURL = Database.database(url: .databaseURL).reference().child(path.rawValue)
        
        do {
            let snapshot = try await databaseURL.getData()
            var tempCourses: [CourseAndPlaylistOfDayModel] = []
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot, let data = snapshot.value as? [String: Any] {
                    let jsonData = try JSONSerialization.data(withJSONObject: data)
                    let courseData = try JSONDecoder().decode(CourseAndPlaylistOfDayModel.self, from: jsonData)
                    tempCourses.append(courseData)
                }
            }
            if isDaily {
                self.allCourses = tempCourses
                self.dailyCourses = allCourses.filter { $0.isDaily == true }
            } else {
                switch path {
                case .allCourses:
                    self.allCourses = tempCourses
                case .allPlaylists:
                    self.playlists = tempCourses
                case .nightStories:
                    self.nightStories = tempCourses
                case .emergencyMeditations:
                    self.emergencyMeditations = tempCourses
                }
            }
        } catch {
            print("Error decoding snapshot: \(error)")
        }

    }

    
//    @MainActor
//    func getCourses(isDaily: Bool) async {
//        let databaseURL = Database.database(url: .databaseURL).reference().child("courses")
//        do {
//            let snapshot = try await databaseURL.getData()
//            var localCourses: [CourseAndPlaylistOfDayModel] = []
//            for child in snapshot.children {
//                if let snapshot = child as? DataSnapshot, let data = snapshot.value as? [String: Any] {
//                    let jsonData = try JSONSerialization.data(withJSONObject: data)
//                    let courseData = try JSONDecoder().decode(CourseAndPlaylistOfDayModel.self, from: jsonData)
//                    localCourses.append(courseData)
//                }
//            }
//            if isDaily {
//                self.allCourses = localCourses
//                self.dailyCourses = allCourses.filter { $0.isDaily == true }
//            } else {
//                self.allCourses = localCourses
//                self.filteredStories = localCourses
//                self.likesCount = localCourses.reduce(0) { $0 + $1.likes }
//            }
//        } catch {
//            print("Error decoding snapshot: \(error)")
//        }
//    }
    
//    @MainActor
//    func filterResults(by genre: String) async {
//        if genre == "Всё" {
//            await getCourses(isDaily: false)
//        } else if genre == "Любимое" {
//            if let user = Auth.auth().currentUser {
//                let snapshot = try? await Database.database(url: .databaseURL).reference().child("users").child(user.uid).child("likedPlaylists").getData()
//                
//                guard let snapshot = snapshot, let likedPlaylists = snapshot.value as? [String: Bool] else { return }
//                
//                let likedObjects = self.allCourses.filter { story in
//                    return story.type == .meditation && likedPlaylists.keys.contains(story.name)
//                }
//                self.filteredStories = likedObjects
//            }
//        } else {
//            self.filteredStories = self.allCourses.filter { $0.genre == genre }
//        }
//    }
    
    
    func getCoursesUserLiked() async {
        let snapshot = try? await Database.database(url: .databaseURL).reference().child("users").child(Auth.auth().currentUser?.uid ?? yandexViewModel.yandexUserID).child("likedPlaylists").getData()
        guard let snapshot = snapshot, let likedPlaylists = snapshot.value as? [String: Bool] else { return }
        
        await getCoursesNew(isDaily: false, path: .allCourses)
        await getCoursesNew(isDaily: false, path: .emergencyMeditations)
        await getCoursesNew(isDaily: false, path: .allPlaylists)
        await getCoursesNew(isDaily: false, path: .nightStories)
        
        await MainActor.run {
            let likedMeditations = self.allCourses.filter { likedPlaylists.keys.contains($0.name) }
            let likedEmergency = self.emergencyMeditations.filter { likedPlaylists.keys.contains($0.name) }
            let likedMusic = self.playlists.filter { likedPlaylists.keys.contains($0.name) }
            let likedStories = self.nightStories.filter { likedPlaylists.keys.contains($0.name) }
            
            self.userLikedMaterials = likedMeditations
            self.userLikedMaterials += likedEmergency
            self.userLikedMaterials += likedMusic
            self.userLikedMaterials += likedStories
        }
    }
    
    func pause() {
        playerViewModel.pause()
    }
    
    func isPlaying(urlString: String) -> Bool {
        return playerViewModel.isPlaying(urlString: urlString)
    }

}


