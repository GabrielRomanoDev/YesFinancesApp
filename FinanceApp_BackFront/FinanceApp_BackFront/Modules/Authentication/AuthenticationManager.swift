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
            
            switch result {
            case .success(let user):
                self.sessionManager.fectchProfileData(userDTO: user, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
            
        }
        
    }
    
    func loginWithGoogle(completion: @escaping (Result<Void, Error>) -> Void) {
        
        googleService.login() { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let user):
                self.sessionManager.fectchProfileData(userDTO: user) { _ in
                    completion(.success(()))
                }
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
    
    func isUserFullConfigured() -> Bool {
        return sessionManager.isUserFullConfigured()
    }
    
    func isSessionValid() -> Bool {
        return sessionManager.isSessionValid()
    }
    
    func clearSession() {
        sessionManager.clearSession()
    }
    
    func updateUserInfo(user: UserData) {
        sessionManager.currentUser?.name = user.name
        sessionManager.currentUser?.phoneNumber = user.phoneNumber
        sessionManager.currentUser?.photoURL = user.photoURL
        
        FirestoreService.shared.setObject(user, subCollection: firebaseSubCollectionNames.profile) { _ in
            //TODO: Treat error
        }
        
    }
    
}
