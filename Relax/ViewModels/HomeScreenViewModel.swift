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

final class HomeScreenViewModel: ObservableObject {
    
    let user = Auth.auth().currentUser
    let yandexViewModel = YandexAuthorization.shared
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
            greeting = "Доброй ночи, \(user?.displayName ?? yandexViewModel.userName ?? "User")!"
            secondaryGreeting = "Желаем вам сладких снов и крепкого отдыха."
        case 4..<12:
            greeting = "Доброе утро, \(user?.displayName ?? yandexViewModel.userName ?? "User")!"
            secondaryGreeting = "Пусть этот день принесёт вам радость и вдохновение."
        case 12..<18:
            greeting = "Добрый день, \(user?.displayName ?? yandexViewModel.userName ?? "User")!"
            secondaryGreeting = "Желаем вам продуктивного и приятного дня."
        case 18...23:
            greeting = "Добрый вечер, \(user?.displayName ?? yandexViewModel.userName ?? "User")!"
            self.secondaryGreeting = "Пусть ваш вечер будет спокойным и уютным."
        default:
            greeting = "Привет, \(user?.displayName ?? yandexViewModel.userName ?? "User")!"
            secondaryGreeting = ""
        }
    }
    
}
