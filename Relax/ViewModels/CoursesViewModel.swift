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
    @Published var dailyCourses: [CourseAndPlaylistOfDayModel] = []
    private var playerViewModel = PlayerViewModel.shared
    private var cancellables = Set<AnyCancellable>()
    private let databaseRef = Database.database(url: .databaseURL).reference().child("courseAndPlaylistOfDay")
    private let imageLoadSemaphore = DispatchSemaphore(value: 1)
    private var lastUpdate: Date?
    var dailyCourse: CourseAndPlaylistOfDayModel?
    
    init() {
        playerViewModel.$isPlaying
            .receive(on: RunLoop.main)
            .assign(to: \.isPlaying, on: self)
            .store(in: &cancellables)
        lastUpdate = UserDefaults.standard.object(forKey: "lastUpdate") as? Date
    }
    
    func fetchCourseDetails(type: Types, courseID: String) {
        var pathToLesson: DatabaseReference = Database.database(url: .databaseURL).reference().child("courses").child(courseID).child("lessons")
        switch type {
        case .meditation:
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
        case .emergency:
            pathToLesson = Database.database(url: .databaseURL).reference().child("emergencyMeditation").child(courseID).child("lessons")
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
        case .playlist:
            pathToLesson = Database.database(url: .databaseURL).reference().child("music").child(courseID).child("lessons")
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
        }
        
    }
    
    @MainActor
        func getCourses(isDaily: Bool) async {
            //let databaseURL = Database.database(url: .databaseURL).reference().child(isDaily ? "courseAndPlaylistOfDay" : "courses")
            let databaseURL = Database.database(url: .databaseURL).reference().child("courses")
            let snapshot = try? await databaseURL.getData()

            guard let snapshot = snapshot else { return }

            var localCourses: [CourseAndPlaylistOfDayModel] = []
            var localLikes = 0

            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot, let data = snapshot.value as? [String: Any] {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: data)
                        let courseData = try JSONDecoder().decode(CourseAndPlaylistOfDayModel.self, from: jsonData)
                        localCourses.append(courseData)
                        localLikes = courseData.likes
                    } catch {
                        print("Error decoding snapshot: \(error)")
                    }
                }
            }
            
            if isDaily {
                self.allCourses = localCourses
                self.dailyCourses = allCourses.filter { $0.isDaily == true }
                //randomDailyCourse()
            } else {
                self.allCourses = localCourses
                self.filteredStories = localCourses
                self.likesCount = localLikes
            }
        }
    
    func randomDailyCourse() {
        if let lastUpdate {
            if Calendar.current.isDateInYesterday(lastUpdate) {
                //Если дата - это вчера, то выбираем новый дневной курс, устанавливая в бэке isDaily = true и меняем у старого курса isDaily = false
                Database.database(url: .databaseURL).reference().child("courses").child(self.dailyCourse!.id).updateChildValues(["isDaily": false])
                self.dailyCourse = allCourses.randomElement()
                Database.database(url: .databaseURL).reference().child("courses").child(self.dailyCourse!.id).updateChildValues(["isDaily": true])
                DispatchQueue.main.async {
                    self.dailyCourses = self.allCourses.filter { $0.isDaily == true }
                }
            } else {
                //Если не вчера
                DispatchQueue.main.async {
                    self.dailyCourses = self.allCourses.filter { $0.isDaily == true }
                }
            }
        } else {
            self.dailyCourse = allCourses.randomElement()
            DispatchQueue.main.async {
                self.dailyCourses = self.allCourses.filter { $0.isDaily == true }
            }
            Database.database(url: .databaseURL).reference().child("courses").child(self.dailyCourse!.id).updateChildValues(["isDaily": true])
            self.lastUpdate = Date()
            UserDefaults.standard.set(self.lastUpdate, forKey: "lastUpdate")
        }
    }
    
    @MainActor
        func filterResults(by genre: String) async {
            if genre == "Всё" {
                await getCourses(isDaily: false)
            } else if genre == "Любимое" {
                if let user = Auth.auth().currentUser {
                    let snapshot = try? await Database.database(url: .databaseURL).reference().child("users").child(user.uid).child("likedPlaylists").getData()

                    guard let snapshot = snapshot, let likedPlaylists = snapshot.value as? [String: Bool] else { return }

                    let likedObjects = self.allCourses.filter { story in
                        return story.type == .meditation && likedPlaylists.keys.contains(story.name)
                    }

                    self.filteredStories = likedObjects
                }
            } else {
                self.filteredStories = self.allCourses.filter { $0.genre == genre }
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


