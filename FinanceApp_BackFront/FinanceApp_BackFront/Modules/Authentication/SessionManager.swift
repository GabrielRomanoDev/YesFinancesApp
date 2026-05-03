//
//  SessionManager.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 08/06/25.
//

import Foundation
import FirebaseAuth

class SessionManager {
    
    var currentUser: UserData?
    
    //Check if last login with password was made before 7 days ago.
    func isSessionValid() -> Bool {
        guard let firebaseUser = Auth.auth().currentUser else {
            clearSession()
            return false
        }
        
        if let currentUser, currentUser.id == firebaseUser.uid {
            return true
        } else if currentUser != nil {
            clearSession()
            return false
        }
        
        if let userLogged = loadUser(),
           let lastLoginDate = LocalStorageManager.getUserDefaults(key: StorageKeys.lastLoginDate) as? Date {
            if lastLoginDate > Date().addingTimeInterval(-604800) {
                if userLogged.id == firebaseUser.uid {
                    currentUser = userLogged
                    return true
                }

                clearSession()
                return false
            }
            
        }

        clearSession()

        return false
        
    }
    
    func setUser(_ user: UserData) {
        if let encoded = try? JSONEncoder().encode(user) {
            currentUser = user
            LocalStorageManager.saveUserDefaults(key:  StorageKeys.loggedUserID, value: encoded)
            saveLoginDate()
        }
        
    }
    
    func loadUser() -> UserData? {
        if let data = LocalStorageManager.getUserDefaults(key: StorageKeys.loggedUserID) as? Data,
           let user = try? JSONDecoder().decode(UserData.self, from: data) {
             return user
        }
        return nil
    }
    
    func fetchProfileData(user: UserData, completion: @escaping (Result<UserData, Error>) -> Void) {
            
        FirestoreService.shared.getProfileInfo(userId: user.id) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let profile):
                self.setUser(profile)
                completion(.success(profile))
            case .failure(let error as FirestoreServiceError):
                switch error {
                case .profileNotFound:
                    self.setUser(user)
                    completion(.success(user))
                }
            case .failure(let error):
                completion(.failure(error))
            }
            
        }
        
    }
    
    func saveLoginDate() {
        LocalStorageManager.saveUserDefaults(key: StorageKeys.lastLoginDate, value: Date())
    }
    
    func clearSession() {
        currentUser = nil
        LocalStorageManager.removeUserDefaults(key: StorageKeys.loggedUserID)
        LocalStorageManager.removeUserDefaults(key: StorageKeys.lastLoginDate)
    }
    
    
}
