//
//  MainViewModel.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 26/05/23.
//

import Foundation
import FirebaseAuth

class MainViewModel {
    
    func loginWithGoogle(completion: @escaping (String?) -> Void) {
        
        AuthenticationManager.shared.loginWithGoogle() { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let user):
                completion(nil)
            case .failure(let error):
                let errorMessage = self.getLocalizedErrorMessage(for: error)
                completion(loginStrings.failToLoginErrorMessage + errorMessage)
            }
        }
        
    }
    
    private func getLocalizedErrorMessage(for error: Error?) -> String {
        if let loginError = error as? LoginError {
            switch loginError {
            case .wrongPassword:
                return loginStrings.wrongPasswordError
            case .userNotFound:
                return loginStrings.userNotFoundError
            case .invalidEmail:
                return loginStrings.invalidEmail
            default:
                return loginStrings.followError + (error?.localizedDescription ?? "")
            }
        } else {
            return loginStrings.followError + (error?.localizedDescription ?? "")
        }
    }
    
}
