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
    @Published var isDownloadStarted = false
    @Published var downloadProgress = 0.0
    private var coursesViewModel = CoursesViewModel()
    private var authViewModel = AuthWithEmailViewModel()
    @State private var downloadURL: URL?
    
    func download(course: CourseAndPlaylistOfDayModel, courseType: Types, isFemale: Bool, lesson: Lesson) {
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        var localURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        switch courseType {
        case .playlist:
            break
        case .meditation:
            let lessonRef = storageRef.child("meditations/\(course.id)/\(isFemale ? "female" : "male")/\(lesson.lessonID)\(isFemale ? "Female" : "Male").mp3")
            localURL.append(path: "\(course.name)/\(lesson.name)", directoryHint: .isDirectory)
            localURL.appendPathExtension(for: .mp3)
            print(lessonRef)
            let downloadTask = lessonRef.write(toFile: localURL) { url, error in
                self.isDownloadStarted = true
                if let error = error {
                    print("Ошибка загрузки: \(error.localizedDescription)")
                    self.isDownloadStarted = false
                    return
                }
                print("Файл загружен в: \(url!.path)")
                DispatchQueue.main.async {
                    self.downloadURL = url
                    self.isDownloadStarted = false
                }
            }
            
            downloadTask.observe(.progress) { snapshot in
                let percentComplete = 100 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
                print("Загрузка: \(percentComplete)% завершено")
                self.downloadProgress = percentComplete
            }
        case .story:
            break
            //referecne = storage.reference(forURL: .databaseURL + "\(isFemale ? lesson.audioFemaleURL : lesson.audioMaleURL)")
        case .emergency:
            break
            //referecne = storage.reference(forURL: .databaseURL + "\(isFemale ? lesson.audioFemaleURL : lesson.audioMaleURL)")
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
        
        switch courseType {
        case .playlist:
            Database.database(url: .databaseURL).reference().child("music").child(course.id).child("listenedCount").observeSingleEvent(of: .value) { snapshot in
                if let listenersCount = snapshot.value as? Int {
                    DispatchQueue.main.async {
                        self.listeners = listenersCount
                    }
                } else {
                    print("Значение не найдено для \(course.id) в music")
                }
            }
        case .meditation:
            Database.database(url: .databaseURL).reference().child("courses").child(course.id).child("listenedCount").observeSingleEvent(of: .value) { snapshot in
                if let listenersCount = snapshot.value as? Int {
                    DispatchQueue.main.async {
                        self.listeners = listenersCount
                    }
                } else {
                    print("Значение не найдено для \(course.id) в meditation")
                }
            }
        case .story:
            Database.database(url: .databaseURL).reference().child("nightStories").child(course.id).child("listenedCount").observeSingleEvent(of: .value) { snapshot in
                if let listenersCount = snapshot.value as? Int {
                    DispatchQueue.main.async {
                        self.listeners = listenersCount
                    }
                } else {
                    print("Значение не найдено для \(course.id) в story")
                }
            }
        case .emergency:
            print("emergency")
            Database.database(url: .databaseURL).reference().child("emergencyMeditation").child(course.id).child("listenedCount").observeSingleEvent(of: .value) { snapshot in
                if let listenersCount = snapshot.value as? Int {
                    DispatchQueue.main.async {
                        self.listeners = listenersCount
                    }
                } else {
                    print("Значение не найдено для \(course.id) в emergency")
                }
            }
        }
    }
    
    func getLikesIn(course: CourseAndPlaylistOfDayModel, courseType: Types) {
        
        switch courseType {
        case .playlist:
            Database.database(url: .databaseURL).reference().child("music").child(course.id).child("likes").observe(.value) { snapshot in
                if let likesValue = snapshot.value as? Int {
                    DispatchQueue.main.async {
                        self.likes = likesValue
                    }
                } else {
                    print("Значение не найдено для \(course.id) в music")
                }
            }
        case .meditation:
            Database.database(url: .databaseURL).reference().child("courses").child(course.id).child("likes").observeSingleEvent(of: .value) { snapshot in
                if let likesValue = snapshot.value as? Int {
                    DispatchQueue.main.async {
                        self.likes = likesValue
                    }
                } else {
                    print("Значение не найдено для \(course.id) в meditation")
                }
            }
        case .story:
            Database.database(url: .databaseURL).reference().child("nightStories").child(course.id).child("likes").observeSingleEvent(of: .value) { snapshot in
                if let likesValue = snapshot.value as? Int {
                    DispatchQueue.main.async {
                        self.likes = likesValue
                    }
                } else {
                    print("Значение не найдено для \(course.id) в story")
                }
            }
        case .emergency:
            Database.database(url: .databaseURL).reference().child("emergencyMeditation").child(course.id).child("likes").observeSingleEvent(of: .value) { snapshot in
                if let likesValue = snapshot.value as? Int {
                    DispatchQueue.main.async {
                        self.likes = likesValue
                    }
                } else {
                    print("Значение не найдено для \(course.id) в emergency")
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
    
    func updateDisplayName(newDisplayName: String) {
        guard let user = Auth.auth().currentUser else {
            print("No user is signed in.")
            //completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user is signed in."]))
            return
        }
        
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = newDisplayName
        changeRequest.commitChanges { error in
            if let error = error {
                print("Error updating display name: \(error.localizedDescription)")
            } else {
                print("Display name updated successfully to \(newDisplayName)")
            }
            //completion(error)
        }
    }
    
    func changeEmail(newEmail: String) async throws {
        guard let user = Auth.auth().currentUser else {
            print("No user is signed in.")
            return
        }
        try await user.sendEmailVerification(beforeUpdatingEmail: newEmail)
    }
    
    func updatePassword(newPassword: String, currentPassword: String, completion: @escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
                    print("Пользователь не найден")
            completion(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No user is signed in."]))
                    return
                }

                // Для повторной аутентификации используем метод EmailAuthProvider
                let credential = EmailAuthProvider.credential(withEmail: user.email ?? "", password: currentPassword)

                user.reauthenticate(with: credential) { result, error in
                    if let error = error {
                        print("Ошибка аутентификации: \(error.localizedDescription)")
                        completion(error)
                        return
                    }

                    // Повторная аутентификация успешна, теперь можно обновить пароль
                    user.updatePassword(to: newPassword) { [weak self] error in
                        if let error = error {
                            print(error.localizedDescription)
                            completion(error)
                        } else {
                            print("Пароль успешно обновлен. Вы будете перенаправлены на экран входа.")
                            self?.authViewModel.signOut()
                        }
                    }
                }
    }
    
    
}
