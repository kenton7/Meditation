//
//  Color+Extensions.swift
//  Relax
//
//  Created by Илья Кузнецов on 29.06.2024.
//

import Foundation
import SwiftUI
import UIKit

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

extension UIColor {
    static let noThanksButtonColor: UIColor = .init(red: 63/255, green: 65/255, blue: 78/255, alpha: 1)
    static let defaultButtonColor: UIColor = .init(red: 142/255, green: 151/255, blue: 253/255, alpha: 1)
}
