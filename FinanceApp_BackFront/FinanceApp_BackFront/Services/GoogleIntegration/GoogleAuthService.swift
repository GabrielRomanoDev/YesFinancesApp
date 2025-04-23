//
//  GoogleAuthService.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 22/04/25.
//

import Foundation
import GoogleSignIn
import FirebaseAuth
import FirebaseCore

class GoogleAuthService {

    static let shared = GoogleAuthService()

    private init() {}

    /// Faz login com a conta Google e autentica no Firebase.
    func signInWithGoogle(completion: @escaping (Result<User, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(.failure(NSError(domain: "MissingClientID", code: 0)))
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        let rootViewController = GoogleSignInHelper.getRootViewController()

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                completion(.failure(NSError(domain: "TokenError", code: 0)))
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    completion(.failure(error))
                } else if let user = authResult?.user {
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
    func getCurrentUser() -> User? {
        return Auth.auth().currentUser
    }
}
