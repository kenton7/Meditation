//
//  ProfileScreen.swift
//  Relax
//
//  Created by Илья Кузнецов on 02.07.2024.
//

import SwiftUI
import FirebaseAuth
import FirebaseCore

struct ProfileScreen: View {
    
    @StateObject private var authViewModel = AuthWithEmailViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                Button("Выйти") {
                    authViewModel.signOut()
                }
            }
        }
    }
}
    
    #Preview {
        ProfileScreen()
    }
