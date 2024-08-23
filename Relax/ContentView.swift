//
//  ContentView.swift
//  Relax
//
//  Created by Илья Кузнецов on 21.06.2024.
//

import SwiftUI
import CoreData
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var yandexViewModel = YandexAuthorization.shared
    @EnvironmentObject var databaseVM: ChangeDataInDatabase
    @EnvironmentObject var notificationsService: NotificationsService
    
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if isLoading {
                LoadingAnimation()
            } else {
                if authViewModel.signedIn && databaseVM.isTutorialViewed || yandexViewModel.isLoggedIn && databaseVM.isTutorialViewed {
                    CustomTabBar()
                        .navigationBarBackButtonHidden()
                } else {
                    NavigationStack {
                        OnboardingScreen()
                    }
                }
            }
        }
        .onAppear {
            authViewModel.signedIn = authViewModel.isUserLoggedIn
            if !authViewModel.signedIn {
                databaseVM.isTutorialViewed = false
            }
            if !yandexViewModel.isLoggedIn && !databaseVM.isTutorialViewed {
                isLoading = false
                Task {
                    if let userID = Auth.auth().currentUser?.uid {
                        await databaseVM.checkIfFirebaseUserViewedTutorial(userID: userID)
                    }
                }
            }
        }
        .onChange(of: yandexViewModel.clientID) { newValue in
            if !newValue.isEmpty {
                Task {
                    await databaseVM.checkIfFirebaseUserViewedTutorial(userID: newValue)
                    await MainActor.run {
                        self.isLoading = false
                    }
                }
            }
        }
        .onChange(of: yandexViewModel.isLoggedIn) { newValue in
            if !newValue {
                isLoading = false
            }
        }
        .onChange(of: databaseVM.isTutorialViewed) { newValue in
            print("onChange сработал, databaseVM.isTutorialViewed изменилось на \(newValue)")
        }
    }
}
