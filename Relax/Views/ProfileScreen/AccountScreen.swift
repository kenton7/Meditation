//
//  AccountScreen.swift
//  Relax
//
//  Created by Илья Кузнецов on 26.07.2024.
//

import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct AccountScreen: View {
    
    private var currentUser = Auth.auth().currentUser
    @State private var userName = ""
    @State private var newUserName = ""
    @State private var currentEmail = ""
    @State private var newEmail = ""
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var isUpdatingEmail = false
    @State private var isUpdatingName = false
    @State private var isUpdatingPassword = false
    @State private var isDeletingAccount = false
    @State private var errorMessagePassword = ""
    @State private var errorMessageEmail = ""
    @State private var isError = false
    @FocusState private var isFocused: Bool
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject private var yandexViewModel: YandexAuthorization
    @StateObject private var databaseVM = ChangeDataInDatabase.shared
    @AppStorage("toogleDarkMode") private var toogleDarkMode = false
    @AppStorage("activeDarkModel") private var activeDarkModel = false
    
    
    var body: some View {
        NavigationStack {
                List {
                    if !yandexViewModel.isLoggedIn {
                        Section("Ваше имя") {
                            VStack {
                                ZStack(alignment: .leading) {
                                    TextField("", text: $newUserName)
                                        .padding()
                                        .foregroundStyle(.black)
                                        .textFieldStyle(.plain)
                                        .background(activeDarkModel ? .black : Color(uiColor: .init(red: 242/255, green: 243/255, blue: 247/255, alpha: 1)))
                                        .clipShape(.rect(cornerRadius: 8))
                                        .focused($isFocused)
                                        .onTapGesture {
                                            isFocused = true
                                        }
                                        .padding()
                                    
                                    Text(userName)
                                        .padding()
                                        .offset(x: 10)
                                        .offset(y: (isFocused || !newUserName.isEmpty) ? -40 : 0)
                                        .foregroundStyle(isFocused ? .black : .secondary)
                                        .animation(.spring, value: isFocused)
                                }
                                Button(action: {
                                    isUpdatingName = true
                                    Task.detached {
                                        try await databaseVM.updateDisplayName(newDisplayName: newUserName)
                                        await MainActor.run {
                                            self.isUpdatingName = false
                                            userName = newUserName
                                            newUserName = ""
                                        }
                                    }
                                }, label: {
                                    if isUpdatingName {
                                        LoadingAnimationButton()
                                    } else {
                                        HStack {
                                            Text("Обновить имя").bold()
                                                .foregroundStyle(.white)
                                                .frame(maxWidth: .infinity)
                                        }
                                        .contentShape(.rect)
                                    }
                                })
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(uiColor: .defaultButtonColor))
                                .clipShape(.rect(cornerRadius: 20))
                                .padding()
                                .disabled(newUserName.isEmpty)
                            }
                        }
                        .buttonStyle(.plain)
                        
                        Section("Ваш email") {
                            VStack {
                                EmailFieldView(currentEmail, email: $newEmail)
                                
                                if !errorMessageEmail.isEmpty {
                                    Text(errorMessageEmail)
                                        .padding()
                                        .foregroundStyle(.red).bold()
                                        .multilineTextAlignment(.center)
                                }
                                
                                Button(action: {
                                    isUpdatingEmail = true
                                    Task.detached {
                                        do {
                                            try await databaseVM.changeEmail(newEmail: newEmail)
                                            await MainActor.run {
                                                self.isUpdatingEmail = false
                                                currentEmail = newEmail
                                                newEmail = ""
                                            }
                                        } catch {
                                            await MainActor.run {
                                                self.errorMessageEmail = error.localizedDescription
                                                self.isUpdatingEmail = false
                                            }
                                        }
                                    }
                                }, label: {
                                    if isUpdatingEmail {
                                        LoadingAnimationButton()
                                    } else {
                                        HStack {
                                            Text("Обновить email").bold()
                                                .foregroundStyle(.white)
                                                .frame(maxWidth: .infinity)
                                        }
                                        .contentShape(.rect)
                                    }
                                })
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(uiColor: .defaultButtonColor))
                                .clipShape(.rect(cornerRadius: 20))
                                .padding()
                                .disabled(newEmail.isEmpty || !newEmail.isValidEmail())
                            }
                        }
                        .buttonStyle(.plain)
                        
                        Section("Сменить пароль") {
                            VStack {
                                PasswordFieldView("Текущий пароль", text: $currentPassword)
                                    .frame(maxWidth: .infinity)
                                
                                PasswordFieldView("Новый пароль", text: $newPassword)
                                    .frame(maxWidth: .infinity)
                                
                                if !errorMessagePassword.isEmpty {
                                    Text(errorMessagePassword)
                                        .padding()
                                        .foregroundStyle(.red).bold()
                                        .multilineTextAlignment(.center)
                                }
                                
                                Button(action: {
                                    isUpdatingPassword = true
                                    Task.detached {
                                        do {
                                            try await databaseVM.updatePassword(newPassword: newPassword, currentPassword: currentPassword)
                                            await MainActor.run {
                                                self.isUpdatingPassword = false
                                            }
                                        } catch {
                                            await MainActor.run {
                                                self.errorMessagePassword = error.localizedDescription
                                                self.isUpdatingPassword = false
                                            }
                                        }
                                    }
                                }, label: {
                                    if isUpdatingPassword {
                                        LoadingAnimationButton()
                                    } else {
                                        HStack {
                                            Text("Обновить пароль").bold()
                                                .foregroundStyle(.white)
                                                .frame(maxWidth: .infinity)
                                        }
                                        .contentShape(.rect)
                                    }
                                })
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(uiColor: .defaultButtonColor))
                                .clipShape(.rect(cornerRadius: 20))
                                .padding()
                                .disabled(currentPassword.isEmpty)
                                .disabled(newPassword.isEmpty)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Section("Выйти из аккаунта") {
                        Button(action: {
                            if Auth.auth().currentUser != nil {
                                viewModel.signOut()
                            } else {
                                yandexViewModel.logout()
                            }
                        }, label: {
                            HStack {
                                Text("Выйти")
                                    .foregroundStyle(.white).bold()
                                    .frame(maxWidth: .infinity)
                            }
                            .contentShape(.rect)
                        })
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(uiColor: .defaultButtonColor))
                        .clipShape(.rect(cornerRadius: 20))
                        .padding()
                    }
                    .buttonStyle(.plain)
                    
                    Section("Удалить аккаунт") {
                        Button(action: {
                            isDeletingAccount = true
                        }, label: {
                            if isDeletingAccount {
                                LoadingAnimationButton()
                            } else {
                                HStack {
                                    Text("Удалить аккаунт").bold()
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity)
                                }
                                .contentShape(.rect)
                            }
                        })
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.red)
                        .clipShape(.rect(cornerRadius: 20))
                        .padding()
                        .alert("Вы уверены, что хотите удалить аккаунт?",
                               isPresented: $isDeletingAccount) {
                            HStack {
                                Button("Да", role: .destructive) {
                                    if Auth.auth().currentUser != nil {
                                        if viewModel.isAppleLogin {
                                            viewModel.revokeAppleSignInToken()
                                        } else {
                                            viewModel.deleteAccount()
                                        }
                                    } else {
                                        Task {
                                            try await Database.database(url: .databaseURL).reference().child("users").child(yandexViewModel.yandexUserID).child("isTutorialViewed").setValue(false)
                                            await yandexViewModel.deleteYandexAccount()
                                            self.isDeletingAccount = false
                                        }
                                    }
                                }
                                Button("Отменить", role: .cancel) {
                                    isDeletingAccount = false
                                }
                            }
                        } message: {
                            Text("Восстановить аккаунт после удаления будет невозможно.")
                        }
                        
                    }
                    .buttonStyle(.plain)
                }
                .onAppear {
                    userName = currentUser?.displayName ?? yandexViewModel.userInfo?.first_name ?? ""
                    currentEmail = currentUser?.email ?? ""
                    isUpdatingEmail = false
                    isUpdatingPassword = false
                    isDeletingAccount = false
                }
                .listStyle(.insetGrouped)
        }
    }
}

