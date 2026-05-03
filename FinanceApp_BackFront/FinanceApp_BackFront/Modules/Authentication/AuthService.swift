//
//  AuthService.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 08/06/25.
//

import FirebaseAuth

/// Planned authentication abstraction.
/// The current active app flow is coordinated directly by `AuthenticationManager`
/// with `EmailAuthService`, `GoogleAuthService`, and `SessionManager`.
/// Keep this protocol only as a placeholder until alternative providers adopt
/// the same contract as the production flow.
protocol AuthService {
    func login(email: String, password:  String, completion: @escaping (Result<User, AuthErrorCode>) -> Void)
    func register(email: String, password:  String, completion: @escaping (Result<User, AuthErrorCode>) -> Void)
}
