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
    @State private var isUpdatingPassword = false
    @State private var isDeletingAccount = false
    @StateObject private var databaseVM = ChangeDataInDatabase()
    @StateObject private var viewModel = AuthWithEmailViewModel()
    
    var body: some View {
        if viewModel.isUserLoggedIn, !viewModel.userID.isEmpty {
                List {
                    Section("Ваше имя") {
                        TextField(userName, text: $newUserName, onCommit: saveText)
                            .padding()
                            .foregroundStyle(.black)
                            .textFieldStyle(.plain)
                    }
                    
                    Section("Ваш email") {
                        TextField(currentEmail, text: $newEmail, onCommit: updateEmail)
                            .padding()
                            .foregroundStyle(.black)
                            .textFieldStyle(.plain)
                            .textContentType(.emailAddress)
                    }
                    
                    Section("Сменить пароль") {
                        VStack {
                            PasswordFieldView("Текущий пароль", text: $currentPassword)
                                .frame(maxWidth: .infinity)
                            
                            PasswordFieldView("Новый пароль", text: $newPassword)
                                .frame(maxWidth: .infinity)
                            
                            Button(action: {
                                updatePassword()
                            }, label: {
                                if isUpdatingPassword {
                                    ProgressView()
                                } else {
                                    Text("Обновить пароль")
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
                    
                    Section("Удалить аккаунт") {
                        Button(action: {
                            isDeletingAccount = true
                        }, label: {
                            if isDeletingAccount {
                                ProgressView()
                            } else {
                                Text("Удалить аккаунт")
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
                }
                .onAppear {
                    userName = currentUser?.displayName ?? ""
                    currentEmail = currentUser?.email ?? ""
                    isUpdatingPassword = false
                    isDeletingAccount = false
                }
            .listStyle(.insetGrouped)
            
        } else {
            OnboardingScreen()
        }
    }
    
    func saveText() {
        userName = newUserName
        databaseVM.updateDisplayName(newDisplayName: userName)
    }
    
    func updateEmail() {
        currentEmail = newEmail
        Task.detached {
            try await databaseVM.changeEmail(newEmail: currentEmail)
        }
    }
    
    func updatePassword() {
        isUpdatingPassword = true
        databaseVM.updatePassword(newPassword: newPassword, currentPassword: currentPassword)
    }
}

#Preview {
    AccountScreen()
}
