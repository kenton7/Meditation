//
//  YandexLoginButton.swift
//  Relax
//
//  Created by Илья Кузнецов on 15.08.2024.
//

import SwiftUI
import YandexLoginSDK

struct YandexLoginButton: UIViewControllerRepresentable {
    @ObservedObject var viewModel: YandexAuthorization

    func makeUIViewController(context: Context) -> some UIViewController {
        return UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        DispatchQueue.main.async {
            do {
                try YandexLoginSDK.shared.authorize(with: uiViewController, customValues: nil, authorizationStrategy: .webOnly)
            } catch {
                print("Ошибка запуска авторизации Яндекс: \(error.localizedDescription)")
            }
        }
    }
}
