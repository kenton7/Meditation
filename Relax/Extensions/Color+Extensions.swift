//
//  Color+Extensions.swift
//  Relax
//
//  Created by Илья Кузнецов on 29.06.2024.
//

import Foundation
import SwiftUI

extension Color {
    func toData() -> Data? {
        guard let components = UIColor(self).cgColor.components else {
            return nil
        }
        let red = Float(components[0])
        let green = Float(components[1])
        let blue = Float(components[2])
        let alpha = Float(components[3])
        
        return try? JSONEncoder().encode([red, green, blue, alpha])
    }
    
    static func fromData(_ data: Data) -> Color? {
        guard let components = try? JSONDecoder().decode([Float].self, from: data) else {
            return nil
        }
        return Color(
            red: Double(components[0]),
            green: Double(components[1]),
            blue: Double(components[2]),
            opacity: Double(components[3])
        )
    }
}
