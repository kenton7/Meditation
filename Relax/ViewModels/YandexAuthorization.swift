//
//  YandexAuthorization.swift
//  Relax
//
//  Created by Илья Кузнецов on 15.08.2024.
//

import Foundation
import YandexLoginSDK
import UserNotifications
import FirebaseDatabase

final class YandexAuthorization: NSObject, ObservableObject, YandexLoginSDKObserver {
    @Published var isLoggedIn = false
    @Published var userName: String?
    @Published var userInfo: YandexUserInfo?
    @Published var clientID: String = ""
    @Published var userToken: String?
    @Published var isViewed = false
    private var databaseVM: ChangeDataInDatabase
    private var notificationsService = NotificationsService.shared
    
    public var isUserLoggedWithYandex: Bool {
        return userInfo != nil
    }
    
    static let shared = YandexAuthorization(databaseVM: ChangeDataInDatabase.shared)
    
    private var authViewModel = AuthViewModel()
    
    //static let shared = YandexAuthorization()
    
//    private override init() {
//        super.init()
//        YandexLoginSDK.shared.add(observer: self)
//        //removeToken()
//        checkIfLoggedIn()
//    }
    
    private init(databaseVM: ChangeDataInDatabase) {
            self.databaseVM = databaseVM
            super.init()
            // Пример кода, который инициализирует объект
            YandexLoginSDK.shared.add(observer: self)
            checkIfLoggedIn()
        }
    
    deinit {
        YandexLoginSDK.shared.remove(observer: self)
    }
    
    func logout() {
        do {
            try YandexLoginSDK.shared.logout()
            removeToken()
            DispatchQueue.main.async {
                self.databaseVM.isTutorialViewed = false
                self.isLoggedIn = false
            }
            userName = nil
            clientID = ""
            userInfo = nil
            notificationsService.stopAllPendingNotifications()
        } catch {
            print("error yandex logout: \(error)")
        }
    }
    
//    func deleteYandexAccount() async {
//        do {
//            try YandexLoginSDK.shared.logout()
//            removeToken()
//            try await Database.database(url: .databaseURL).reference().child("users").child(clientID).child("isTutorialViewed").setValue(false)
//            await databaseVM.checkIfFirebaseUserViewedTutorial(userID: clientID)
//            try await Database.database(url: .databaseURL).reference().child("users").child(clientID).removeValue()
//            await MainActor.run {
//                self.databaseVM.isTutorialViewed = false
//                self.isLoggedIn = false
//                self.userName = nil
//                self.clientID = ""
//                self.userInfo = nil
//            }
//            notificationsService.stopAllPendingNotifications()
//        } catch {
//            print("error yandex deleting account: \(error)")
//        }
//    }
    
    func deleteYandexAccount() async {
        //checkIfLoggedIn()
        removeToken()
        do {
            try YandexLoginSDK.shared.logout()
            //removeToken()
            
            // Убедитесь, что `isLoggedIn` становится `false`
            await MainActor.run {
                self.isLoggedIn = false
                self.databaseVM.isTutorialViewed = false
                print("User logged out. isLoggedIn = \(self.isLoggedIn)")
            }
            
            try await Database.database(url: .databaseURL).reference().child("users").child(clientID).removeValue()
            
            await MainActor.run {
                self.userName = nil
                self.clientID = ""
                self.userInfo = nil
                print("Account deleted. Navigating to OnboardingScreen.")
            }
            
            notificationsService.stopAllPendingNotifications()
        } catch {
            print("Error while deleting Yandex account: \(error)")
        }
    }


    
    func checkIfLoggedIn() {
        if let token = UserDefaults.standard.string(forKey: "YandexToken") {
            print("yandex token: \(token)")
            self.userToken = token
            self.isLoggedIn = true

            Task {
                do {
                    let yandexUser = try await fetchUserInfo(with: token)
                    
                    if let clientID = yandexUser.client_id {
                        await databaseVM.checkIfFirebaseUserViewedTutorial(userID: clientID)
                        await MainActor.run {
                            self.clientID = clientID
                            self.userName = yandexUser.first_name
                            self.userInfo = yandexUser
                        }
                    }
                    //await databaseVM.checkIfUserViewedTutorial(userID: clientID)
                    notificationsService.rescheduleNotifications()
                    
                } catch {
                    await MainActor.run {
                        self.isLoggedIn = false
                    }
                    print("Error fetching Yandex user info: \(error)")
                }
            }
            
        } else {
            self.isLoggedIn = false
            self.databaseVM.isTutorialViewed = false
            print("User is not logged in")
        }
    }

    
    private func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "YandexToken")
    }

    private func loadToken() -> String? {
        return UserDefaults.standard.string(forKey: "YandexToken")
    }

    private func removeToken() {
        UserDefaults.standard.removeObject(forKey: "YandexToken")
    }
    
    func didFinishLogin(with result: Result<LoginResult, any Error>) {
        switch result {
        case .success(let userData):
            self.userToken = userData.token
            saveToken(userData.token)
            notificationsService.rescheduleNotifications()

            Task {
                do {
                    let yandexUser = try await self.fetchUserInfo(with: userData.token)
                    
                    if let clientID = yandexUser.client_id {
                        //self.isViewed = await databaseVM.checkIfUserViewedTutorial(userID: clientID)
                        
                        await MainActor.run {
                            self.clientID = clientID
                            self.userInfo = yandexUser
                            self.userName = self.userInfo?.first_name
                            self.isLoggedIn = true
                            print(self.isLoggedIn)
                        }
                        
                        // Проверка, просмотрел ли пользователь туториал
                        //await databaseVM.checkIfUserViewedTutorial(userID: clientID)
                        try await Database.database(url: .databaseURL).reference().child("users").child(clientID).child("name").setValue(userName)
                        try await Database.database(url: .databaseURL).reference().child("users").child(clientID).child("email").setValue(userInfo?.emails)
                        try await Database.database(url: .databaseURL).reference().child("users").child(clientID).child("phone").setValue(userInfo?.default_phone.number)
                    }
                } catch {
                    print("Error fetching Yandex user info: \(error)")
                }
            }
            
        case .failure(let error):
            print("error when finish login yandex: \(error)")
        }
    }



    
    // Функция для получения информации о пользователе
    func fetchUserInfo(with accessToken: String) async throws -> YandexUserInfo {
        let urlString = "https://login.yandex.ru/info?format=json"
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("OAuth \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let userInfo = try JSONDecoder().decode(YandexUserInfo.self, from: data)
        print("USER: \(userInfo)")
        return userInfo
    }
}
