//
//  UserLearningAnimation.swift
//  Relax
//
//  Created by Илья Кузнецов on 25.06.2024.
//

import Foundation
import Lottie
import SwiftUI
import UIKit

struct UserLearningAnimation: UIViewRepresentable {
    
    private let userLearningAnimation: LottieAnimationView = {
       let animation = LottieAnimationView()
        animation.animation = LottieAnimation.named("UserLearningAnimation")
        animation.translatesAutoresizingMaskIntoConstraints = false
        animation.contentMode = .scaleAspectFit
        animation.loopMode = .loop
        animation.animationSpeed = 0.5
        animation.play()
        return animation
    }()
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
        view.addSubview(userLearningAnimation)
        NSLayoutConstraint.activate([
            userLearningAnimation.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userLearningAnimation.heightAnchor.constraint(equalToConstant: 300),
            userLearningAnimation.widthAnchor.constraint(equalToConstant: 300)
        ])
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}
