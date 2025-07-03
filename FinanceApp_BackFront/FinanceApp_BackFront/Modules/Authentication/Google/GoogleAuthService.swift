//
//  GoogleAuthService.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 08/06/25.
//

import Foundation
import GoogleSignIn
import FirebaseAuth
import FirebaseCore

class GoogleAuthService {    
    
    func login(completion: @escaping (Result<UserDataDTO, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(.failure(LoginError.missingClientId))
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        let rootViewController = GoogleSignInHelper.getRootViewController()

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                completion(.failure(self.getLoginError(for: error)))
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                completion(.failure(LoginError.tokenError))
                return
            }
            
            

            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { authResult, error in
                
                guard error == nil, let authResult = authResult else {
                    completion(.failure(self.getLoginError(for: error)))
                    return
                }
                
                if authResult.additionalUserInfo?.isNewUser ?? false {
                    
                    let user = UserDataDTO(
                        id: authResult.user.uid,
                        email: authResult.user.email ?? "",
                        name: authResult.user.displayName ?? "",
                        phoneNumber: nil,
                        photoURL: authResult.user.photoURL,
                        userRegistered: false
                    )
                    
                    completion(.success(user))
                    
                } else {
                    let user = UserDataDTO(
                        id: authResult.user.uid,
                        email: authResult.user.email ?? "",
                        userRegistered: true
                    )
                    
                    completion(.success(user))
                }
                
            }
        }
    }

    /// Faz logout do Firebase e do Google
    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }

    /// Retorna o usuário atual (se estiver logado)
    func getCurrentUser() -> FirebaseAuth.User? {
        return Auth.auth().currentUser
    }
    
    private func getLoginError(for error: Error?) -> Error {
        if let errorCode = (error as NSError?)?.code {
            switch errorCode {
            case AuthErrorCode.wrongPassword.rawValue:
                return LoginError.wrongPassword
            case AuthErrorCode.userNotFound.rawValue:
                return LoginError.userNotFound
            case AuthErrorCode.invalidEmail.rawValue:
                return LoginError.invalidEmail
            default:
                return error ?? LoginError.undefined
            }
        } else {
            return error ?? LoginError.undefined
        }
    }
    
}
