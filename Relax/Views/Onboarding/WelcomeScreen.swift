//
//  WelcomeScreen.swift
//  Relax
//
//  Created by Илья Кузнецов on 21.06.2024.
//

import SwiftUI
import FirebaseDatabase
import FirebaseAuth
import Lottie
import YandexLoginSDK

struct WelcomeScreen: View {
    
    @EnvironmentObject private var viewModel: AuthViewModel
    @EnvironmentObject var yandexViewModel: YandexAuthorization
    @State private var isLogOut = false
    @State private var isGetStartedTapped = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .init(red: 140/255, green: 150/255, blue: 255/255, alpha: 1)).ignoresSafeArea()
                VStack {
                    Text("Серотоника")
                        .padding()
                        .font(.system(.title2, design: .rounded)).bold()
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    if let userName = Auth.auth().currentUser?.displayName ?? yandexViewModel.userName {
                        Text("Привет, \(userName)! \nДобро пожаловать \n в Серотонику")
                            .padding(.bottom)
                            .multilineTextAlignment(.center)
                            .textInputAutocapitalization(.words)
                            .font(.system(.title, design: .rounded)).bold()
                            .foregroundStyle(.white)
                    }
                    
                    Text("Найдите внутренний покой и гармонию, следуя нашим медитациям каждый день.")
                        .padding(.horizontal)
                        .foregroundStyle(.white)
                        .font(.system(.subheadline, design: .rounded, weight: .light))
                        .multilineTextAlignment(.center)
                    
                    UserLearningAnimation()

                    VStack {
                        Spacer()
                        Button(action: {
                            withAnimation {
                                isGetStartedTapped = true
                            }
                        }, label: {
                            HStack {
                                Text("Давайте начнём")
                                    .foregroundStyle(.black)
                                    .frame(maxWidth: .infinity)
                            }
                            .contentShape(.rect)
                        })
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.white)
                        .clipShape(.rect(cornerRadius: 20))
                        .padding()
                    }
                }
            }
        }
        .navigationBarBackButtonHidden()
        .navigationDestination(isPresented: $isGetStartedTapped) {
            UserInterestsTopicScreen()
        }
    }
}

#Preview {
    WelcomeScreen()
}
