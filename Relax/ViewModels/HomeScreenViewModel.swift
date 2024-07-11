//
//  HomeScreenViewModel.swift
//  Relax
//
//  Created by Илья Кузнецов on 27.06.2024.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import SwiftUI

class HomeScreenViewModel: ObservableObject {
    
    let user = Auth.auth().currentUser
    private let calendar = Calendar.current
    private let currentDate = Date()
    var currentHour: Int {
        return calendar.component(.hour, from: currentDate)
    }
    @Published var greeting: String
    
    init() {
        self.greeting = "Привет, User"
        updateGreeting()
    }
    
    private func updateGreeting() {
        switch currentHour {
        case 0..<4:
            self.greeting = "Доброй ночи, \(user?.displayName ?? "User")"
        case 4..<12:
            self.greeting = "Доброе утро, \(user?.displayName ?? "User")"
        case 12..<18:
            self.greeting = "Добрый день, \(user?.displayName ?? "User")"
        case 18...23:
            self.greeting = "Добрый вечер, \(user?.displayName ?? "User")"
        default:
            self.greeting = "Привет, \(user?.displayName ?? "User")"
        }
    }
    
}
