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
                        .scaleEffect(CGSize(width: 1.2, height: 1.0))
                    Spacer()
                }
                VStack {
                    Text("Серотоника")
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
                    .background(Color(uiColor: .defaultButtonColor))
                    .clipShape(.rect(cornerRadius: 20))
                    .frame(maxWidth: .infinity)
                    
                    HStack {
                        Text("Уже есть аккаунт?")
                            .font(.system(.callout, design: .rounded, weight: .light))
                        Button("Войти") {
                            hasAccount = true
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
        }
    }
}

#Preview {
    OnboardingScreen()
}
