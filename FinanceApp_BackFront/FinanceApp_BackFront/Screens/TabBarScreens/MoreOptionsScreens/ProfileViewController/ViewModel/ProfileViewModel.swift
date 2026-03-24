//
//  ProfileViewModel.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 24/03/26.
//

import Foundation

class ProfileViewModel {

    func deleteAccount(completion: @escaping (Result<Void, Error>) -> Void) {
        AuthenticationManager.shared.deleteCurrentAccount(completion: completion)
    }
}
