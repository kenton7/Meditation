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
    
    @Published var greeting: String = ""
    @Published var secondaryGreeting: String = ""
    
    init() {
        updateGreeting()
    }
    
    func updateGreeting() {
        switch currentHour {
        case 0..<4:
            self.greeting = "Доброй ночи, \(user?.displayName ?? "User")!"
            self.secondaryGreeting = "Желаем вам сладких снов и крепкого отдыха."
        case 4..<12:
            self.greeting = "Доброе утро, \(user?.displayName ?? "User")!"
            self.secondaryGreeting = "Пусть этот день принесёт вам радость и вдохновение."
        case 12..<18:
            self.greeting = "Добрый день, \(user?.displayName ?? "User")!"
            self.secondaryGreeting = "Желаем вам продуктивного и приятного дня."
        case 18...23:
            self.greeting = "Добрый вечер, \(user?.displayName ?? "User")!"
            self.secondaryGreeting = "Пусть ваш вечер будет спокойным и уютным."
        default:
            self.greeting = "Привет, \(user?.displayName ?? "User")!"
            self.secondaryGreeting = ""
        }
    }
    
}
