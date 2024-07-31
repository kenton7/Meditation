//
//  PasswordFieldView.swift
//  Relax
//
//  Created by Илья Кузнецов on 21.06.2024.
//

import SwiftUI

struct PasswordFieldView: View {
    
    @Binding private var text: String
    @State private var isSecured: Bool = true
    private var title: String
    @FocusState private var isFocused: Bool
    
    init(_ title: String, text: Binding<String>) {
        self.title = title
        self._text = text
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            Group {
                if isSecured {
                    SecureField(title, text: $text)
                        .padding()
                        .background(Color(uiColor: .init(red: 242/255, green: 243/255, blue: 247/255, alpha: 1)))
                        .clipShape(.rect(cornerRadius: 8))
                        .padding()
                        .autocorrectionDisabled(true)
                        .onTapGesture {
                            isFocused = true
                        }
                } else {
                    TextField(title, text: $text)
                        .padding()
                        .background(Color(uiColor: .init(red: 242/255, green: 243/255, blue: 247/255, alpha: 1)))
                        .clipShape(.rect(cornerRadius: 8))
                        .padding()
                        .autocorrectionDisabled(true)
                        .onTapGesture {
                            isFocused = true
                        }
                }
                
                Button(action: {
                    isSecured.toggle()
                }) {
                    Image(systemName: isSecured ? "eye.slash" : "eye")
                        .padding(.horizontal)
                        .foregroundStyle(.gray)
                }
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    PasswordFieldView("Пароль", text: .constant("123"))
}
