//
//  NavigationService.swift
//  Серотоника
//
//  Created by Илья Кузнецов on 07.09.2024.
//

import Foundation
import SwiftUI

class NavigationService: ObservableObject {
    @Published var path = NavigationPath()
    
    func popToRoot() {
        path.removeLast(path.count) // Удаляем все экраны, чтобы вернуться к корневому
    }
}
