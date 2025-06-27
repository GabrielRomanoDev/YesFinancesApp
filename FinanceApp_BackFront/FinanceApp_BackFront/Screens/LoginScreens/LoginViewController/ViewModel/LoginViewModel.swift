//
//  LoginViewModel.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 26/05/23.
//

import Foundation
import FirebaseAuth

class LoginViewModel {
    
    func loginUser(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        
        AuthenticationManager.shared.login(email: email, password: password, completion: completion)
        
    }
    
}
