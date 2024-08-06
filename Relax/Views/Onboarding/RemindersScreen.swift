//
//  RemindersScreen.swift
//  Relax
//
//  Created by Илья Кузнецов on 25.06.2024.
//

import SwiftUI
import FirebaseAuth

struct Day {
    let name: String
    var isSelected: Bool = false
}

struct RemindersScreen: View {
    
    @State private var selectionTime = Date()
    @State private var isDaySelected = false
    private let coreDataService = CoreDataService.shared
    private let notificationService = NotificationsService.shared
    @StateObject private var databaseVM = ChangeDataInDatabase()
    @State private var selectedDays: [Day] = .init()
    @EnvironmentObject var authViewModel: AuthWithEmailViewModel
    @State private var isContinueOrSkipButtonPressed = false
    @State private var days: [Day] = [
            Day(name: "ПН"),
            Day(name: "ВТ"),
            Day(name: "СР"),
            Day(name: "ЧТ"),
            Day(name: "ПТ"),
            Day(name: "СБ"),
            Day(name: "ВС")
        ]
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("В какое время вам удобнее было бы медитировать?")
                        .padding(.horizontal)
                        .foregroundStyle(Color(uiColor: .init(red: 63/255, green: 65/255, blue: 78/255, alpha: 1)))
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                
                HStack {
                    Text("Вы можете выбрать любое время, \nно мы советуем заниматься утром.")
                        .padding(.horizontal)
                        .foregroundStyle(Color(uiColor: .init(red: 161/255, green: 164/255, blue: 178/255, alpha: 1)))
                    Spacer()
                }
                
                DatePicker("", selection: $selectionTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .clipped()
                
                HStack {
                    Text("В какой день вам было бы удобнее медитировать?")
                        .padding(.horizontal)
                        .foregroundStyle(Color(uiColor: .init(red: 63/255, green: 65/255, blue: 78/255, alpha: 1)))
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .multilineTextAlignment(.leading)
                    Spacer()
                }
                
                HStack {
                    Text("Каждый день – это лучший вариант, \nно мы советуем выбрать как минимум \n5 дней в неделю.")
                        .padding(.horizontal)
                        .foregroundStyle(Color(uiColor: .init(red: 161/255, green: 164/255, blue: 178/255, alpha: 1)))
                    Spacer()
                }
                
                LazyHGrid(rows: [GridItem(.fixed(40))],
                          alignment: .center,
                          spacing: 5,
                          content: {
                    ForEach($days, id: \.name) { $day in
                        Button(action: {
                            withAnimation {
                                day.isSelected.toggle()
                                selectedDays.append(day)
                                coreDataService.saveSelectedDays(selectedDays, time: selectionTime)
                            }
                        }, label: {
                            Text(day.name)
                                .foregroundColor(day.isSelected ? .white : Color(uiColor: .init(red: 161/255, green: 164/255, blue: 178/255, alpha: 1)))
                                .frame(width: 40, height: 40)
                                .background(day.isSelected ? Color(uiColor: .init(red: 63/255, green: 65/255, blue: 78/255, alpha: 1)) : Color.clear)
                                .overlay(
                                    Circle()
                                        .stroke(Color(uiColor: .init(red: 161/255, green: 164/255, blue: 178/255, alpha: 1)), lineWidth: 2)
                                )
                                .clipShape(Circle())
                        })
                        .padding(.horizontal, 5)
                    }
                })

                VStack {
                    Spacer()
                    Button(action: {
                        notificationService.requestAuthorization()
                        coreDataService.saveSelectedDays(selectedDays, time: selectionTime)
                        notificationService.sendNotificationWithContent(title: "Медитация ждет вас!",
                                                                        subtitle: nil,
                                                                        body: "Найдите спокойное место и начните свою практику.",
                                                                        sound: .default,
                                                                        selectedDays: selectedDays,
                                                                        selectedTime: selectionTime)
                        authViewModel.signedIn = true
                        isContinueOrSkipButtonPressed = true
                        if let user = Auth.auth().currentUser {
                            databaseVM.writeToDatabaseIfUserViewedTutorial(user: user, isViewed: isContinueOrSkipButtonPressed)
                        }
                    }, label: {
                        Text("Сохранить")
                            .foregroundStyle(.white)
                    })
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor(red: 142/255, green: 151/255, blue: 253/255, alpha: 1)))
                    .clipShape(.rect(cornerRadius: 20))
                    .padding()
                    
                    Button("Нет, спасибо") {
                        authViewModel.signedIn = true
                        coreDataService.saveSelectedDays(selectedDays, time: selectionTime)
                        isContinueOrSkipButtonPressed = true
                        if let user = Auth.auth().currentUser {
                            databaseVM.writeToDatabaseIfUserViewedTutorial(user: user, isViewed: isContinueOrSkipButtonPressed)
                        }
                    }
                    .foregroundStyle(Color(uiColor: .init(red: 63/255, green: 65/255, blue: 78/255, alpha: 1)))
                }
            }
            Spacer()
        }
        .navigationDestination(isPresented: $isContinueOrSkipButtonPressed) {
            MainScreen()
        }
    }
}

#Preview {
    RemindersScreen()
}
