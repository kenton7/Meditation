//
//  AuthWithEmail.swift
//  Relax
//
//  Created by Илья Кузнецов on 21.06.2024.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import UserNotifications

enum AuthorizationType {
    case emailPassword
    case yandexSDK
}

protocol Authable: AnyObject {
    func asyncRegisterWith(name: String, email: String, password: String) async throws
    func asyncLogInWith(email: String, password: String) async throws
    func restorePasswordWith(email: String, completion: @escaping ((Bool, NSError?) -> Void))
    func signOut()
    func deleteAccount()
}

final class AuthViewModel: ObservableObject, Authable {
    
    @Published var signedIn = false
    @Published var userID: String = ""
    private var handler: AuthStateDidChangeListenerHandle?
    
    public var isUserLoggedIn: Bool {
        return Auth.auth().currentUser != nil
    }
    
    func asyncRegisterWith(name: String, email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            await MainActor.run {
                //self.signedIn = true
                self.userID = result.user.uid
            }
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = name
            try await changeRequest.commitChanges()
            let userData = ["email": email, "name": name]
            try await Database.database(url: .databaseURL).reference().child("users").child(result.user.uid).setValue(userData)
        } catch {
            let authError = AuthErrorCode(rawValue: error._code)
            let errorMessage = authError?.errorMessage ?? "Произошла неизвестная ошибка."
            throw(NSError(domain: "", code: error._code, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
        }
    }
    
    func asyncLogInWith(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            await MainActor.run {
                self.signedIn = true
                self.userID = result.user.uid
            }
        } catch {
            print(error._code)
            let authError = AuthErrorCode(rawValue: error._code)
            let errorMessage = authError?.errorMessage ?? "Произошла неизвестная ошибка."
            throw(NSError(domain: "", code: error._code, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
        }
    }
    
    func restorePasswordWith(email: String, completion: @escaping ((Bool, NSError?) -> Void)) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if error != nil {
                DispatchQueue.main.async {
                    completion(false, error as NSError?)
                }
            } else {
                DispatchQueue.main.async {
                    completion(true, nil)
                }
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.signedIn = false
                self.userID = ""
                print("Пользователь вышел из системы. signedOut: \(self.signedIn), userID: \(self.userID)")
            }
        } catch {
            print("Ошибка при попытке выхода из аккаунта: \(error.localizedDescription)")
        }
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("User signed out")
    }
    
    func deleteAccount() {
        guard let user = Auth.auth().currentUser else { return }
        Database.database(url: .databaseURL).reference().child("users").child(user.uid).removeValue()
        Auth.auth().currentUser?.delete(completion: { error in
            if let error = error {
                print(error)
            } else {
                DispatchQueue.main.async {
                    self.signedIn = false
                    self.userID = ""
                }
            }
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        })
    }
}
