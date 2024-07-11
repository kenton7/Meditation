//
//  CoursesModel.swift
//  Relax
//
//  Created by Илья Кузнецов on 27.06.2024.
//

import Foundation

struct CoursesModel: Identifiable, Codable {
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
}
