//
//  OnboardingAnimation.swift
//  Relax
//
//  Created by Илья Кузнецов on 21.06.2024.
//

import Foundation
import Lottie
import SwiftUI
import UIKit

struct OnboardingAnimation: UIViewRepresentable {
    
    private let onboardingAnimation: LottieAnimationView = {
       let animation = LottieAnimationView()
        animation.animation = LottieAnimation.named("OnboadringRelaxAnimation")
        animation.translatesAutoresizingMaskIntoConstraints = false
        animation.contentMode = .scaleAspectFit
        animation.loopMode = .loop
        animation.animationSpeed = 0.5
        animation.play()
        return animation
    }()
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
        view.addSubview(onboardingAnimation)
        NSLayoutConstraint.activate([
            onboardingAnimation.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            //onboardingAnimation.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            onboardingAnimation.heightAnchor.constraint(equalToConstant: 300),
            onboardingAnimation.widthAnchor.constraint(equalToConstant: 300)
        ])
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}
