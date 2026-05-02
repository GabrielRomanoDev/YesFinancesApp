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
            if error == nil {
                let user = UserData(id: authResult?.user.uid ?? UUID().uuidString, name: "", email: email)
                self.completeOnMain(completion, with: .success(user))
            } else {
                let errorMessage = loginStrings.failToLoginErrorMessage + self.getLocalizedErrorMessage(for: error)
                self.completeOnMain(completion, with: .failure(StringError(message: errorMessage)))
            }
        }
    }
    
    func register(email: String, password: String, phoneNumber: PhoneNumberData, completion: @escaping (Result<Void, Error>) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            
            guard let self = self else { return }
            
            guard error == nil else {
                let errorMessage = registerStrings.failToRegisterErrorMessage + self.getLocalizedErrorMessage(for: error)
                self.completeOnMain(completion, with: .failure(StringError(message: errorMessage)))
                return
            }
            
            let userId = authResult?.user.uid ?? "noID"
            
            let profile: UserData = UserData(
                id: userId,
                name: email,
                email: email,
                phoneNumber: phoneNumber,
                infoValidated: true
            )
            
//            Auth.auth().currentUser?.sendEmailVerification { error in
//              
//                if let error = error {
//                    print("Error sendingEmailVerification: \(error).")
//                }
//                
//            }
            
            FirestoreService.shared.setObject(profile, subCollection: firebaseSubCollectionNames.profile) { result in
                if result == "Success" {
                    self.completeOnMain(completion, with: .success(()))
                } else {
                    let errorMessage = "\(registerStrings.failToRegisterErrorMessage) \(result)"
                    self.completeOnMain(completion, with: .failure(StringError(message: errorMessage)))
                }
                
            }
            
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
