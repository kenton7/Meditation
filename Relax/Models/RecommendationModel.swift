//
//  RecommendationModel.swift
//  Relax
//
//  Created by Илья Кузнецов on 27.06.2024.
//

import Foundation

struct RecommendationModel: Codable {
    var name: String
    var type: String
    var imageURL: String
    var color: ButtonColor
    var isSelected: Bool?
}

