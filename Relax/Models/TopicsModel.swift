//
//  TopicsModel.swift
//  Relax
//
//  Created by Илья Кузнецов on 25.06.2024.
//

import Foundation
import UIKit.UIImage
import SwiftUI
import CoreData

class TopicsModel: ObservableObject, Identifiable {
    var id: String
    var name: String
    var audioFemaleURL: String
    var audioMaleURL: String
    var imageURL: String
    var color: ButtonColor
    var duration: String
    var description: String
    var listenedCount: Int
    var type: Types
    @Published var isSelected = false
    
    @StateObject private var coursesVM = CoursesViewModel()
    
    init(id: String, name: String, audioFemaleURL: String, audioMaleURL: String, imageURL: String, color: ButtonColor, duration: String, description: String, listenedCount: Int, type: Types) {
        self.id = id
        self.name = name
        self.audioFemaleURL = audioFemaleURL
        self.audioMaleURL = audioMaleURL
        self.imageURL = imageURL
        self.color = color
        self.duration = duration
        self.description = description
        self.listenedCount = listenedCount
        self.type = type
    }
}

//extension TopicsModel {
//    var imageView: UIImage {
//        if let data = image, let image = UIImage(data: data) {
//            return image
//        } else {
//            return UIImage(systemName: "photo")!
//        }
//    }
//}

extension TopicsModel {
    func getCourses() {
        Task.detached {
            await self.coursesVM.getCourses(isDaily: false)
        }
    }
}

//extension TopicsModel {
//    static func getTopics() -> [TopicsModel] {
//        //128/255, green: 138/255, blue: 255/255, alpha: 1
//        
//        let reduceStress = TopicsModel(topicName: "Избавиться от стресса", image: UIImage(resource: .reduceStress).pngData()!, color: .init(red: 128, green: 138, blue: 255), isSelected: false, imageURL: "https://firebasestorage.googleapis.com/v0/b/relax-8e1d3.appspot.com/o/ReduceStress.png?alt=media&token=5fe6a575-d0b6-40ef-b0b4-fc1ae3e9d015")
//        
//        //red: 250/255, green: 110/255, blue: 90/255
//        let improvePerformance = TopicsModel(topicName: "Улучшить \nпроизводительность", image: UIImage(resource: .improvePerformance).pngData()!, color: .init(red: 250, green: 110, blue: 90), isSelected: false, imageURL: "https://firebasestorage.googleapis.com/v0/b/relax-8e1d3.appspot.com/o/ImprovePerformance.png?alt=media&token=e11c811e-64aa-41b4-91ea-2f62a99890ec")
//        
//        //red: 254/255, green: 177/255, blue: 143/255
//        let increaseHappiness = TopicsModel(topicName: "Быть счастливее", image: UIImage(resource: .increaseHappiness).pngData()!, color: .init(red: 254, green: 177, blue: 143), isSelected: false, imageURL: "https://firebasestorage.googleapis.com/v0/b/relax-8e1d3.appspot.com/o/IncreaseHappiness.png?alt=media&token=af8ad951-74b1-4829-9efb-f7cf7f07b558")
//        
//        //red: 255/255, green: 207/255, blue: 134/255
//        let reduceAnxiety = TopicsModel(topicName: "Уменьшить тревожность", image: UIImage(resource: .reduceAnxiety).pngData()!, color: .init(red: 255, green: 207, blue: 134), isSelected: false, imageURL: "https://firebasestorage.googleapis.com/v0/b/relax-8e1d3.appspot.com/o/ReduceAnxiety.png?alt=media&token=8180d55c-47d5-42c5-9198-c5b1af264073")
//        
//        //red: 108/255, green: 178/255, blue: 142/255
//        let personalGrowth = TopicsModel(topicName: "Саморазвитие", image: UIImage(resource: .personalGrowth).pngData()!, color: .init(red: 108, green: 178, blue: 142), isSelected: false, imageURL: "https://firebasestorage.googleapis.com/v0/b/relax-8e1d3.appspot.com/o/PersonalGrowth.png?alt=media&token=52c0938a-1a48-48bf-9945-88b3f5a9fe52")
//        
//        //red: 63/255, green: 65/255, blue: 78/255
//        let betterSleep = TopicsModel(topicName: "Улучшить сон", image: UIImage(resource: .betterSleep).pngData()!, color: .init(red: 63, green: 65, blue: 78), isSelected: false, imageURL: "https://firebasestorage.googleapis.com/v0/b/relax-8e1d3.appspot.com/o/BetterSleep.png?alt=media&token=b3fa1ead-3109-485a-8a5e-2dd8f37607d9")
//        
//        //red: 217/255, green: 165/255, blue: 181/255
//        let selfEsteem = TopicsModel(topicName: "Повысить самооценку", image: UIImage(resource: .selfEsteem).pngData()!, color: .init(red: 217, green: 165, blue: 181), isSelected: false, imageURL: "https://firebasestorage.googleapis.com/v0/b/relax-8e1d3.appspot.com/o/SelfEsteem.png?alt=media&token=cc045f1e-685c-44dc-9bf9-4ec1f7f9aa97")
//        
//        //ed: 142/255, green: 151/255, blue: 253/255
//        let stopAlcohol = TopicsModel(topicName: "Избавиться от \nвредных привычек", image: UIImage(resource: .stopAlcohol).pngData()!, color: .init(red: 142, green: 151, blue: 253), isSelected: false, imageURL: "https://firebasestorage.googleapis.com/v0/b/relax-8e1d3.appspot.com/o/StopAclohol.png?alt=media&token=32754f07-a0e3-4b40-91e3-3b49f3129c2c")
//        return [reduceStress, improvePerformance, increaseHappiness, reduceAnxiety, personalGrowth, betterSleep, selfEsteem, stopAlcohol]
//        
//    }
//}

//extension TopicsModel {
//    func toDictionary() -> [String: Any] {
//        var dict: [String: Any] = [
//            "topicName": topicName,
//            "isSelected": isSelected
//        ]
//        
//        if let image = image {
//            dict["image"] = image.base64EncodedString()
//        }
//        
//        if let color = color {
//            // Convert Color to Data and then to Base64 String
//            if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: UIColor(color), requiringSecureCoding: false) {
//                dict["color"] = colorData.base64EncodedString()
//            }
//        }
//        
//        return dict
//    }
//}


