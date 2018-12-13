//
//  KeychainService.swift
//  Film App
//
//  Created by Вероника Данилова on 11/12/2018.
//  Copyright © 2018 Veronika Danilova. All rights reserved.
//

import UIKit

final class KeychainService {
    
    enum Accounts: String {
        case vkontakte = "VK"
        case facebook = "FB"
        case google = "G"
    }
    
    static let shared = KeychainService()
    public let service = "MovieNight"
    
    private func keychainQuery(account: String) -> [String : AnyObject] {
        
        var query = [String : AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlocked
        query[kSecAttrService as String] = service as AnyObject
        query[kSecAttrAccount as String] = account as AnyObject
        
        return query
    }
    
    public func readToken(account: String) -> String? {
        var query = keychainQuery(account: account)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        
        var queryResult: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer(&queryResult))
        
        if status != noErr {
            return nil
        }
        
        guard let item = queryResult as? [String : AnyObject],
            let tokenData = item[kSecValueData as String] as? Data,
            let token = String(data: tokenData, encoding: .utf8) else {
                return nil
        }
        
        return token
    }
    
    public func saveToken(account: String, token: String) {
        
        let tokenData = token.data(using: .utf8)
        
        if readToken(account: account) != nil {
            var attributesToUpdate = [String : AnyObject]()
            attributesToUpdate[kSecValueData as String] = tokenData as AnyObject
            
            let query = keychainQuery(account: account)
            _ = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
        }
        
        var item = keychainQuery(account: account)
        item[kSecValueData as String] = tokenData as AnyObject
        _ = SecItemAdd(item as CFDictionary, nil)
    }
    
    
    public func deleteToken(account: String) {
        let item = keychainQuery(account: account)
        _ = SecItemDelete(item as CFDictionary)
    }
    
}
