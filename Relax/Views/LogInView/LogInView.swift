//
//  LogInView.swift
//  Relax
//
//  Created by Илья Кузнецов on 21.06.2024.
//

import SwiftUI
import FirebaseAuth
import YandexLoginSDK
import AuthenticationServices
import FirebaseDatabase

struct LogInView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var isLogIn = false
    @State private var isForgotPasswordPressed = false
    @State private var errorMessage: String?
    @State private var userID: String?
    @State private var userModel: UserModel?
    @State private var isLogining = false
    @StateObject private var databaseVM = ChangeDataInDatabase.shared
    @EnvironmentObject var notificationsService: NotificationsService
    @EnvironmentObject private var yandexViewModel: YandexAuthorization
    private let locale = Locale.current
    @Environment(\.colorScheme) private var scheme
    @State private var isViewed = false
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Image("LoginBackground").ignoresSafeArea()
                    Spacer()
                }
                VStack {
                    Spacer()
                    Text("C возвращением!")
                        .font(.system(.title, design: .rounded, weight: .bold))
                    
                    Button {
                        if let rootViewController = getRootViewController() {
                            do {
                                isLogining = true
                                try YandexLoginSDK.shared.authorize(with: rootViewController,
                                                                    customValues: nil,
                                                                    authorizationStrategy: .default)
                            } catch {
                                print("Ошибка запуска авторизации: \(error.localizedDescription)")
                                isLogining = false
                            }
                        }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.black)
                            HStack {
                                Image("Yandex")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                Text("Войти с Яндекс ID")
                                    .foregroundStyle(.white)
                                    .bold()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .padding()
                    .clipShape(.rect(cornerRadius: 16))
                    
                    //Кнопка войти через Apple. НЕ должна быть доступна для пользователей из РФ
                    if locale.identifier == "ru_RU" {
                        SignInWithAppleButton(.signIn) { request in
                            isLogining = true
                            request.requestedScopes = [.fullName, .email]
                            request.nonce = viewModel.currentNonce
                        } onCompletion: { result in
                            switch result {
                            case .success(let authorization):
                                Task {
                                    await viewModel.signInWithApple(authorization)
                                    //await databaseVM.checkIfFirebaseUserViewedTutorial(userID: viewModel.userID)
//                                    await MainActor.run {
//                                        self.isLogIn = true
//                                    }
//                                    if let userID = Auth.auth().currentUser?.uid {
//                                        print("userID after Sign in With Apple: \(userID)")
//                                        await databaseVM.checkIfFirebaseUserViewedTutorial(userID: userID)
////                                        try await Database.database(url: .databaseURL).reference().child("users").child(userID).child("email").setValue(viewModel.appleIDEmail)
//                                        await MainActor.run {
//                                            self.isLogIn = true
//                                        }
//                                    }
                                }
                            case .failure(let error):
                                errorMessage = error.localizedDescription
                                isLogining = false
                                self.isLogIn = false
                            }
                        }
                        .overlay {
                            ZStack {
                                Capsule()
                                    .clipShape(.rect(cornerRadius: 16))
                                HStack {
                                    Image(systemName: "applelogo")
                                    Text("Вход с Apple")
                                        .bold()
                                }
                                .foregroundStyle(scheme == .dark ? .black : .white)
                            }
                            .allowsHitTesting(false)
                        }
                        .clipShape(.rect(cornerRadius: 16))
                        .frame(height: 56)
                        .frame(maxWidth: .infinity)
                        .padding()
                    }

                    Divider()
                    
                    Text("ИЛИ ВОЙТИ С ПОМОЩЬЮ EMAIL")
                        .font(.system(size: 15))
                        .foregroundStyle(.gray)
                        .padding()
                    Spacer()
                    
                    VStack {
                        EmailFieldView("Email", email: $email)
                        PasswordFieldView("Пароль", text: $password)
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .padding(.horizontal)
                                .bold()
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    Spacer()
                    Button(action: {
                        isLogining = true
                        errorMessage = nil
                        Task.detached {
                            do {
                                try await viewModel.asyncLogInWith(email: email, password: password)
                                if let userID = Auth.auth().currentUser?.uid {
                                    await databaseVM.checkIfFirebaseUserViewedTutorial(userID: userID)
                                }
                                await MainActor.run {
                                    isLogining = false
                                    self.errorMessage = nil
                                    withAnimation {
                                        isLogIn = true
                                    }
                                }
                            } catch {
                                await MainActor.run {
                                    self.errorMessage = "\(error.localizedDescription)"
                                    self.isLogining = false
                                }
                            }
                        }
                    }, label: {
                        if isLogining {
                            LoadingAnimationButton()
                                .frame(width: 40, height: 40)
                        } else {
                            Text("Войти")
                                .foregroundStyle(.white)
                        }
                    })
                    .padding()
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(uiColor: .defaultButtonColor))
                    .clipShape(.rect(cornerRadius: 20))
                    .padding()
                    .disabled(email.isEmpty)
                    .disabled(password.isEmpty)
                    Button(action: {
                        withAnimation {
                            isForgotPasswordPressed = true
                        }
                    }, label: {
                        Text("Забыли пароль?").bold()
                            .foregroundStyle(Color(uiColor: .darkGray))
                    })
                    .padding()
                }
            }
        }
        .navigationDestination(isPresented: $isLogIn) {
//            if databaseVM.isTutorialViewed {
//                CustomTabBar()
//                    .navigationBarBackButtonHidden()
//            } else {
//                WelcomeScreen()
//            }
            if isViewed {
                CustomTabBar()
                    .navigationBarBackButtonHidden()
            } else {
                WelcomeScreen()
            }
        }
        .onReceive(yandexViewModel.$isLoggedIn) { isLoggedIn in
                    if isLoggedIn {
                        self.isLogIn = true
                    }
                }
        .onReceive(databaseVM.$isTutorialViewed) { isViewed in
            //self.isLogIn = true
            self.isViewed = isViewed
            self.isLogIn = true
                }
        .onChange(of: databaseVM.isTutorialViewed) { newValue in
            isViewed = newValue
        }
        .navigationDestination(isPresented: $isForgotPasswordPressed) {
            ForgotPasswordView()
        }
        .onAppear {
            email = ""
            password = ""
            isLogIn = false
        }
    }
}

#Preview {
    LogInView()
}
