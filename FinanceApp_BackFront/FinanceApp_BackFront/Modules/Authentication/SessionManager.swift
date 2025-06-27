//
//  SessionManager.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 08/06/25.
//

import Foundation

class SessionManager {
    
    var currentUser: UserData?
    
    //Check if last login with password was made before 7 days ago.
    func isSessionValid() -> Bool {
        
        if currentUser != nil {
            return true
        }
        
        if let userLogged = loadUser(),
           let lastLoginDate = LocalStorageManager.getUserDefaults(key: ConstantKeys.lastLoginDate) as? Date {
            
            if lastLoginDate > Date().addingTimeInterval(-604800) {
                currentUser = userLogged
                return true
            }
            
        }

        return false
        
    }
    
    func setUser(_ user: UserData) {
        
        if let encoded = try? JSONEncoder().encode(user) {
            currentUser = user
            LocalStorageManager.saveUserDefaults(key:  ConstantKeys.loggedUserID, value: encoded)
            saveLoginDate()
        }
        
    }
    
    func loadUser() -> UserData? {
        if let data = LocalStorageManager.getUserDefaults(key: ConstantKeys.loggedUserID) as? Data,
           let user = try? JSONDecoder().decode(UserData.self, from: data) {
             return user
        }
        return nil
    }
    
    func fectchProfileData(id: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        FirestoreService.shared.getProfileInfo(userId: id) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let profile):
                self.setUser(profile)
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
            
        }
    }
    
    func saveLoginDate() {
        LocalStorageManager.saveUserDefaults(key: ConstantKeys.lastLoginDate, value: Date())
    }
    
    func clearSession() {
        currentUser = nil
        LocalStorageManager.removeUserDefaults(key: ConstantKeys.loggedUserID)
        LocalStorageManager.removeUserDefaults(key: ConstantKeys.lastLoginDate)
    }
    
    
}
