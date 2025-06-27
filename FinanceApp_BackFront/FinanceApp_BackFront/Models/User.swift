//
//  Profile.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 06/07/23.
//

import Foundation

struct UserData: FirestoreObject {
    let id: String
    var name: String
    var email: String
    
    init(id: String, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
}
