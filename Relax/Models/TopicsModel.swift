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

extension TopicsModel {
    func getCourses() {
        Task {
            //await self.coursesVM.getCourses(isDaily: false)
            await self.coursesVM.getCoursesNew(isDaily: false, path: .allCourses)
        }
    }
}



