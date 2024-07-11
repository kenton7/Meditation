//
//  AVPlayer+Extansion.swift
//  Relax
//
//  Created by Илья Кузнецов on 01.07.2024.
//

import Foundation
import AVFoundation

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
