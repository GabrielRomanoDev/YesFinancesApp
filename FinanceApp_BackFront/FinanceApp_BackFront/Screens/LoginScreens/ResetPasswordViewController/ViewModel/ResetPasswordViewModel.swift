//
//  ResetPasswordViewModel.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 14/07/25.
//
import Foundation
import FirebaseAuth

class ResetPasswordViewModel {
    
    func sendResetPasswordEmail(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        AuthenticationManager.shared.forgetPassword(email: email, completion: completion)
    }
    
}
