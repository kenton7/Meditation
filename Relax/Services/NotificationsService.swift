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

class NotificationsService: ObservableObject {
    
    static let shared = NotificationsService()
    private init() {}
        
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                UserDefaults.standard.set(true, forKey: "isNotificationsOn")
            } else if let error {
                print(error.localizedDescription)
                UserDefaults.standard.set(false, forKey: "isNotificationsOn")
            }
        }
    }
    
    func sendNotificationWithContent(title: String, subtitle: String?, body: String, sound: UNNotificationSound, selectedDays: [Day], selectedTime: Date) {
        let content = UNMutableNotificationContent()
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: selectedTime)
        let minutes = calendar.component(.minute, from: selectedTime)
        
        for day in selectedDays {
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minutes
            dateComponents.weekday = day.index  // Предполагается, что day.index соответствует порядку дней недели в календаре (1 = воскресенье, 2 = понедельник, и т.д.)
            
            content.title = title
            if let subtitle = subtitle {
                content.subtitle = subtitle
            }
            content.sound = sound
            content.body = body
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            
            // Добавление уведомления в центр уведомлений
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Ошибка при добавлении уведомления: \(error.localizedDescription)")
                } else {
                    print("Уведомление добавлено для дня \(day.name) в \(hour):\(minutes)")
                }
            }
        }
    }

    
    func rescheduleNotifications() {
        // Пример данных, которые нужно запланировать
        @FetchRequest(sortDescriptors: []) var savedDays: FetchedResults<Reminder>
        let title = "Медитация ждет вас!"
        let subtitle: String? = nil
        let body = "Найдите спокойное место и начните свою практику."
        var selectedDays = [Day]()
        
        savedDays.forEach {
            selectedDays.append(.init(name: $0.day ?? "", isSelected: $0.isSelected, index: Int($0.index)))
            print(selectedDays)
            sendNotificationWithContent(title: title, subtitle: subtitle, body: body, sound: .default, selectedDays: selectedDays, selectedTime: $0.time ?? Date())
        }
    }
    
    func stopAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
