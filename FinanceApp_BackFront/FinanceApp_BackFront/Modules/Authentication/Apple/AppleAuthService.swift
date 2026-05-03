//
//  AppleAuthService.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 08/06/25.
//

import Foundation
import FirebaseAuth

/// Stub reserved for future Sign in with Apple support.
/// This service is not wired into the active authentication flow yet.
class AppleAuthService: AuthService {
    
    func login(email: String, password: String, completion: @escaping (Result<User, AuthErrorCode>) -> Void) {
        // Future implementation point for Apple authentication.
    }
    
    func register(email: String, password: String, completion: @escaping (Result<User, AuthErrorCode>) -> Void) {
        // Future implementation point for Apple account bootstrap.
    }
    
}
