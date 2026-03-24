//
//  Errors.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 23/06/25.
//

import Foundation

enum LoginError: Error, Equatable {
    case userNotFound
    case wrongPassword
    case invalidEmail
    case missingClientId
    case invalidPresentingViewController
    case tokenError
    case googleLoginFailed(detail: String)
    case firebaseAuthenticationFailed(detail: String)
    case canceled
    case logoutFailed(detail: String)
    case undefined
}
extension LoginError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return loginStrings.userNotFoundError
        case .wrongPassword:
            return loginStrings.wrongPasswordError
        case .invalidEmail:
            return loginStrings.invalidEmail
        case .missingClientId:
            return loginStrings.googleMissingClientIdError
        case .invalidPresentingViewController:
            return loginStrings.googlePresenterError
        case .tokenError:
            return loginStrings.googleTokenError
        case .googleLoginFailed(let detail):
            return loginStrings.googleLoginFailedError + detail
        case .firebaseAuthenticationFailed(let detail):
            return loginStrings.firebaseGoogleLoginFailedError + detail
        case .canceled:
            return loginStrings.googleLoginCanceled
        case .logoutFailed(let detail):
            return loginStrings.googleLogoutFailedError + detail
        case .undefined:
            return loginStrings.undefinedError
        }
    }
}

