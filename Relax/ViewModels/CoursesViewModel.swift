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


class CoursesViewModel: ObservableObject {
    
    enum PathToMaterialOfDay: String {
        case playlist = "playlistOfDay"
        case meditation = "courseOfDay"
    }
    
    enum Paths: String {
//        case playlistOfDay = "playlistOfDay"
        case playlistOfDay = "courseAndPlaylistOfDay"
        case meditationOfDay = "courseOfDay"
        case allCourses = "courses"
        case allPlaylists = "music"
        case nightStories = "nightStories"
    }
    
    @Published var allCourses: [CourseAndPlaylistOfDayModel] = []
    @Published var dailyRecommendations: [CourseAndPlaylistOfDayModel] = []
    @Published var lessons: [Lesson] = []
    @Published var isPlaying: Bool = false
    @Published var likesCount = 0
    @Published var filteredStories: [CourseAndPlaylistOfDayModel] = []
    private var playerViewModel = PlayerViewModel.shared
    private var cancellables = Set<AnyCancellable>()
    private let databaseRef = Database.database(url: .databaseURL).reference().child("courseAndPlaylistOfDay")
    
    init() {
        playerViewModel.$isPlaying
            .receive(on: RunLoop.main)
            .assign(to: \.isPlaying, on: self)
            .store(in: &cancellables)
    }
    
    func fetchCourseDetails(type: Types, courseID: String, isDaily: Bool) {
        var pathToLesson: DatabaseReference!
        
        if isDaily {
            pathToLesson = Database.database(url: .databaseURL).reference().child("courseAndPlaylistOfDay").child(courseID).child("lessons")
        } else {
            pathToLesson = Database.database(url: .databaseURL).reference().child("courses").child(courseID).child("lessons")
        }
        
        switch type {
        case .playlist, .meditation:
            pathToLesson.observe(.value) { snapshot in
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
                DispatchQueue.main.async {
                    self.lessons = newFiles
                }
            }
        case .story:
            pathToLesson = Database.database(url: .databaseURL).reference().child("nightStories").child(courseID).child("lessons")
            pathToLesson.observe(.value) { snapshot in
                var newFiles: [Lesson] = []
                //var likesCount = 0
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
                DispatchQueue.main.async {
                    self.lessons = newFiles
                }
            }
        }
        
    }
    
    func getCourses(isDaily: Bool) {
        let databaseURL = Database.database(url: .databaseURL).reference().child(isDaily ? "courseAndPlaylistOfDay" : "courses")
        databaseURL.observe(.value) { snapshot in
            var courses: [CourseAndPlaylistOfDayModel] = []
            var likes = 0
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot {
                    if let data = snapshot.value as? [String: Any] {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: data)
                            let courseData = try JSONDecoder().decode(CourseAndPlaylistOfDayModel.self, from: jsonData)
                            courses.append(courseData)
                            likes = courseData.likes
                        } catch {
                            print("Error decoding snapshot: \(error)")
                        }
                    } else {
                        print("Failed to convert snapshot to dictionary")
                    }
                }
            }
            DispatchQueue.main.async {
                self.allCourses = courses
                self.filteredStories = courses
                self.likesCount = likes
            }
        }
    }
    
    func filterResults(by genre: String) {
        if genre == "Всё" {
            getCourses(isDaily: false)
            DispatchQueue.main.async {
                self.filteredStories = self.allCourses
            }
        } else if genre == "Любимое" {
            if let user = Auth.auth().currentUser {
                Database.database(url: .databaseURL).reference().child("users").child(user.uid).child("likedPlaylists").getData { error, snapshot in
                    if let snapshot {
                        if let likedPlaylists = snapshot.value as? [String: Bool] {
                            DispatchQueue.main.async {
                                let likedObjects = self.allCourses.filter { story in
                                    if story.type == .meditation {
                                        return likedPlaylists.keys.contains(story.name)
                                    } else {
                                        return false
                                    }
                                }
                                DispatchQueue.main.async {
                                    self.filteredStories = likedObjects
                                }
                            }
                        }
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.filteredStories = self.allCourses.filter { $0.genre == genre }
            }
        }
    }

    func playCourse(from urlString: String, playlist: [Lesson]) {
        playerViewModel.playAudio(from: urlString, playlist: playlist)
    }
    
    func pause() {
        playerViewModel.pause()
    }
    
    func isPlaying(urlString: String) -> Bool {
        return playerViewModel.isPlaying(urlString: urlString)
    }
    
}


