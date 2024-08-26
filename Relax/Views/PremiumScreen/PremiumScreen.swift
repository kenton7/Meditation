//
//  PremiumScreen.swift
//  Серотоника
//
//  Created by Илья Кузнецов on 24.08.2024.
//

import SwiftUI
import StoreKit

struct PremiumScreen: View {
    
    @EnvironmentObject private var premuimViewModel: PremiumViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = true
    @State private var isRestoringPurchases = false
    
    var body: some View {
        VStack {
            if premuimViewModel.hasUnlockedPremuim {
                withAnimation {
                    VStack(spacing: 20) {
                        Text("Добро пожаловать в мир спокойствия!")
                            .padding()
                            .foregroundStyle(Color(uiColor: .init(red: 63/255,
                                                                  green: 65/255,
                                                                  blue: 78/255,
                                                                  alpha: 1)))
                            .font(.system(.title, design: .rounded, weight: .bold))
                            .multilineTextAlignment(.center)
                        CompletePurchaseAnimation()
                            .frame(width: 150, height: 150)
                        
                        Group {
                            Text("Спасибо за вашу подписку на Серотонику! \nТеперь у вас есть полный доступ ко всем медитациям, урокам и персонализированным программам. Вы сделали важный шаг на пути к внутреннему покою и благополучию.")
                                .padding()
                            
                            Text("Мы рады, что вы с нами! \nЕсли у вас возникнут вопросы или нужна помощь, наша команда всегда готова помочь. Наслаждайтесь каждым моментом с Серотоникой!")
                                .padding(.horizontal)
                        }
                        .foregroundStyle(Color(uiColor: .init(red: 63/255,
                                                              green: 65/255,
                                                              blue: 78/255,
                                                              alpha: 1)))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.leading)
                        
                        Button(action: {
                            dismiss()
                        }, label: {
                            Text("Закрыть")
                                .foregroundStyle(.white)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                        })
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(uiColor: .defaultButtonColor))
                        .clipShape(.rect(cornerRadius: 20))
                        .padding()
                    }
                }
            } else {
                PremiumAnimation()
                    .frame(height: 150)
                Group {
                    Text("Разблокируйте все возможности!")
                        .padding(.horizontal)
                        .foregroundStyle(Color(uiColor: .init(red: 161/255,
                                                              green: 164/255,
                                                              blue: 178/255,
                                                              alpha: 1)))
                    VStack {
                        HStack {
                            Image(systemName: "checkmark.square.fill")
                                .foregroundStyle(.green)
                                .frame(width: 15, height: 15)
                            Text("Неограниченные медитации: открывайте для себя новые практики каждый день;")
                                .foregroundStyle(Color(uiColor: .init(red: 63/255,
                                                                      green: 65/255,
                                                                      blue: 78/255,
                                                                      alpha: 1)))
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            Image(systemName: "checkmark.square.fill")
                                .foregroundStyle(.green)
                                .frame(width: 15, height: 15)
                            Text("Эксклюзивные материалы: глубокие уроки по осознанности, управлению стрессом и улучшению сна;")
                                .foregroundStyle(Color(uiColor: .init(red: 63/255,
                                                                      green: 65/255,
                                                                      blue: 78/255,
                                                                      alpha: 1)))
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            Image(systemName: "checkmark.square.fill")
                                .foregroundStyle(.green)
                                .frame(width: 15, height: 15)
                            Text("Скачивайте уроки или весь плейлист в оффлайн: практикуйтесь даже там, где нет интернета.")
                                .foregroundStyle(Color(uiColor: .init(red: 63/255,
                                                                      green: 65/255,
                                                                      blue: 78/255,
                                                                      alpha: 1)))
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                    
                    VStack {
                        Text("Выберите свой план:")
                            .padding()
                            .foregroundStyle(Color(uiColor: .init(red: 63/255,
                                                                  green: 65/255,
                                                                  blue: 78/255,
                                                                  alpha: 1)))
                            .font(.system(.title2, design: .rounded, weight: .bold))
                            .multilineTextAlignment(.center)
                        
                        if isLoading {
                            LoadingAnimationButton()
                                .frame(width: 100, height: 100)
                        } else {
                            ForEach(premuimViewModel.products) { product in
                                Button(action: {
                                    Task {
                                        do {
                                            try await premuimViewModel.purchase(product)
                                        } catch {
                                            print("Error when trying to purchase \(error)")
                                        }
                                    }
                                }, label: {
                                    Text("\(product.displayName): \(product.displayPrice)")
                                        .foregroundStyle(.white)
                                        .font(.system(size: 17, weight: .bold, design: .rounded))
                                })
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color(uiColor: .defaultButtonColor))
                                .clipShape(.rect(cornerRadius: 20))
                                .padding(.horizontal)
                            }
                        }
                    }
                    
                    Text("Оплата будет снята с вашего аккаунта App Store после подтверждения покупки. Подписка автоматически продлевается, если автообновление не будет отключено за 24 часа до окончания текущего периода. Управление подпиской и отключение автообновления доступны в настройках вашего аккаунта App Store.")
                        .padding(10)
                        .foregroundStyle(Color(uiColor: .init(red: 161/255,
                                                              green: 164/255,
                                                              blue: 178/255,
                                                              alpha: 1)))
                        .font(.system(size: 11, weight: .light, design: .rounded))
                    
                    Button(action: {
                        isRestoringPurchases = true
                        Task {
                            do {
                                try await AppStore.sync()
                                await MainActor.run {
                                    self.isRestoringPurchases = false
                                }
                            } catch {
                                print("Error when restoring purchases \(error)")
                            }
                        }
                    }, label: {
                        if isRestoringPurchases {
                            LoadingAnimationButton()
                                .frame(width: 40, height: 40)
                        } else {
                            Text("Восстановить покупки").bold()
                                .foregroundStyle(Color(uiColor: .init(red: 63/255,
                                                                      green: 65/255,
                                                                      blue: 78/255,
                                                                      alpha: 1)))
                        }
                    })
                }
                Spacer()
            }
        }
        .preferredColorScheme(.light)
        .task {
            do {
                try await premuimViewModel.loadProducts()
                await MainActor.run {
                    self.isLoading = false
                }
            } catch {
                print("error loading products \(error)")
            }
        }
    }
}

#Preview {
    PremiumScreen()
}
