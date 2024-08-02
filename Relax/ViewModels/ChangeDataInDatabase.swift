//
//  ChangeDataInDatabase.swift
//  Relax
//
//  Created by Илья Кузнецов on 04.07.2024.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import SwiftUI


protocol DatabaseChangable: AnyObject {
    func asyncDownload(course: CourseAndPlaylistOfDayModel, courseType: Types, isFemale: Bool, lesson: Lesson) async throws -> URL
    func downloadAllCourse(course: CourseAndPlaylistOfDayModel, courseType: Types, isFemale: Bool?, lessons: [Lesson]) async throws -> [URL]
    func userLiked(course: CourseAndPlaylistOfDayModel, type: IncrementDecrementLike, isLiked: Bool, user: User, courseType: Types)
    func updateListeners(course: CourseAndPlaylistOfDayModel, type: Types)
    func getListenersIn(course: CourseAndPlaylistOfDayModel, courseType: Types)
    func getLikesIn(course: CourseAndPlaylistOfDayModel, courseType: Types)
    func storyInfo(course: CourseAndPlaylistOfDayModel, isFemale: Bool)
    func checkIfUserLiked(user: User, course: CourseAndPlaylistOfDayModel)
    func writeToDatabaseIfUserViewedTutorial(user: User, isViewed: Bool)
    func checkIfUserViewedTutorial(user: User) async
    func updateDisplayName(newDisplayName: String) async throws
    func changeEmail(newEmail: String) async throws
    func updatePassword(newPassword: String, currentPassword: String) async throws
}

enum IncrementDecrementLike {
    case increment
    case decrement
}

final class ChangeDataInDatabase: ObservableObject, DatabaseChangable {
    
    @Published var likes = 0
    @Published var isLiked = false
    @Published var listeners = 0
    @Published var storyURL = ""
    @Published var isTutorialViewed = false
    @Published var isDownloadStarted = false
    @Published var downloadProgress = 0.0
    private var coursesViewModel = CoursesViewModel()
    private var authViewModel = AuthWithEmailViewModel()
    @State private var downloadURL: URL?
    
    func downloadAllCourse(course: CourseAndPlaylistOfDayModel, courseType: Types, isFemale: Bool?, lessons: [Lesson]) async throws -> [URL] {
        var results = [URL]()
        
        try await withThrowingTaskGroup(of: URL.self) { [unowned self] group in
            for lesson in lessons {
                group.addTask {
                    return try await self.asyncDownload(course: course, courseType: courseType, isFemale: isFemale ?? true, lesson: lesson)
                }
            }
            for try await result in group {
                results.append(result)
            }
        }
        
        return results
    }
    
    func asyncDownload(course: CourseAndPlaylistOfDayModel, courseType: Types, isFemale: Bool, lesson: Lesson) async throws -> URL {
        
        var localURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        var storageRef: StorageReference {
            switch courseType {
            case .playlist:
                return Storage.storage().reference(withPath: "music/\(course.id)/\(lesson.lessonID).mp3")
            case .meditation:
                return Storage.storage().reference(withPath: "meditations/\(course.id)/\(isFemale ? "female" : "male")/\(lesson.lessonID)\(isFemale ? "Female" : "Male").mp3")
            case .story:
                return Storage.storage().reference(withPath: "stories/\(course.id)/\(isFemale ? "female" : "male")/\(lesson.lessonID)\(isFemale ? "Female" : "Male").mp3")
            case .emergency:
                return Storage.storage().reference(withPath: "emergency/\(course.id)/\(isFemale ? "female" : "male")/\(lesson.lessonID)\(isFemale ? "Female" : "Male").mp3")
            }
        }
        
        localURL.append(path: "\(course.name)/\(lesson.name)", directoryHint: .isDirectory)
        localURL.appendPathExtension(for: .mp3)
        
        return try await withCheckedThrowingContinuation { continuation in
            let downloadTask = storageRef.write(toFile: localURL) { url, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: localURL)
                }
            }
            
            downloadTask.observe(.progress) { snapshot in
                let percentComplete = 100 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
                print("Загрузка: \(percentComplete)% завершено")
                DispatchQueue.main.async {
                    self.downloadProgress = percentComplete
                }
            }
            
