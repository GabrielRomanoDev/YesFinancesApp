//
//  AuthService.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 08/06/25.
//

import FirebaseAuth

protocol AuthService {
    func login(email: String, password:  String, completion: @escaping (Result<User, AuthErrorCode>) -> Void)
    func register(email: String, password:  String, completion: @escaping (Result<User, AuthErrorCode>) -> Void)
}
