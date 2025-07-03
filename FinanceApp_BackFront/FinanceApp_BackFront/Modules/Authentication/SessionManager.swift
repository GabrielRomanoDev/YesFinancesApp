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
           let lastLoginDate = LocalStorageManager.getUserDefaults(key: StorageKeys.lastLoginDate) as? Date {
            
            if lastLoginDate > Date().addingTimeInterval(-604800) {
                currentUser = userLogged
                return true
            }
            
        }

        return false
        
    }
    
    func isUserFullConfigured() -> Bool {
        
        guard let user = currentUser else { return false }
        
        return  (
            isSessionValid() &&
            !user.name.isEmpty &&
            !user.id.isEmpty &&
            !user.email.isEmpty &&
            !user.phoneNumber.number.isEmpty
        )
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
    
    func fectchProfileData(userDTO: UserDataDTO, completion: @escaping (Result<Void, Error>) -> Void) {
        
        if userDTO.registered {
            
            FirestoreService.shared.getProfileInfo(userId: userDTO.id) { [weak self] result in
                
                guard let self = self else { return }
                
                switch result {
                case .success(let profile):
                    self.setUser(profile)
                    completion(.success(()))
                case .failure(let error):
                    self.setUser(UserData(dto: userDTO))
                    completion(.success(()))
                }
                
            }
            
        } else {
            let user = UserData(dto: userDTO)
            self.setUser(user)
            FirestoreService.shared.setObject(user, subCollection: firebaseSubCollectionNames.profile) { result in
                if result == "Success" {
                    completion(.success(()))
                } else {
                    completion(.failure(StringError(message: result)))
                }
                
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
