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
    
    func login(completion: @escaping (Result<UserData, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("failure 1")
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
                print("failure 3 \(LoginError.tokenError)")
                completion(.failure(LoginError.tokenError))
                return
            }
            
            

            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { authResult, error in
                
                guard error == nil, let authResult = authResult else {
                    print("failure 4 \(self.getLoginError(for: error))")
                    completion(.failure(self.getLoginError(for: error)))
                    return
                }
                
                if authResult.additionalUserInfo?.isNewUser ?? false {
                    
                    let user = UserData(
                        id: authResult.user.uid,
                        name: authResult.user.displayName ?? "",
                        email: authResult.user.email ?? "",
                        phoneNumber: nil,
                        photoURL: authResult.user.photoURL,
                    )
                    
                    completion(.success(user))
                    
                } else {
                    let user = UserData(
                        id: authResult.user.uid,
                        name: authResult.user.displayName ?? "",
                        email: authResult.user.email ?? "",
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
        if let err = (error as NSError?) {
            
            switch err.code {
            case GIDSignInError.canceled.rawValue:
                return LoginError.canceled
            default:
                return error ?? LoginError.undefined
            }
            
        } else {
            return error ?? LoginError.undefined
        }
    }
    
}
