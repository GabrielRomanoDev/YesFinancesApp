//
//  StringError.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 30/06/25.
//

import Foundation

struct StringError: LocalizedError {
    let message: String

    var errorDescription: String? {
        return message
    }
}
