//
//  LoadingAnimation.swift
//  Relax
//
//  Created by Илья Кузнецов on 11.08.2024.
//

import Foundation
import Lottie
import SwiftUI
import UIKit

struct LoadingAnimation: UIViewRepresentable {
    
    private let loadingAnimation: LottieAnimationView = {
       let animation = LottieAnimationView()
        animation.animation = LottieAnimation.named("LoadingAnimation")
        animation.translatesAutoresizingMaskIntoConstraints = false
        animation.contentMode = .scaleAspectFit
        animation.loopMode = .loop
        animation.animationSpeed = 0.5
        animation.play()
        return animation
    }()
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
        view.addSubview(loadingAnimation)
        NSLayoutConstraint.activate([
            loadingAnimation.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingAnimation.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingAnimation.heightAnchor.constraint(equalToConstant: 300),
            loadingAnimation.widthAnchor.constraint(equalToConstant: 300)
        ])
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}
