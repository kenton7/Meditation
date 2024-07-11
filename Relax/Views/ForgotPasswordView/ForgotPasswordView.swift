//
//  ForgotPasswordView.swift
//  Relax
//
//  Created by Илья Кузнецов on 21.06.2024.
//

import SwiftUI
import FirebaseAuth

struct ForgotPasswordView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var email: String = ""
    @EnvironmentObject private var authViewModel: AuthWithEmailViewModel
    @State private var hasSentRestorePassword = false
    
    var body: some View {
        VStack {
            Text("Введите вашу электронную почту, на которую зарегистрирован аккаунт")
                .padding()
                .font(.system(.title, design: .rounded, weight: .bold))
                .multilineTextAlignment(.center)
            Spacer()
            EmailFieldView("Email", email: $email)
            Spacer()
            Button(action: {
                authViewModel.restorePasswordWith(email: email) { success, error in
                    if success {
                        hasSentRestorePassword = true
                    } else {
                        let authErrorCode = AuthErrorCode(_nsError: error!)
                        print(authErrorCode.code)
                    }
                }
            }, label: {
                Text("Сбросить пароль")
                    .foregroundStyle(.white)
            })
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(UIColor(red: 142/255, green: 151/255, blue: 253/255, alpha: 1)))
            .clipShape(.rect(cornerRadius: 20))
            .padding()
            .disabled(email.isEmpty)
            .alert("На вашу почту были отправлены инструкции для сброса пароля. Пожалуйста, проверьте.", isPresented: $hasSentRestorePassword) {
                VStack {
                    Button("OK", role: .cancel) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ForgotPasswordView()
}
