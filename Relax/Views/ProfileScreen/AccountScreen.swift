//
//  AccountScreen.swift
//  Relax
//
//  Created by Илья Кузнецов on 26.07.2024.
//

import SwiftUI
import FirebaseAuth

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
    @EnvironmentObject var viewModel: AuthWithEmailViewModel
    @StateObject private var databaseVM = ChangeDataInDatabase()
    
    
    var body: some View {
        NavigationStack {
            if viewModel.signedIn/*, !viewModel.userID.isEmpty*/ {
                List {
                    Section("Ваше имя") {
                        VStack {
                            TextField(userName, text: $newUserName)
                                .padding()
                                .foregroundStyle(.black)
                                .textFieldStyle(.plain)
                                .background(Color(uiColor: .init(red: 242/255, green: 243/255, blue: 247/255, alpha: 1)))
                                .clipShape(.rect(cornerRadius: 8))
                                .padding()
                            
                            Button(action: {
                                isUpdatingName = true
                                Task.detached {
                                    try await databaseVM.updateDisplayName(newDisplayName: newUserName)
                                    await MainActor.run {
                                        self.isUpdatingName = false
                                    }
                                }
                            }, label: {
                                if isUpdatingName {
                                    ProgressView()
                                } else {
                                    Text("Обновить имя").bold()
                                        .foregroundStyle(.white)
                                }
                            })
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(UIColor(red: 142/255, green: 151/255, blue: 253/255, alpha: 1)))
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
                                    ProgressView()
                                } else {
                                    Text("Обновить email").bold()
                                        .foregroundStyle(.white)
                                }
                            })
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(UIColor(red: 142/255, green: 151/255, blue: 253/255, alpha: 1)))
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
                                    ProgressView()
                                } else {
                                    Text("Обновить пароль").bold()
                                        .foregroundStyle(.white)
                                }
                            })
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(UIColor(red: 142/255, green: 151/255, blue: 253/255, alpha: 1)))
                            .clipShape(.rect(cornerRadius: 20))
                            .padding()
                            .disabled(currentPassword.isEmpty)
                            .disabled(newPassword.isEmpty)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    Section("Выйти из аккаунта") {
                        Button(action: {
                            viewModel.signOut()
                        }, label: {
                            Text("Выйти")
                                .foregroundStyle(.white).bold()
                        })
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor(red: 142/255, green: 151/255, blue: 253/255, alpha: 1)))
                        .clipShape(.rect(cornerRadius: 20))
                        .padding()
                    }
                    .buttonStyle(.plain)
                    
                    Section("Удалить аккаунт") {
                        Button(action: {
                            isDeletingAccount = true
                        }, label: {
                            if isDeletingAccount {
                                ProgressView()
                            } else {
                                Text("Удалить аккаунт").bold()
                                    .foregroundStyle(.white)
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
                                    viewModel.deleteAccount()
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
                    userName = currentUser?.displayName ?? ""
                    currentEmail = currentUser?.email ?? ""
                    isUpdatingEmail = false
                    isUpdatingPassword = false
                    isDeletingAccount = false
                }
                .listStyle(.insetGrouped)
            } else {
                OnboardingScreen()
            }
        }
    }
}

#Preview {
    AccountScreen()
}
