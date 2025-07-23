//
//  KeychainHelper.swift
//  NeuroNote
//
//  Created by Eclipse on 05/07/25.
//
import Foundation
import Security

class KeychainHelper {
    static let standard = KeychainHelper()

    func save(_ value: String, forKey key: String) {
        if let data = value.data(using: .utf8) {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
                kSecValueData as String: data
            ]

            SecItemDelete(query as CFDictionary)
            SecItemAdd(query as CFDictionary, nil)
        }
    }

    func read(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        if SecItemCopyMatching(query as CFDictionary, &item) == noErr,
           let data = item as? Data,
           let string = String(data: data, encoding: .utf8) {
            return string
        }
        return nil
    }

    func delete(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}

extension KeychainHelper: UserIDStore {
    func getUserID() -> String? {
        return read(forKey: "userId")
    }
}

extension KeychainHelper {
    func clearTestKeys() {
        delete(forKey: Constants.KeychainHelperKeys.authToken)
        delete(forKey: Constants.KeychainHelperKeys.userId)
    }
}
