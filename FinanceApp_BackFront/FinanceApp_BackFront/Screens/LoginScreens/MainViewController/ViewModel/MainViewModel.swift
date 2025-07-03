//
//  MainViewModel.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 26/05/23.
//

import Foundation
import FirebaseAuth

class MainViewModel {
    
    func loginWithGoogle(completion: @escaping (Result<Void, Error>) -> Void) {
        
        AuthenticationManager.shared.loginWithGoogle() { result in
            
            switch result {
            case .success():
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
    }
    
}
