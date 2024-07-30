//
//  CustomTabBar.swift
//  Relax
//
//  Created by Илья Кузнецов on 11.07.2024.
//

import SwiftUI

enum TabbedItems: Int, CaseIterable {
    case home = 0
    case sleep
    case meditation
    case music
    case profile
    
    var title: String {
        switch self {
        case .home:
            return "Главная"
        case .sleep:
            return "Сон"
        case .meditation:
            return "Медитация"
        case .music:
            return "Музыка"
        case .profile:
            return "Профиль"
        }
    }
    
    var iconName: String {
        switch self {
        case .home:
            return "house"
        case .sleep:
            return "powersleep"
        case .meditation:
            return "figure.mind.and.body"
        case .music:
            return "music.note"
        case .profile:
            return "person.fill"
        }
    }
}

struct CustomTabBar: View {
    
    @State private var selectedTab = 0
    private let musicViewModel = MusicFilesViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeScreen()
                    .tag(0)
                
                SleepScreen()
                    .tag(1)
                
                MeditationScreen()
                    .tag(2)
                
                MusicScreen()
                    .tag(3)
                    .environmentObject(musicViewModel)
                
                ProfileScreen()
                    .tag(4)
            }
            
            HStack(spacing: 10) {
                ForEach(TabbedItems.allCases, id: \.self) { item in
                    Button {
                        withAnimation {
                            selectedTab = item.rawValue
                        }
                    } label: {
                        customTabItem(imageName: item.iconName,
                                      title: item.title,
                                      isActive: (selectedTab == item.rawValue)
                        )
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 65)
            .background(selectedTab == 1 ? Color(uiColor: .init(red: 3/255,
                                                                green: 23/255,
                                                                blue: 77/255,
                                                                alpha: 1)) : .white)
        }
        .shadow(color: selectedTab == 1 ? .white.opacity(0.4) : .black.opacity(0.4), radius: 10, x: 0, y: 5)
    }
}

extension CustomTabBar {
    func customTabItem(imageName: String, title: String, isActive: Bool) -> some View {
        VStack(spacing: 3) {
            ZStack {
                Circle()
                    .fill(isActive ? Color(uiColor: .init(red: 142/255,
                                                          green: 151/255,
                                                          blue: 253/255,
                                                          alpha: 1)) : .clear)
                    .frame(width: 40, height: 40)
                
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(isActive ? .white : .gray).bold()
            }
            .frame(height: 50)
            
            Text(title)
                .padding(.horizontal, 0)
                .foregroundStyle((isActive && selectedTab == 1) ? .white
                                 : (isActive && selectedTab != 1 ?
                                    Color(uiColor: .init(red: 142/255,
                                                         green: 151/255,
                                                         blue: 253/255,
                                                         alpha: 1))
                                    : .gray))
                .font(.system(size: 11, weight: .bold, design: .rounded))
        }
    }
}

#Preview {
    CustomTabBar()
}
