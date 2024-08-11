//
//  RegisterView.swift
//  Relax
//
//  Created by Илья Кузнецов on 21.06.2024.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

struct RegisterView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var name: String = ""
    @State private var isEmailEditing = false
    @State private var isShowingPassword = false
    @State private var isAgreeWithPrivacy = false
    @State private var isRegistered: Bool = false
    @State private var isErrorWhileRegister: Bool = false
    @State private var errorMessage: String?
    @State private var userID: String?
    @EnvironmentObject var viewModel: AuthWithEmailViewModel
    @State private var isRegistration = false
    @State private var isPrivacyPolicyPressed = false
    @State private var isTermsAndConditionsPressed = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Image("LoginBackground").ignoresSafeArea()
                    Spacer()
                }
                VStack {
                    Spacer()
                    Text("Создайте новый аккаунт")
                        .font(.system(.title, design: .rounded, weight: .bold))
                    //Spacer()
                    //MARK: - Кнопки авторизации через гугл и Apple
                    Button {
                        //GOOGLE
                    } label: {
                        HStack {
                            Image("Google")
                                .frame(width: 20, height: 20)
                            Text("Войти через Google")
                                .foregroundStyle(.black)
                                .bold()
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
                    Text("ИЛИ ЗАРЕГИСТРИРУЙТЕСЬ С ПОМОЩЬЮ EMAIL")
                        .font(.system(size: 15))
                        .foregroundStyle(.gray)
                        .padding()
                    Spacer()
                    
                    TextField("Как Вас зовут?", text: $name)
                        .padding()
                        .background(Color(uiColor: .init(red: 242/255, green: 243/255, blue: 247/255, alpha: 1)))
                        .clipShape(.rect(cornerRadius: 8))
                        .padding()
                        .autocorrectionDisabled(true)
                    
                    VStack {
                        EmailFieldView("Email", email: $email)
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .bold()
                                .foregroundStyle(.red)
                                .font(.system(size: 15))
                                .lineLimit(nil)
                        }
                    }
                    PasswordFieldView("Пароль", text: $password)
                    Spacer()
                    
                    Group {
                        HStack {
                            Text("Я прочитал(-а)")
                                .font(.system(size: 9, weight: .light, design: .rounded))
                            Button(action: {
                                isPrivacyPolicyPressed = true
                            }, label: {
                                Text("политику конфиденциальности")
                                    .foregroundStyle(.blue)
                                    .font(.system(size: 9, weight: .light, design: .rounded))
                            })
                            .sheet(isPresented: $isPrivacyPolicyPressed, content: {
                                WebView(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/relax-8e1d3.appspot.com/o/Privacy.rtf?alt=media&token=8b23e1ac-d014-465f-adba-445426f0b37e")!)
                            })
                            
                            Button(action: {
                                isTermsAndConditionsPressed = true
                            }, label: {
                                Text("и согласен(-на) с условиями")
                                    .foregroundStyle(.blue)
                                    .font(.system(size: 9, weight: .light, design: .rounded))
                            })
                            .sheet(isPresented: $isTermsAndConditionsPressed, content: {
                                WebView(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/relax-8e1d3.appspot.com/o/terms.rtf?alt=media&token=8d861b43-5a76-48f3-8c2d-ae77ad2faee1")!)
                            })

                            Button(action: {
                                withAnimation {
                                    isAgreeWithPrivacy.toggle()
                                }
                            }, label: {
                                RoundedRectangle(cornerRadius: 5, style: RoundedCornerStyle.continuous)
                                    .stroke(Color(uiColor: .black), lineWidth: 1)
                                    .frame(width: 20, height: 20)
                                    .overlay {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(isAgreeWithPrivacy ? .green : .clear)
                                    }
                            })
                        }
                        .padding(.vertical)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        isRegistration = true
                        Task {
                            do {
                                try await viewModel.asyncRegisterWith(name: name, email: email, password: password)
                                await MainActor.run {
                                    self.isRegistered = true
                                    print("is registered? \(self.isRegistered)")
                                    self.errorMessage = nil
                                }
                            } catch {
                                await MainActor.run {
                                    self.errorMessage = "\(error.localizedDescription)"
                                    self.isRegistration = false
                                }
                            }
                        }
                    }, label: {
                        if isRegistration {
                            ProgressView()
                        } else {
                            Text("Зарегистрироваться")
                                .foregroundStyle(.white)
                        }
                    })
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(uiColor: .defaultButtonColor))
                    .clipShape(.rect(cornerRadius: 20))
                    .disabled(!email.isValidEmail())
                    .disabled(name.isEmpty)
                    .disabled(password.isEmpty)
                    .disabled(!isAgreeWithPrivacy)
                    .padding()
                }
            }
            .navigationDestination(isPresented: $isRegistered) {
                WelcomeScreen()
            }
        }
    }
}



#Preview {
    RegisterView()
}
