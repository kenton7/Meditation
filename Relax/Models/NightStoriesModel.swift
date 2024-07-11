//
//  NightStoriesModel.swift
//  Relax
//
//  Created by Илья Кузнецов on 29.06.2024.
//

import Foundation

struct NightStoriesModel: Codable {
    var name: String
    var imageURL: String
    var audioFemaleURL: String
    var audioMaleURL: String
    var color: ButtonColor
    var id: String
    var listenedCount: Int
    var likes: Int
}
