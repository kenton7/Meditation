//
//  RectKey.swift
//  Серотоника
//
//  Created by Илья Кузнецов on 08.09.2024.
//

import SwiftUI

struct RectKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
