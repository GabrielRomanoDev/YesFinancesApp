//
//  MainViewModel.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 26/05/23.
//

import Foundation
import FirebaseAuth

class MainViewModel {
    
    func loginWithGoogle(completion: @escaping (String) -> Void) {
        
        GoogleAuthService.shared.signInWithGoogle() { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let user):
                print("User: \(user)")
                userLogged = user.uid
                completion(loginStrings.loginSuccessMessage)
            case .failure(let error):
                let errorMessage = self.getLocalizedErrorMessage(for: error)
                userLogged = "user_Error"
                completion(loginStrings.failToLoginErrorMessage + errorMessage)
            }
        }
        
    }
    
    private func getLocalizedErrorMessage(for error: Error?) -> String {
        if let errorCode = (error as NSError?)?.code {
            switch errorCode {
            case AuthErrorCode.wrongPassword.rawValue:
                return loginStrings.wrongPasswordError
            case AuthErrorCode.userNotFound.rawValue:
                return loginStrings.userNotFoundError
            case AuthErrorCode.invalidEmail.rawValue:
                return loginStrings.invalidEmail
            default:
                return loginStrings.followError + (error?.localizedDescription ?? "")
            }
        } else {
            return loginStrings.followError + (error?.localizedDescription ?? "")
        }
    }
    
}
