//
//  MoreOptionsViewModel.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 26/05/23.
//

import Foundation
import FirebaseAuth

class MoreOptionsViewModel {
    
    func logoutUser()  {
        
        AuthenticationManager.shared.clearSession()
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
        
    }
    
}
