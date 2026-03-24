//
//  MoreOptionsViewModel.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 26/05/23.
//

import Foundation

class MoreOptionsViewModel {
    
    func logoutUser(completion: @escaping (Result<Void, Error>) -> Void) {
        AuthenticationManager.shared.logout(completion: completion)
    }
    
}
