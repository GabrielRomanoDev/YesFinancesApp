//
//  LoginViewModel.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 26/05/23.
//

import Foundation
import Firebase

class LoginViewModel {
    public func loginUser(email: String, password: String, completion: @escaping (String) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if error == nil {
                completion(loginStrings.loginSuccessMessage)
            } else {
                completion(loginStrings.failToLoginErrorMessage + (error?.localizedDescription ?? ""))
            }
        }
    }
}