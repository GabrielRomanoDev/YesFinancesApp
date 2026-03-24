//
//  MainViewModel.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 26/05/23.
//

import Foundation
import FirebaseAuth
import UIKit

class MainViewModel {
    
    func loginWithGoogle(presentingViewController: UIViewController, completion: @escaping (Result<UserData, Error>) -> Void) {
        AuthenticationManager.shared.loginWithGoogle(presentingViewController: presentingViewController, completion: completion)
    }
    
}
