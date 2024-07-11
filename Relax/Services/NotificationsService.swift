//
//  NotificationsService.swift
//  Relax
//
//  Created by Илья Кузнецов on 26.06.2024.
//

import Foundation
import UserNotifications
import CoreData
import SwiftUI

class NotificationsService {
    
    static let shared = NotificationsService()
    private init() {}
    
    //@FetchRequest(sortDescriptors: []) var selectedDays: FetchedResults<Reminder>
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                
            } else if let error {
                print(error.localizedDescription)
            }
        }
    }
    
    func sendNotificationWithContent(title: String, subtitle: String?, body: String, sound: UNNotificationSound, selectedDays: [Day], selectedTime: Date) {
        let currentDate = Date()
        let content = UNMutableNotificationContent()
        var dateComponents = DateComponents()
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "E"
        let dayOfWeek = formatter.string(from: currentDate).uppercased()
        let hour = calendar.component(.hour, from: selectedTime)
        let minutes = calendar.component(.minute, from: selectedTime)
        
        dateComponents.hour = hour
        dateComponents.minute = minutes
        
        for day in selectedDays {
            if day.name == dayOfWeek {
                print(day.name)
                print(dayOfWeek)
                content.title = title
                if let subtitle {
                    content.subtitle = subtitle
                }
                content.sound = sound
                content.body = body
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request)
            }
        }
    }
    
}
