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
    @EnvironmentObject var authViewModel: AuthWithEmailViewModel
    @StateObject private var databaseVM = ChangeDataInDatabase()
    @EnvironmentObject var notificationsService: NotificationsService
    
    @State private var isLoading = true
    
    var body: some View {
        
        
        Group {
            if let isTutorialViewed = databaseVM.isTutorialViewed {
                if authViewModel.signedIn && isTutorialViewed {
                    CustomTabBar()
                        .navigationBarBackButtonHidden()
                } else {
                    NavigationStack {
                        OnboardingScreen()
                    }
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            authViewModel.signedIn = authViewModel.isUserLoggedIn
        }
        .task {
            guard let user = Auth.auth().currentUser else { return }
            await databaseVM.checkIfUserViewedTutorial(user: user)
        }
    }
}

