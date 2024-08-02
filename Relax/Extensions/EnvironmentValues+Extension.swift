//
//  EnvironmentValues+Extension.swift
//  Relax
//
//  Created by Илья Кузнецов on 01.08.2024.
//

import Foundation
import SwiftUI

extension EnvironmentValues {
    var currentTab: Binding<TabbedItems> {
        get { self[CurrentTabKey.self] }
        set { self[CurrentTabKey.self] = newValue }
    }
}
