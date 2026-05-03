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
import UIKit

class GoogleAuthService {    

    private func completeOnMain<T>(_ completion: @escaping (Result<T, Error>) -> Void, with result: Result<T, Error>) {
        DispatchQueue.main.async {
            completion(result)
        }
    }
    
    func login(presentingViewController: UIViewController, completion: @escaping (Result<UserData, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completeOnMain(completion, with: .failure(LoginError.missingClientId))
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        let activePresenter = ApplicationViewControllerResolver.getTopViewController() ?? presentingViewController

        guard activePresenter.viewIfLoaded?.window != nil else {
            completeOnMain(completion, with: .failure(LoginError.invalidPresentingViewController))
            return
        }

        GIDSignIn.sharedInstance.signIn(withPresenting: activePresenter) { result, error in
            if let error = error {
                self.completeOnMain(completion, with: .failure(self.getGoogleLoginError(for: error)))
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                self.completeOnMain(completion, with: .failure(LoginError.tokenError))
                return
            }
            
            

            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { authResult, error in
                
                guard error == nil, let authResult = authResult else {
                    self.completeOnMain(completion, with: .failure(self.getFirebaseAuthenticationError(for: error)))
                    return
                }
                
                let user = UserData(
                    id: authResult.user.uid,
                    name: authResult.user.displayName ?? "",
                    email: authResult.user.email ?? "",
                    phoneNumber: nil,
                    photoURL: authResult.user.photoURL
                )
                
                self.completeOnMain(completion, with: .success(user))
                
            }
        }
    }

    /// Faz logout do Firebase e do Google
    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            completeOnMain(completion, with: .success(()))
        } catch {
            completeOnMain(completion, with: .failure(LoginError.logoutFailed(detail: error.localizedDescription)))
        }
    }

    /// Retorna o usuário atual (se estiver logado)
    func getCurrentUser() -> FirebaseAuth.User? {
        return Auth.auth().currentUser
    }
    
    private func getGoogleLoginError(for error: Error?) -> Error {
        if let err = (error as NSError?) {
            
            switch err.code {
            case GIDSignInError.canceled.rawValue:
                return LoginError.canceled
            default:
                return LoginError.googleLoginFailed(detail: err.localizedDescription)
            }
            
        } else {
            return LoginError.undefined
        }
    }

    private func getFirebaseAuthenticationError(for error: Error?) -> Error {
        guard let error = error as NSError? else {
            return LoginError.undefined
        }

        switch error.code {
        case AuthErrorCode.invalidCredential.rawValue:
            return LoginError.tokenError
        case AuthErrorCode.userDisabled.rawValue:
            return LoginError.firebaseAuthenticationFailed(detail: error.localizedDescription)
        case AuthErrorCode.operationNotAllowed.rawValue:
            return LoginError.firebaseAuthenticationFailed(detail: error.localizedDescription)
        default:
            return LoginError.firebaseAuthenticationFailed(detail: error.localizedDescription)
        }
    }
    
}
