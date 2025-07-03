//
//  RegisterViewModel.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 26/05/23.
//

import Foundation
import FirebaseAuth

class RegisterViewModel {
    
    func createUser(email: String, password: String, phoneNumber: PhoneNumberData, completion: @escaping (Result<Void, any Error>) -> Void) {
        AuthenticationManager.shared.register(email: email, password: password, phoneNumber: phoneNumber, completion: completion)
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
