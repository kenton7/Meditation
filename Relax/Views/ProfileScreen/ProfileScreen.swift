//
//  ProfileScreen.swift
//  Relax
//
//  Created by Илья Кузнецов on 02.07.2024.
//

import SwiftUI
import FirebaseAuth
import FirebaseCore
import StoreKit

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
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject private var yandexViewModel: YandexAuthorization
    @EnvironmentObject private var premiumViewModel: PremiumViewModel
    private var currentUser = Auth.auth().currentUser
    @State private var isBuyPremiumPressed = false
    @State private var aboutUsPressed = false
    @State private var isRemindersPressed = false
    let fileManagerService: IFileManagerSerivce = FileManagerSerivce()
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack {
                HStack {
                    if let user = currentUser {
                        Text("\(user.displayName ?? "")")
                            .padding()
                            .foregroundStyle(.black)
                            .font(.system(.title, design: .rounded, weight: .bold))
                    } else {
                        Text("\(yandexViewModel.userName ?? "")")
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
                            RemindersScreen(isFromSettings: true)
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
                            PremiumScreen()
                        })
                    }
                    
                    Section("Материалы") {
                            NavigationLink {
                                if premiumViewModel.hasUnlockedPremuim {
                                    DownloadedScreen(fileManagerSerivce: fileManagerService)
                                } else {
                                    PremiumScreen()
                                }
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
                            openMail(emailTo: "serotonika.app@gmail.com",
                                     subject: "Серотоника",
                                     body: "")
                        }, label: {
                            HStack {
                                Image("email")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text("Связаться с разработчиком")
                            }
                        })
                        
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
                            WebView(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/relax-8e1d3.appspot.com/o/aboutUs.rtf?alt=media&token=64393fb2-c94c-4f6b-a904-1688cb4c2a65")!)
                                .ignoresSafeArea()
                                .navigationTitle("О нас")
                                .navigationBarTitleDisplayMode(.inline)
                        })
                    }
                    
                    Button(action: {
                        Task {
                            do {
                                try await AppStore.sync()
                            } catch {
                                print("Error when restoring purchases \(error)")
                            }
                        }
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
    
    func openMail(emailTo: String, subject: String, body: String?) {
        if let url = URL(string: "mailto:\(emailTo)?subject=\(subject.fixToBrowserString())&body=\(String(describing: body?.fixToBrowserString()))"),
           UIApplication.shared.canOpenURL(url)
        {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("error email")
        }
    }
}
