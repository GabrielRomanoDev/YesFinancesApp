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
    
    // Active production flow uses email/google providers plus local session orchestration.
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
    
    func register(name: String, email: String, password: String, phoneNumber: PhoneNumberData, completion: @escaping (Result<UserData, Error>) -> Void) {
        
        emailService.register(email: email, password: password) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let userId):
                let profile = UserData(
                    id: userId,
                    name: name,
                    email: email,
                    phoneNumber: phoneNumber
                )
                
                FirestoreService.shared.setObject(
                    profile,
                    userId: userId,
                    subCollection: firebaseSubCollectionNames.profile
                ) { firestoreResult in
                    switch firestoreResult {
                    case .success:
                        self.sessionManager.setUser(profile)
                        completion(.success(profile))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
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
        
        FirestoreService.shared.deleteUserData(userId: userId) { [weak self] firestoreResult in
            guard let self = self else { return }

            switch firestoreResult {
            case .success:
                currentFirebaseUser.delete { error in
                    if let error {
                        completion(.failure(self.accountDeletionError(from: error)))
                        return
                    }

                    self.googleService.signOut { signOutResult in
                        self.sessionManager.clearSession()
                        
                        switch signOutResult {
                        case .success:
                            completion(.success(()))
                        case .failure:
                            completion(.success(()))
                        }
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func updateUserInfo(user: UserData, completion: @escaping (Result<UserData, Error>) -> Void) {
        FirestoreService.shared.setObject(
            user,
            userId: user.id,
            subCollection: firebaseSubCollectionNames.profile
        ) { result in
            switch result {
            case .success:
                self.sessionManager.setUser(user)
                completion(.success(user))
            case .failure(let error):
                completion(.failure(error))
            }
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
