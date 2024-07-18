//
//  MusicFileDataModel.swift
//  Relax
//
//  Created by Илья Кузнецов on 27.06.2024.
//

import Foundation
import Firebase

struct MusicFileDataModel: Identifiable, Codable {
    var id: String
    var name: String
    var url: String
    var listenedCount: Int
    var likes: Int
    var imageURL: String
}
