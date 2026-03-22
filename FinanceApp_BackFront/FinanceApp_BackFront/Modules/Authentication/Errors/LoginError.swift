
//
//  Errors.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 23/06/25.
//

enum LoginError: Error {
    case userNotFound
    case wrongPassword
    case invalidEmail
    case missingClientId
    case tokenError
    case canceled
    case undefined
}
