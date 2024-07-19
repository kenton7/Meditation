//
//  CoreDataService.swift
//  Relax
//
//  Created by Илья Кузнецов on 26.06.2024.
//

import Foundation
import CoreData
import SwiftUI

import CoreData

class CoreDataService {
    let viewContext: NSManagedObjectContext
    
    static let shared = CoreDataService()
    
    private init() {
        self.viewContext = PersistenceController.shared.container.viewContext
    }
    
    // Сохранение выбранных дней недели
    func saveSelectedDays(_ days: [Day], time: Date) {
        deleteAllDays()
        
        for day in days {
            let reminder = Reminder(context: viewContext)
            reminder.day = day.name
            reminder.time = time
            
            do {
                try viewContext.save()
            } catch {
                print("Failed to save selected days: \(error)")
            }
        }
    }
    
    // Загрузка выбранных дней недели
    func loadSelectedDays() -> [Day] {
        let fetchRequest: NSFetchRequest<Reminder> = Reminder.fetchRequest()
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            return results.map { reminder in
                return Day(name: reminder.day ?? "")
            }
        } catch {
            print("Failed to load selected days: \(error)")
            return []
        }
    }
    
    // Сохранение тем
    func saveTopic(_ topic: TopicsModel) {
        let topicEntity = Topic(context: viewContext)
        topicEntity.topicName = topic.name
        topicEntity.isSelected = topic.isSelected
        //topicEntity.image = topic.image
        // topicEntity.color = topic.color (если требуется сохранять цвет)
        
        do {
            try viewContext.save()
        } catch {
            print("Failed to save topic: \(error)")
        }
    }
    
    func deleteTopic(topic: TopicsModel) {
        let fetchRequest: NSFetchRequest<Topic> = Topic.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "topicName == %@", topic.name)
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            guard let topicToDelete = results.first else {
                print("Тема не найдена для удаления")
                return
            }
            
            viewContext.delete(topicToDelete)
            try viewContext.save()
            print("Тема \(topic.name) успешно удалена")
        } catch {
            print("Ошибка при удалении темы: \(error.localizedDescription)")
        }
    }
    
//    func loadTopics() -> [TopicsModel] {
//        let fetchRequest: NSFetchRequest<Topic> = Topic.fetchRequest()
//        
//        do {
//            let results = try viewContext.fetch(fetchRequest)
//            return results.map { topicEntity in
//                var color: Color?
//                if let colorData = topicEntity.color as Data?,
//                   let uiColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
//                    color = Color(uiColor)
//                }
//                
//                return TopicsModel(
//                    topicName: topicEntity.topicName ?? "",
//                    image: topicEntity.image,
//                    color: color,
//                    isSelected: topicEntity.isSelected
//                )
//            }
//        } catch {
//            print("Failed to load topics: \(error)")
//            return []
//        }
//    }

    
    private func deleteAllDays() {
        let fetchRequest: NSFetchRequest<Reminder> = Reminder.fetchRequest()
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            for reminder in results {
                viewContext.delete(reminder)
            }
            try viewContext.save()
        } catch {
            print("Failed to delete existing days: \(error)")
        }
    }
}




