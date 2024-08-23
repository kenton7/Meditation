//
//  LoadingAnimationButton.swift
//  Relax
//
//  Created by Илья Кузнецов on 11.08.2024.
//

import Foundation
import Lottie
import SwiftUI
import UIKit

struct LoadingAnimationButton: UIViewRepresentable {
    
    private let loadingAnimation: LottieAnimationView = {
        let animation = LottieAnimationView()
        animation.animation = LottieAnimation.named("LoadingAnimationWhenButtonPressed")
        animation.translatesAutoresizingMaskIntoConstraints = false
        animation.contentMode = .scaleAspectFit
        animation.loopMode = .loop
        animation.animationSpeed = 0.8
        animation.play()
        return animation
    }()
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
        view.addSubview(loadingAnimation)
        NSLayoutConstraint.activate([
            loadingAnimation.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingAnimation.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingAnimation.heightAnchor.constraint(equalToConstant: 50),
            loadingAnimation.widthAnchor.constraint(equalToConstant: 50)
        ])
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}
