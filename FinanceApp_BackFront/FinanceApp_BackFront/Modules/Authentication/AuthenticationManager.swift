//
//  AuthenticationManager.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 08/06/25.
//

import Foundation
import FirebaseAuth
import UIKit

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
    
    func loginWithGoogle(presentingViewController: UIViewController, completion: @escaping (Result<UserData, Error>) -> Void) {
        
        googleService.login(presentingViewController: presentingViewController) { [weak self] result in
            
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

    func logout(completion: @escaping (Result<Void, Error>) -> Void) {
        googleService.signOut { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success:
                self.sessionManager.clearSession()
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func deleteCurrentAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentFirebaseUser = Auth.auth().currentUser else {
            sessionManager.clearSession()
            completion(.failure(StringError(message: "Nenhum usuário autenticado foi encontrado.")))
            return
        }

        let userId = currentFirebaseUser.uid
        
        currentFirebaseUser.delete { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(self.accountDeletionError(from: error)))
                return
            }
            
            FirestoreService.shared.deleteUserData(userId: userId) { firestoreResult in
                switch firestoreResult {
                case .success:
                    self.googleService.signOut { signOutResult in
                        switch signOutResult {
                        case .success:
                            self.sessionManager.clearSession()
                            completion(.success(()))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func updateUserInfo(user: UserData) {
        sessionManager.setUser(user)
        FirestoreService.shared.setObject(user, subCollection: firebaseSubCollectionNames.profile) { result in
            //TODO: Treat error
        }
        
    }

    private func accountDeletionError(from error: Error) -> Error {
        guard let authError = error as NSError? else {
            return error
        }
        
        if authError.code == AuthErrorCode.requiresRecentLogin.rawValue {
            return StringError(message: "Para excluir sua conta, faça login novamente e tente de novo.")
        }
        
        return error
    }
    
}
