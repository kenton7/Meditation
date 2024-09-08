//
//  EmailService.swift
//  Серотоника
//
//  Created by Илья Кузнецов on 07.09.2024.
//

import Foundation
import UIKit.UIApplication

class EmailService: ObservableObject {
    func openMail(emailTo: String, subject: String, body: String) {
        if let url = URL(string: "mailto:\(emailTo)?subject=\(subject.fixToBrowserString())&body=\(body)"),
           UIApplication.shared.canOpenURL(url)
        {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("error email")
        }
    }
}
