//
//  ChangeDataInDatabase.swift
//  Relax
//
//  Created by Илья Кузнецов on 04.07.2024.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class ChangeDataInDatabase: ObservableObject {
    
    enum IncrementDecrementLike {
        case increment
        case decrement
    }
    
    @Published var likes = 0
    @Published var isLiked = false
    @Published var listeners = 0
    @Published var storyURL = ""
    @Published var isTutorialViewed = false
    
    func userLiked(course: CourseAndPlaylistOfDayModel, type: IncrementDecrementLike, isLiked: Bool, user: User, courseType: Types, isDaily: Bool) {
        
        var likesCount = likes
        
        switch type {
        case .increment:
            likesCount += 1
            self.isLiked = true
            Database.database(url: .databaseURL).reference().child("users").child(user.uid).child("likedPlaylists").updateChildValues([course.name: self.isLiked])
        case .decrement:
            self.isLiked = false
            guard likesCount >= 0 else { return }
            likesCount -= 1
            Database.database(url: .databaseURL).reference().child("users").child(user.uid).child("likedPlaylists").child(course.name).removeValue()
        }
        
        if isDaily {
            Database.database(url: .databaseURL).reference().child("courseAndPlaylistOfDay").child(course.id).updateChildValues(["likes": likesCount])
        } else {
            switch courseType {
            case .playlist:
                Database.database(url: .databaseURL).reference().child("music").child(course.id).updateChildValues(["likes": likesCount])
            case .meditation:
                Database.database(url: .databaseURL).reference().child("courses").child(course.id).updateChildValues(["likes": likesCount])
            case .story:
                Database.database(url: .databaseURL).reference().child("nightStories").child(course.id).updateChildValues(["likes": likesCount])
            }
        }
        //Database.database(url: .databaseURL).reference().child("users").child(user.uid).child("likedPlaylists").updateChildValues([course.name: self.isLiked])
    }
    
    func updateListeners(course: CourseAndPlaylistOfDayModel, type: Types, isDaily: Bool) {
        var listenersCount = self.listeners
        listenersCount += 1
                
        if isDaily {
            Database.database(url: .databaseURL).reference().child("courseAndPlaylistOfDay").child(course.id).updateChildValues(["listenedCount": listenersCount])
        } else {
            switch type {
            case .playlist:
                Database.database(url: .databaseURL).reference().child("music").child(course.id).updateChildValues(["listenedCount": listenersCount])
            case .meditation:
                Database.database(url: .databaseURL).reference().child("courses").child(course.id).updateChildValues(["listenedCount": listenersCount])
            case .story:
                Database.database(url: .databaseURL).reference().child("nightStories").child(course.id).updateChildValues(["listenedCount": listenersCount])
            }
        }
    }
    
    func getListenersIn(course: CourseAndPlaylistOfDayModel, courseType: Types, isDaily: Bool) {
        
        if isDaily {
            Database.database(url: .databaseURL).reference().child("courseAndPlaylistOfDay").child(course.id).child("listenedCount").observe(.value) { snapshot in
                if let listenersCount = snapshot.value as? Int {
                    DispatchQueue.main.async {
                        self.listeners = listenersCount
                    }
                } else {
                    print("Значение не найдено")
                }
            }
        } else {
            switch courseType {
            case .playlist:
                Database.database(url: .databaseURL).reference().child("music").child(course.id).child("listenedCount").observe(.value) { snapshot in
                    if let listenersCount = snapshot.value as? Int {
                        DispatchQueue.main.async {
                            self.listeners = listenersCount
                        }
                    } else {
                        print("Значение не найдено")
                    }
                }
            case .meditation:
                Database.database(url: .databaseURL).reference().child("courses").child(course.id).child("listenedCount").observeSingleEvent(of: .value) { snapshot in
                    if let listenersCount = snapshot.value as? Int {
                        DispatchQueue.main.async {
                            self.listeners = listenersCount
                        }
                    } else {
                        print("Значение не найдено")
                    }
                }
            case .story:
                Database.database(url: .databaseURL).reference().child("nightStories").child(course.id).child("listenedCount").observeSingleEvent(of: .value) { snapshot in
                    if let listenersCount = snapshot.value as? Int {
                        DispatchQueue.main.async {
                            self.listeners = listenersCount
                        }
                    } else {
                        print("Значение не найдено")
                    }
                }
            }
        }
    }

    func getLikesIn(course: CourseAndPlaylistOfDayModel, courseType: Types, isDaily: Bool) {
                
        if isDaily {
            Database.database(url: .databaseURL).reference().child("courseAndPlaylistOfDay").child(course.id).child("likes").observe(.value) { snapshot in
                if let likesValue = snapshot.value as? Int {
                    DispatchQueue.main.async {
                        self.likes = likesValue
                    }
                } else {
                    print("Значение не найдено")
                }
            }
        } else {
            switch courseType {
            case .playlist:
                Database.database(url: .databaseURL).reference().child("music").child(course.id).child("likes").observe(.value) { snapshot in
                    if let likesValue = snapshot.value as? Int {
                        DispatchQueue.main.async {
                            self.likes = likesValue
                        }
                    } else {
                        print("Значение не найдено")
                    }
                }
            case .meditation:
                Database.database(url: .databaseURL).reference().child("courses").child(course.id).child("likes").observeSingleEvent(of: .value) { snapshot in
                    if let likesValue = snapshot.value as? Int {
                        DispatchQueue.main.async {
                            self.likes = likesValue
                        }
                    } else {
                        print("Значение не найдено")
                    }
                }
            case .story:
                Database.database(url: .databaseURL).reference().child("nightStories").child(course.id).child("likes").observeSingleEvent(of: .value) { snapshot in
                    if let likesValue = snapshot.value as? Int {
                        DispatchQueue.main.async {
                            self.likes = likesValue
                        }
                    } else {
                        print("Значение не найдено")
                    }
                }
            }
        }
    }
    
    func storyInfo(course: CourseAndPlaylistOfDayModel, isFemale: Bool) {
        Database.database(url: .databaseURL).reference().child("nightStories").child(course.id).child("lessons").child("lesson1").child(isFemale ? "audioFemaleURL" : "audioMaleURL").observe(.value) { snapshot in
            if let url = snapshot.value as? String {
                DispatchQueue.main.async {
                    self.storyURL = url
                }
            } else {
                print("Не НАЙДЕНО")
            }
        }
    }
    
    func checkIfUserLiked(user: User, course: CourseAndPlaylistOfDayModel) {
        let ref = Database.database(url: .databaseURL).reference()
        let likedPlaylistsRef = ref.child("users").child(user.uid).child("likedPlaylists")
        
        likedPlaylistsRef.observeSingleEvent(of: .value) { snapshot in
            if let likedPlaylists = snapshot.value as? [String: Bool] {
                if let isLiked = likedPlaylists[course.name] {
                    DispatchQueue.main.async {
                        self.isLiked = isLiked
                        print("isLiked? \(isLiked)")
                    }
                } else {
                    print("Значение для курса \(course.name) не найдено или не является Bool")
                }
            } else {
                print("Значения курсов не найдены или не в ожидаемом формате")
            }
        }
    }
    
    func writeToDatabaseIfUserViewedTutorial(user: User, isViewed: Bool) {
        Database.database(url: .databaseURL).reference().child("users").child(user.uid).child("isTutorialViewed").setValue(isViewed)
    }

    func checkIfUserViewedTutorial(user: User) async {
        Database.database(url: .databaseURL).reference().child("users").child(user.uid).child("isTutorialViewed").observeSingleEvent(of: .value) { snapshot in
            if let isViewed = snapshot.value as? Bool {
                DispatchQueue.main.async {
                    self.isTutorialViewed = isViewed
                }
            } else {
                print("Значение isTutorialViewed не найдено")
            }
        }
    }

    
}
