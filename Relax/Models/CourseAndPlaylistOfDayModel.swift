//
//  CourseAndPlaylistOfDay.swift
//  Relax
//
//  Created by Илья Кузнецов on 27.06.2024.
//

import Foundation

enum Types: String, Codable {
    case playlist = "ПЛЕЙЛИСТ"
    case meditation = "МЕДИТАЦИЯ"
    case story = "ИСТОРИЯ"
}

struct CourseAndPlaylistOfDayModel: Identifiable, Codable {
    var id: String
    var name: String
    var imageURL: String
    var color: ButtonColor
    var duration: String
    var description: String
    var listenedCount: Int
    var type: Types
    var isDaily: Bool
    var likes: Int
    var genre: String?
    var isLiked: Bool?
    //var lessons: [Lesson]
}

struct ButtonColor: Codable {
    var red: Int
    var green: Int
    var blue: Int
}

struct Lesson: Codable {
    var audioMaleURL: String
    var audioFemaleURL: String
    var name: String
    let duration: String
}
