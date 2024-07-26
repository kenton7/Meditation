//
//  ProfileScreen.swift
//  Relax
//
//  Created by Илья Кузнецов on 02.07.2024.
//

import SwiftUI
import FirebaseAuth
import FirebaseCore

enum ProfileScreenModel: String, CaseIterable {
    case account = "Аккаунт"
    case notifications = "Уведомления"
    case downloaded = "Скачанное"
    case buyPremium = "Премиум"
    case writeDevelopers = "Связаться с разработчиком"
    case aboutUs = "О нас"
    case restorePurchases = "Восстановить покупки"
}

struct ProfileScreen: View {
    
    @StateObject private var authViewModel = AuthWithEmailViewModel()
    private var currentUser = Auth.auth().currentUser
    @State private var isBuyPremiumPressed = false
    @State private var writeToDeveloperPressed = false
    @State private var aboutUsPressed = false
    
    var body: some View {
        NavigationStack {
            
            VStack {
                HStack {
                    if let user = currentUser {
                        Text("\(user.displayName!)")
                            .padding()
                            .foregroundStyle(.black)
                            .font(.system(.title, design: .rounded, weight: .bold))
                    }
                    Spacer()
                }
                Spacer()
                
                List {
                    Section("Настройки") {
                        NavigationLink {
                            AccountScreen()
                        } label: {
                            HStack {
                                Image("account")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text("Аккаунт")
                            }
                        }

                            
                        NavigationLink {
                            //
                        } label: {
                            HStack {
                                Image("notifications")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text("Уведомления")
                            }
                        }
                        
                        Button(action: {
                            isBuyPremiumPressed = true
                        }, label: {
                            HStack {
                                Image("premium")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text("Премиум")
                            }
                        })
                        .sheet(isPresented: $isBuyPremiumPressed, content: {
                            //
                        })
                    }
                    
                    Section("Материалы") {
                        NavigationLink {
                            //
                        } label: {
                            HStack {
                                Image("downloaded")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text("Скачанное")
                            }
                        }
                    }
                    
                    Section("Помощь") {
                        Button(action: {
                            //writeToDeveloperPressed = true
                            openMail(emailTo: "support@gmail.com",
                                         subject: "App feedback",
                                         body: "Huston, we have a problem!\n\n...")
                        }, label: {
                            HStack {
                                Image("email")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text("Связаться с разработчиком")
                            }
                        })
//                        .sheet(isPresented: $writeToDeveloperPressed, content: {
//                            //
//                        })
                        
                        Button(action: {
                            aboutUsPressed = true
                        }, label: {
                            HStack {
                                Image("aboutUs")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text("О нас")
                            }
                        })
                        .sheet(isPresented: $aboutUsPressed, content: {
                            //
                        })
                    }
                    
                    Button(action: {
                        
                    }, label: {
                        HStack {
                            Image("restorePurchases")
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text("Восстановить покупки")
                        }
                    })
                }
                .foregroundStyle(.black)
            }
        }
    }
    
    func openMail(emailTo:String, subject: String, body: String) {
        if let url = URL(string: "mailto:\(emailTo)?subject=\(subject.fixToBrowserString())&body=\(body.fixToBrowserString())"),
           UIApplication.shared.canOpenURL(url)
        {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("error email")
        }
    }
}

#Preview {
    ProfileScreen()
}
