//
//  AuthenticationManager.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 08/06/25.
//

import Foundation
import FirebaseAuth

class AuthenticationManager {
    
    static let shared = AuthenticationManager()
    
    private let sessionManager = SessionManager()
    private let emailService = EmailAuthService()
    private let googleService = GoogleAuthService()
    private let appleService = AppleAuthService()
    
    private init() {}
    
    func login(email: String, password: String, completion: @escaping (Result<UserData, Error>) -> Void) {
        
        emailService.login(email: email, password: password) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let user):
                self.sessionManager.fetchProfileData(user: user, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
            
        }
        
    }
    
    func loginWithGoogle(completion: @escaping (Result<UserData, Error>) -> Void) {
        
        googleService.login() { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let user):
                self.sessionManager.fetchProfileData(user: user, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
            
        }
        
    }
    
    func register(email: String, password: String, phoneNumber: PhoneNumberData, completion: @escaping (Result<Void, Error>) -> Void) {
        emailService.register(email: email, password: password, phoneNumber: phoneNumber, completion: completion)
    }
    
    func forgetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        emailService.forgetPassword(email: email, completion: completion)
    }
    
    func setCurrentUser(_ user: UserData) {
        sessionManager.setUser(user)
    }
    
    func getCurrentUser() -> UserData? {
        return sessionManager.currentUser
    }
    
    func isSessionValid() -> Bool {
        return sessionManager.isSessionValid()
    }
    
    func clearSession() {
        sessionManager.clearSession()
    }
    
    func updateUserInfo(user: UserData) {
        sessionManager.setUser(user)
        FirestoreService.shared.setObject(user, subCollection: firebaseSubCollectionNames.profile) { result in
            //TODO: Treat error
        }
        
    }
    
}