            downloadTask.observe(.failure) { snapshot in
                if let error = snapshot.error {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func userLiked(course: CourseAndPlaylistOfDayModel, type: IncrementDecrementLike, isLiked: Bool, user: User, courseType: Types) {
        
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
        
        switch courseType {
        case .playlist:
            Database.database(url: .databaseURL).reference().child("music").child(course.id).updateChildValues(["likes": likesCount])
        case .meditation:
            Database.database(url: .databaseURL).reference().child("courses").child(course.id).updateChildValues(["likes": likesCount])
        case .story:
            Database.database(url: .databaseURL).reference().child("nightStories").child(course.id).updateChildValues(["likes": likesCount])
        case .emergency:
            Database.database(url: .databaseURL).reference().child("emergencyMeditation").child(course.id).updateChildValues(["likes": likesCount])
        }
    }
    
    func updateListeners(course: CourseAndPlaylistOfDayModel, type: Types) {
        
        var reference: DatabaseReference
        self.listeners += 1
        
        switch type {
        case .playlist:
            reference = Database.database(url: .databaseURL).reference().child("music").child(course.id)
        case .meditation:
            reference = Database.database(url: .databaseURL).reference().child("courses").child(course.id)
        case .story:
            reference = Database.database(url: .databaseURL).reference().child("nightStories").child(course.id)
        case .emergency:
            reference = Database.database(url: .databaseURL).reference().child("emergencyMeditation").child(course.id)
        }
        
        // Загружаем текущее значение
        reference.child("listenedCount").observeSingleEvent(of: .value) { snapshot in
            var currentListeners = snapshot.value as? Int ?? 0
            currentListeners += 1
            
            // Сохраняем увеличенное значение обратно в базу данных
            reference.updateChildValues(["listenedCount": currentListeners]) { error, _ in
                if let error = error {
                    print("Ошибка при обновлении listenedCount: \(error)")
                } else {
                    DispatchQueue.main.async {
                        self.listeners = currentListeners
                        print("Обновляем прослушивания. Стало: \(self.listeners)")
                    }
                }
            }
        }
    }
    
    func getListenersIn(course: CourseAndPlaylistOfDayModel, courseType: Types) {
        
        var path: String {
            switch courseType {
            case .playlist:
                "music"
            case .meditation:
                "courses"
            case .story:
                "nightStories"
            case .emergency:
                "emergencyMeditation"
            }
        }
        
        Database.database(url: .databaseURL).reference().child(path).child(course.id).child("listenedCount").observeSingleEvent(of: .value) { snapshot in
            if let listenersCount = snapshot.value as? Int {
                DispatchQueue.main.async {
                    self.listeners = listenersCount
                }
            } else {
                print("Значнние не найдено для \(course.id) в \(path)")
            }
        }
    }
    
    func getLikesIn(course: CourseAndPlaylistOfDayModel, courseType: Types) {
        
        var path: String {
            switch courseType {
            case .playlist:
                "music"
            case .meditation:
                "courses"
            case .story:
                "nightStories"
            case .emergency:
                "emergencyMeditation"
            }
        }
        
        Database.database(url: .databaseURL).reference().child(path).child(course.id).child("likes").observeSingleEvent(of: .value) { snapshot in
            if let likesCount = snapshot.value as? Int {
                DispatchQueue.main.async {
                    self.likes = likesCount
                }
            } else {
                print("Значнние не найдено для \(course.id) в \(path)")
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
    
    func updateDisplayName(newDisplayName: String) async throws {
        guard let user = Auth.auth().currentUser else {
            print("No user is signed in.")
            throw(NSError(domain: "Авторизованный пользователь не найден", code: 121))
        }
        
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = newDisplayName
        
        do {
            try await changeRequest.commitChanges()
        } catch {
            throw(NSError(domain: "Произошла ошибка при попытке изменения имени", code: 119))
        }
    }
    
    func changeEmail(newEmail: String) async throws {
        guard !newEmail.isEmpty, newEmail.isValidEmail() else {
            throw(NSError(domain: "Новое значение email введено неверно или не может быть пустым", code: 120, userInfo: ["Ошибка": ""]))
        }
        
        guard let user = Auth.auth().currentUser, !newEmail.isEmpty, newEmail.isValidEmail() else {
            print("No user is signed in.")
            throw(NSError(domain: "Авторизованный пользователь не найден", code: 121))
        }
        do {
            try await user.sendEmailVerification(beforeUpdatingEmail: newEmail)
        } catch {
            throw(error)
        }
    }
    
    func updatePassword(newPassword: String, currentPassword: String) async throws {
        guard let user = Auth.auth().currentUser else {
            print("Пользователь не найден")
            throw(NSError(domain: "Авторизованный пользователь не найден", code: 121))
        }
        
        // Для повторной аутентификации используем метод EmailAuthProvider
        let credential = EmailAuthProvider.credential(withEmail: user.email ?? "", password: currentPassword)
        
        do {
            try await user.reauthenticate(with: credential)
            try await user.updatePassword(to: newPassword)
            authViewModel.signOut()
        } catch {
            throw(NSError(domain: "Текущий пароль введён неверно", code: 122))
        }
    }
}

