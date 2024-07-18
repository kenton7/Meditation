//
//  UserDefaults+Extension.swift
//  Relax
//
//  Created by Илья Кузнецов on 16.07.2024.
//

import Foundation

extension UserDefaults {
    func setObject<T: Codable>(_ object: T, forKey key: String) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(object)
            self.set(data, forKey: key)
        } catch {
            print("Unable to Encode Object (\(error))")
        }
    }
    
    func getObject<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = self.data(forKey: key) else { return nil }
        do {
            let decoder = JSONDecoder()
            let object = try decoder.decode(type, from: data)
            return object
        } catch {
            print("Unable to Decode Object (\(error))")
            return nil
        }
    }
}
