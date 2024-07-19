//
//  LogInView.swift
//  Relax
//
//  Created by Илья Кузнецов on 21.06.2024.
//

import SwiftUI
import FirebaseAuth

struct LogInView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @EnvironmentObject var viewModel: AuthWithEmailViewModel
    @State private var isLogIn = false
    @State private var isForgotPasswordPressed = false
    @State private var errorMessage: String?
    @State private var userID: String?
    @State private var userModel: UserModel?
    @State private var isLogining = false
    @StateObject private var databaseVM = ChangeDataInDatabase()
    
    var body: some View {
        //MARK: - Кнопки авторизации через гугл и Apple
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
                        //GOOGLE
                    } label: {
                        HStack {
                            Image("Google")
                                .frame(width: 20, height: 20)
                            Text("Войти через Google")
                                .foregroundStyle(.black).bold()
                        }
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: RoundedCornerStyle.continuous)
                            .stroke(Color(uiColor: .lightGray), lineWidth: 3)
                    )
                    
                    Button(action: {
                        //Apple
                    }, label: {
                        HStack {
                            Image("Apple")
                                .frame(width: 25, height: 20)
                            Text("Войти через Apple")
                                .bold()
                                .foregroundStyle(.black)
                        }
                    })
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: RoundedCornerStyle.continuous)
                            .stroke(Color(uiColor: .black), lineWidth: 3)
                    )
                    .padding()
                    
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
                                .bold()
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    Spacer()
                    Button(action: {
                        isLogining = true
                        Task.detached {
                            do {
                                let user = try await viewModel.asyncLogInWith(email: email, password: password)
                                if let firebaseUser = Auth.auth().currentUser {
                                    await databaseVM.checkIfUserViewedTutorial(user: firebaseUser)
                                }
                                await MainActor.run {
                                    userModel = user
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
                            ProgressView()
                        } else {
                            Text("Войти")
                                .foregroundStyle(.white)
                        }
                    })
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor(red: 142/255, green: 151/255, blue: 253/255, alpha: 1)))
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
            
            if databaseVM.isTutorialViewed {
                MainScreen()
                    .environmentObject(viewModel)
            } else {
                WelcomeScreen(user: userModel)
                    .environmentObject(viewModel)
            }
            
//            if UserDefaults.standard.bool(forKey: "isTutorialViewed") {
//                    MainScreen()
//                        .environmentObject(viewModel)
//            } else {
//                WelcomeScreen(user: userModel)
//                    .environmentObject(viewModel)
//            }
        }
        .navigationDestination(isPresented: $isForgotPasswordPressed) {
            ForgotPasswordView()
                .environmentObject(viewModel)
        }
        .onAppear {
            email = ""
            password = ""
        }
    }
}

#Preview {
    LogInView()
}
