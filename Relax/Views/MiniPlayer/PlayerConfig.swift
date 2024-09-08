//
//  PlayerConfig.swift
//  Серотоника
//
//  Created by Илья Кузнецов on 08.09.2024.
//

import SwiftUI

struct PlayerConfig: Equatable {
    var position: CGFloat = .zero
    var lastPosition: CGFloat = .zero
    var progress: CGFloat = .zero
    var selectedContentItem: Lesson?
    var showMiniPlayer: Bool = false
    
    mutating func resetPosition() {
        position = .zero
        lastPosition = .zero
        progress = .zero
    }
}

class PlayerConfig2: ObservableObject {
    @Published var position: CGFloat = .zero
    @Published var lastPosition: CGFloat = .zero
    @Published var progress: CGFloat = .zero
    @Published var selectedContentItem: Lesson?
    @Published var showMiniPlayer: Bool = false
    
    static let shared = PlayerConfig2()
    private init() {}
    
    func resetPosition() {
        position = .zero
        lastPosition = .zero
        progress = .zero
    }
}

