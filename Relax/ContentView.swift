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
    
    var body: some View {
        Group {
            if authViewModel.signedIn /*&& !authViewModel.userID.isEmpty*/ {
                //NavigationStack {
                    MainScreen()
                //}
            } else {
                NavigationStack {
                    OnboardingScreen()
                }
            }
        }
        .onAppear {
            authViewModel.signedIn = authViewModel.isUserLoggedIn
        }
    }
}

