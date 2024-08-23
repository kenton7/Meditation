//
//  MainScreen.swift
//  Relax
//
//  Created by Илья Кузнецов on 26.06.2024.
//

import SwiftUI
import FirebaseAuth

struct MainScreen: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var notificationsService: NotificationsService
    
    var body: some View {
        if viewModel.isUserLoggedIn {
            CustomTabBar()
        } else {
            OnboardingScreen()
        }
    }
}
