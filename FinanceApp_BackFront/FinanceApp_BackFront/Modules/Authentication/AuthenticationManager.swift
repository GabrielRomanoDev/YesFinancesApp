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
    
    func login(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        emailService.login(email: email, password: password) { [weak self] result in
            
            guard let self = self else { return }
            
            if case .success(let userId) = result {
                self.sessionManager.fectchProfileData(id: userId, completion: completion)
            }
            
        }
        
    }
    
    func loginWithGoogle(completion: @escaping (Result<Void, Error>) -> Void) {
        
        googleService.login() { [weak self] result in
            
            guard let self = self else { return }
            
            if case .success(let userId) = result {
                self.sessionManager.fectchProfileData(id: userId, completion: completion)
            }
            
        }
        
    }
    
    func register(email: String, password: String, completion: @escaping (String) -> Void) {
        emailService.register(email: email, password: password, completion: completion)
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
        sessionManager.currentUser?.name = user.name
        
        FirestoreService.shared.setObject(user, subCollection: firebaseSubCollectionNames.profile) { _ in
            //TODO: Treat error
        }
        
    }
    
}
