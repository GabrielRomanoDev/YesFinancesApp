//
//  EmailAuthService.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 08/06/25.
//

import Foundation
import FirebaseAuth

class EmailAuthService {
    
    func login(email: String, password: String, completion: @escaping (Result<UserDataDTO, Error>) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if error == nil {
                let user = UserDataDTO(id: authResult?.user.uid ?? UUID().uuidString, email: email)
                completion(.success(user))
            } else {
                let errorMessage = loginStrings.failToLoginErrorMessage + self.getLocalizedErrorMessage(for: error)
                completion(.failure(StringError(message: errorMessage)))
            }
        }
    }
    
    func register(email: String, password: String, phoneNumber: PhoneNumberData, completion: @escaping (Result<Void, Error>) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            
            guard let self = self else { return }
            
            guard error == nil else {
                let errorMessage = registerStrings.failToRegisterErrorMessage + self.getLocalizedErrorMessage(for: error)
                completion(.failure(StringError(message: errorMessage)))
                return
            }
            
            let userId = authResult?.user.uid ?? "noID"
            
            let profile: UserData = UserData(
                id: userId,
                name: email,
                email: password,
                phoneNumber: phoneNumber
            )
            
            FirestoreService.shared.setObject(profile, subCollection: firebaseSubCollectionNames.profile) { result in
                if result == "Success" {
                    completion(.success(()))
                } else {
                    let errorMessage = "\(registerStrings.failToRegisterErrorMessage) \(result)"
                    completion(.failure(StringError(message: errorMessage)))
                }
                
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
