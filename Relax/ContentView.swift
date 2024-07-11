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
    @Environment(\.managedObjectContext) private var managedObjectContext
    
    var body: some View {
        NavigationStack {
            if authViewModel.signedIn && !authViewModel.userID.isEmpty {
                MainScreen()
            } else {
                OnboardingScreen()
            }
        }
        .onAppear {
            authViewModel.signedIn = authViewModel.isUserLoggedIn
            print("onAppear - signedIn: \(authViewModel.signedIn), userID: \(authViewModel.userID)")
        }
        .onChange(of: authViewModel.signedIn) { signedIn in
            print("signedIn changed: \(signedIn)")
        }
    }
}
