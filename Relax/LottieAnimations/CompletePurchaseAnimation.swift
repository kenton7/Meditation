//
//  CompletePurchaseAnimation.swift
//  Серотоника
//
//  Created by Илья Кузнецов on 25.08.2024.
//

import Foundation
import Lottie
import SwiftUI
import UIKit

struct CompletePurchaseAnimation: UIViewRepresentable {
    
    private let premiumAnimation: LottieAnimationView = {
       let premiuim = LottieAnimationView()
        premiuim.animation = LottieAnimation.named("CompletePurchaseAnimation")
        premiuim.translatesAutoresizingMaskIntoConstraints = false
        premiuim.contentMode = .scaleAspectFit
        premiuim.loopMode = .playOnce
        premiuim.animationSpeed = 0.6
        premiuim.play()
        return premiuim
    }()
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
        view.addSubview(premiumAnimation)
        NSLayoutConstraint.activate([
            premiumAnimation.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            premiumAnimation.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            premiumAnimation.heightAnchor.constraint(equalToConstant: 150),
            premiumAnimation.widthAnchor.constraint(equalToConstant: 150)
        ])
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}
