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

class AuthWithEmailViewModel: ObservableObject {
    
    @Published var signedIn = false
    @Published var userID: String = ""
    private var handler: AuthStateDidChangeListenerHandle?
    
    public var isUserLoggedIn: Bool {
        return Auth.auth().currentUser != nil
    }
    
    init() {
        self.handler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.userID = user?.uid ?? ""
                self?.signedIn = user != nil
                print("userID \(self?.userID ?? ""), signedIn: \(self?.signedIn ?? false)")
            }
        }
    }
    
    func asyncRegisterWith(name: String, email: String, password: String) async throws -> UserModel? {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = name
            try await changeRequest.commitChanges()
            let userData = ["email": email, "name": name]
            try await Database.database(url: String.databaseURL).reference().child("users").child(result.user.uid).setValue(userData)
            await MainActor.run {
                self.signedIn = true
                self.userID = result.user.uid
            }
            return UserModel(user: result.user)
        } catch {
            let errorCodes = AuthErrorCode(_nsError: error as NSError)
            let customError: NSError
            
            switch errorCodes.code {
            case .invalidEmail:
                customError = NSError(domain: "FirebaseAuth",
                                      code: errorCodes.errorCode,
                                      userInfo: [NSLocalizedDescriptionKey: "Введён некорректный email."])
            case .emailAlreadyInUse:
                customError = NSError(domain: "FirebaseAuth",
                                      code: errorCodes.errorCode,
                                      userInfo: [NSLocalizedDescriptionKey: "Пользователь с таким email уже зарегистрирован."])
            case .weakPassword:
                customError = NSError(domain: "FirebaseAuth",
                                      code: errorCodes.errorCode,
                                      userInfo: [NSLocalizedDescriptionKey: "Пароль должен быть длиной минимум в 6 символов."])
            default:
                customError = NSError(domain: "FirebaseAuth",
                                      code: errorCodes.errorCode,
                                      userInfo: [NSLocalizedDescriptionKey: "Неизвестная ошибка: \(error.localizedDescription)"])
            }
            throw customError
        }
    }
    
    func asyncLogInWith(email: String, password: String) async throws -> UserModel? {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            await MainActor.run {
                self.signedIn = true
                self.userID = result.user.uid
            }
            print("User logged in with ID: \(userID)")
            return UserModel(user: result.user)
        } catch {
            let errorCodes = AuthErrorCode(_nsError: error as NSError)
            let customError: NSError
            
            switch errorCodes.code {
            case .invalidEmail:
                customError = NSError(domain: "FirebaseAuth",
                                      code: errorCodes.errorCode,
                                      userInfo: [NSLocalizedDescriptionKey: "Введён неверный email."])
            case .wrongPassword:
                customError = NSError(domain: "FirebaseAuth",
                                      code: errorCodes.errorCode,
                                      userInfo: [NSLocalizedDescriptionKey: "Введён неверный пароль."])
            case .userNotFound:
                customError = NSError(domain: "FirebaseAuth",
                                      code: errorCodes.errorCode,
                                      userInfo: [NSLocalizedDescriptionKey: "Пользователь не найден."])
            case .invalidCredential:
                customError = NSError(domain: "FirebaseAuth",
                                      code: errorCodes.errorCode,
                                      userInfo: [NSLocalizedDescriptionKey: "Пользователь не найден."])
            default:
                print(error)
                customError = NSError(domain: "FirebaseAuth",
                                      code: errorCodes.errorCode,
                                      userInfo: [NSLocalizedDescriptionKey: "Неверный email или пароль."])
            }
            throw customError
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
                print("Пользователь вышел из системы. signedIn: \(self.signedIn), userID: \(self.userID)")
            }
        } catch {
            print("Ошибка при попытке выхода из аккаунта: \(error.localizedDescription)")
        }
        print("User signed out")
    }
}
