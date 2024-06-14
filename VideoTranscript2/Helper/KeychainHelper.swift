//
//  KeychainHelper.swift
//  VideoTranscript2
//
//  Created by Viktor Kushnerov on 8.06.24.
//

import Foundation
import Security

enum KeychainHelper {
    static func storeTokenInKeychain(token: String) {
        let data = Data(token.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "openai_api_token",
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
        ]

        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)

        keychainLogger.warning("Store API token status: \(status.getOSStatusString())")
    }

    static func retrieveTokenFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "openai_api_token",
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        keychainLogger.warning("Retrieve API token status: \(status.getOSStatusString())")

        guard status == errSecSuccess, let data = item as? Data else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    static func updateTokenInKeychain(token: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "openai_api_token",
        ]

        let attributes: [String: Any] = [
            kSecValueData as String: Data(token.utf8),
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        keychainLogger.warning("Update API token status: \(status.getOSStatusString())")
    }
}
