//
//  OnboardingScreen.swift
//  Relax
//
//  Created by Илья Кузнецов on 21.06.2024.
//

import SwiftUI

struct OnboardingScreen: View {
    
    @EnvironmentObject var viewModel: AuthWithEmailViewModel
    @State private var hasAccount = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    Image("Frame").ignoresSafeArea()
                    Spacer()
                }
                VStack {
                    Text("Сияние души")
                        .font(.system(.title, design: .rounded)).bold()
                    OnboardingAnimation()
                    Spacer()
                    Text("Привет!")
                        .font(.title).bold()
                    Text("Добро пожаловать в наше приложение для медитации! Мы здесь, чтобы помочь вам найти внутренний покой и гармонию. Наши специально разработанные медитации и упражнения направлены на улучшение вашего самочувствия, снижение стресса и повышение концентрации. Начните свой путь к спокойствию и самосовершенствованию уже сегодня!")
                        .padding()
                        .font(.system(.callout, design: .rounded, weight: .light))
                        .foregroundStyle(Color(uiColor: .gray))
                        .multilineTextAlignment(.center)
                    
                    NavigationLink {
                        RegisterView()
                    } label: {
                        Text("Зарегистрироваться")
                            .foregroundStyle(.white)
                    }
                    .padding()
                    .background(Color(UIColor(red: 142/255, green: 151/255, blue: 253/255, alpha: 1)))
                    .clipShape(.rect(cornerRadius: 20))
                    
                    HStack {
                        Text("Уже есть аккаунт?")
                            .font(.system(.callout, design: .rounded, weight: .light))
                        Button("Войти") {
                            print(hasAccount)
                            withAnimation {
                                hasAccount = true
                            }
                            print(hasAccount)
                        }
                        .foregroundStyle(.blue)
                    }
                    .padding()
                }
            }
        }
        .navigationBarBackButtonHidden()
        .navigationDestination(isPresented: $hasAccount) {
            LogInView()
                .environmentObject(viewModel)
        }
    }
}

#Preview {
    OnboardingScreen()
}
