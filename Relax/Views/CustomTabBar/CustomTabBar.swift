//
//  CustomTabBar.swift
//  Relax
//
//  Created by Илья Кузнецов on 11.07.2024.
//

import SwiftUI

//MARK: - CurrentTabKey
struct CurrentTabKey: EnvironmentKey {
    static let defaultValue: Binding<TabbedItems> = .constant(.home)
}

enum TabbedItems: Hashable, CaseIterable {
    case home
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

extension TabbedItems {
    
    @ViewBuilder
    var destination: some View {
        switch self {
        case .home:
            HomeScreen()
        case .sleep:
            SleepScreen()
        case .meditation:
            MeditationScreen()
        case .music:
            MusicScreen()
                .tint(.black)
        case .profile:
            ProfileScreen()
                .tint(.black)
        }
    }
}

struct CustomTabBar: View {
    
    @State private var selection: TabbedItems = .home
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selection) {
                ForEach(TabbedItems.allCases, id: \.self) { screen in
                    screen.destination
                        .tag(selection as TabbedItems?)
                }
            }
            .environment(\.currentTab, $selection)
            
            HStack(spacing: 10) {
                ForEach(TabbedItems.allCases, id: \.self) { item in
                    Button {
                        withAnimation {
                            selection = item
                        }
                    } label: {
                        customTabItem(imageName: item.iconName,
                                      title: item.title,
                                      isActive: (selection == item as TabbedItems?)
                        )
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 65)
            .background(selection == .sleep ? Color(uiColor: .init(red: 3/255,
                                                                green: 23/255,
                                                                blue: 77/255,
                                                                alpha: 1)) : .white)
        }
        .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 5)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

extension CustomTabBar {
    
    @ViewBuilder
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
                .foregroundStyle((isActive && selection == .sleep) ? .white
                                 : (isActive && selection != .sleep ?
                                    Color(uiColor: .init(red: 142/255,
                                                         green: 151/255,
                                                         blue: 253/255,
                                                         alpha: 1))
                                    : .gray))
                .font(.system(size: 11, weight: .bold, design: .rounded))
        }
    }
}

