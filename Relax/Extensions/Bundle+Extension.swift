//
//  Bundle+Extension.swift
//  Серотоника
//
//  Created by Илья Кузнецов on 28.08.2024.
//

import Foundation

import Foundation

extension Bundle {
    var appVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    var appBuild: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
}
