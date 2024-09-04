//
//  AuthErrorCode+Extension.swift
//  Relax
//
//  Created by Илья Кузнецов on 24.06.2024.
//

import FirebaseAuth

extension AuthErrorCode {
    var errorMessage: String {
        switch self {
        case .emailAlreadyInUse:
            return "Пользователь с таким email уже зарегистрирован в системе."
        case .userNotFound:
            return "Аккаунт с такими данными не найден."
        case .userDisabled:
            return "Ваш аккаунт заблокирован. \nПожалуйста, свяжитесь со службой поддержки: serotonika.app@gmail.com."
        case .invalidEmail, .invalidSender, .invalidRecipientEmail:
            return "Введите корректный email."
        case .networkError:
            return "Ошибка сети. Пожалуйста, повторите попытку."
        case .weakPassword:
            return "Ваш пароль слишком слабый. \nПароль должен иметь не менее 6 символов."
        case .wrongPassword:
            return "Введён неверный пароль. \nПожалуйста, повторите попытку или нажмите на кнопку «Забыли пароль»."
        case .invalidCredential:
            return "Введён неверный email или пароль. \nПожалуйста, повторите попытку."
        case .tooManyRequests:
            return "Слишком много неуспешных попыток. \nПовторите через некоторое время."
        default:
            return "Произошла неизвестная ошибка."
        }
    }
}
