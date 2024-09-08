//
//  EmailFieldView.swift
//  Relax
//
//  Created by Илья Кузнецов on 21.06.2024.
//

import SwiftUI

struct EmailFieldView: View {
    
    @Binding private var email: String
    @State private var isEmailEditing = false
    private var title: String
    @FocusState private var isFocused: Bool
    @AppStorage("toogleDarkMode") private var toogleDarkMode = false
    @AppStorage("activeDarkModel") private var activeDarkModel = false
    
    init(_ title: String, email: Binding<String>) {
        self.title = title
        self._email = email
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
        TextField("", text: $email)
            .padding()
            .background(activeDarkModel ? .black : Color(uiColor: .init(red: 242/255, green: 243/255, blue: 247/255, alpha: 1)))
            .clipShape(.rect(cornerRadius: 8))
            .padding()
            .keyboardType(.emailAddress)
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
            .focused($isFocused)
            .onTapGesture {
                withAnimation {
                    isEmailEditing = true
                    isFocused = true
                }
            }
            .overlay {
                HStack {
                    Spacer()
                    Image(systemName: email.isValidEmail() ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .padding(.horizontal, -50)
                        .foregroundStyle(email.isValidEmail() ? .green : .red)
                        .opacity(isFocused ? 1 : 0)
                }
            }

            Text(title)
                .padding()
                .offset(x: 10)
                .offset(y: (isFocused || !email.isEmpty) ? -40 : 0)
                .foregroundStyle(isFocused && activeDarkModel ? .white : .secondary)
                .foregroundStyle(isFocused ? .black : .secondary)
                .animation(.spring, value: isFocused)
        }
    }
}

