//
//  View+Extension.swift
//  Relax
//
//  Created by Илья Кузнецов on 26.07.2024.
//

import Foundation
import SwiftUI

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
    
    func getRootViewController() -> UIViewController? {
            guard let windowScene = UIApplication.shared.connectedScenes
                    .first as? UIWindowScene else {
                return nil
            }
            return windowScene.windows.first?.rootViewController
        }
}
