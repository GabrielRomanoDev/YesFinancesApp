//
//  MainViewModel.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 26/05/23.
//

import Foundation
import FirebaseAuth

class MainViewModel {
    
    func loginWithGoogle(completion: @escaping (Result<UserData, Error>) -> Void) {
        AuthenticationManager.shared.loginWithGoogle(completion: completion)
    }
    
}
