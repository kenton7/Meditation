//
//  MainScreen.swift
//  Relax
//
//  Created by Илья Кузнецов on 26.06.2024.
//

import SwiftUI
import FirebaseAuth

struct MainScreen: View {
    
    @StateObject private var viewModel = AuthWithEmailViewModel()
    
    var body: some View {
        NavigationStack {
            if viewModel.isUserLoggedIn, !viewModel.userID.isEmpty {
                CustomTabBar()
            } else {
                OnboardingScreen()
            }
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    return MainScreen()
}
