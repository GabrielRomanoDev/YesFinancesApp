//
//  LocalStorageManager.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 23/06/25.
//

import Foundation

class LocalStorageManager {
    
    static func saveUserDefaults(key: String, value: Any) {
        UserDefaults.standard.setValue(value, forKey: key)
    }
    
    static func removeUserDefaults(key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    static func getUserDefaults(key: String) -> Any? {
        return UserDefaults.standard.object(forKey: key)
    }
    
    static func saveUserData(user: UserData) {
        
    }
    
}
