//
//  RegisterViewModel.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 26/05/23.
//

import Foundation
import FirebaseAuth

class RegisterViewModel {
    
    func createUser(email: String, password: String, completion: @escaping (String) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            
            guard let self = self else { return }
            
            guard error == nil else {
                let errorMessage = self.getLocalizedErrorMessage(for: error)
                completion(registerStrings.failToRegisterErrorMessage + errorMessage)
                return
            }
            
            userLogged = authResult?.user.uid ?? ""
            //self.serviceFirestore.setUser(userLogged)
            
            let profile: Profile = Profile(
                id: userLogged,
                name: email,
                email: password
            )
            
            FirestoreService.shared.setObject(profile, subCollection: firebaseSubCollectionNames.profile) { result in
                if result == "Success" {
                    completion(registerStrings.registerSuccessText)
                } else {
                    completion("\(registerStrings.failToRegisterErrorMessage) \(result)")
                }
                
            }
            
        }
        
    }
    
    private func getLocalizedErrorMessage(for error: Error?) -> String {
        if let errorCode = (error as NSError?)?.code {
            switch errorCode {
            case AuthErrorCode.emailAlreadyInUse.rawValue:
                return registerStrings.emailAlreadyInUse
            default:
                return registerStrings.followError + (error?.localizedDescription ?? "")
            }
        } else {
            return registerStrings.followError + (error?.localizedDescription ?? "")
        }
    }
    
    func checkEmail(email : String) -> Bool{
        let emailRegex = registerStrings.emailRegexFormat
        let emailPredicate = NSPredicate(format: registerStrings.emailPredicatedFormat, emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func checkPassword(password: String) -> Bool {
        return password.count >= 8
    }
    
}

var userLogged: String = "default"
