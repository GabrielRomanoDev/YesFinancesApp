//
//  EmailAuthService.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 08/06/25.
//

import Foundation
import FirebaseAuth

class EmailAuthService {

    private func completeOnMain<T>(_ completion: @escaping (Result<T, Error>) -> Void, with result: Result<T, Error>) {
        DispatchQueue.main.async {
            completion(result)
        }
    }
    
    func login(email: String, password: String, completion: @escaping (Result<UserData, Error>) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error {
                let errorMessage = loginStrings.failToLoginErrorMessage + self.getLocalizedErrorMessage(for: error)
                self.completeOnMain(completion, with: .failure(StringError(message: errorMessage)))
                return
            }

            guard let userId = authResult?.user.uid else {
                self.completeOnMain(
                    completion,
                    with: .failure(StringError(message: loginStrings.followError + "UID do usuário não foi encontrado."))
                )
                return
            }

            let user = UserData(id: userId, name: "", email: email)
            self.completeOnMain(completion, with: .success(user))
        }
    }
    
    func register(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            
            guard let self = self else { return }
            
            guard error == nil else {
                let errorMessage = registerStrings.failToRegisterErrorMessage + self.getLocalizedErrorMessage(for: error)
                self.completeOnMain(completion, with: .failure(StringError(message: errorMessage)))
                return
            }
            
//            Auth.auth().currentUser?.sendEmailVerification { error in
//              
//                if let error = error {
//                    print("Error sendingEmailVerification: \(error).")
//                }
//                
//            }

            guard let userId = authResult?.user.uid else {
                let errorMessage = registerStrings.failToRegisterErrorMessage + " UID do usuário não foi encontrado."
                self.completeOnMain(completion, with: .failure(StringError(message: errorMessage)))
                return
            }

            self.completeOnMain(completion, with: .success(userId))
            
        }
        
    }
    
    func setProfileinStorage() {
        
    }
    
    func forgetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                self.completeOnMain(completion, with: .failure(error))
            } else {
                self.completeOnMain(completion, with: .success(()))
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
            case AuthErrorCode.emailAlreadyInUse.rawValue:
                return registerStrings.emailAlreadyInUse
            default:
                return loginStrings.followError + (error?.localizedDescription ?? "")
            }
        } else {
            return loginStrings.followError + (error?.localizedDescription ?? "")
        }
    }
    
}
