//
//  loginStrings.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 26/05/23.
//

import Foundation

enum loginStrings {
    static let enterButtonTitle = "Entrar"
    static let forgotPasswordButtonTitle = "Esqueceu a Senha"
    static let registerButtonTitle = "Criar Conta"
    
    static let atention = "Atenção"
    static let emptyFieldsErrorMessage = "Um ou mais campos não foram preenchidos!"
    static let loginSuccessMessage = "Login realizado com Sucesso!"
    static let failToLoginErrorMessage = "Falha em realizar login, "
    
    static let userNotFoundError = "Usuário não encontrado."
    static let wrongPasswordError = "Senha incorreta."
    static let invalidEmail = "Formato de email invalido."
    static let undefinedError = "Algo deu errado, tente novamente mais tarde."
    static let followError = "segue o erro "
    static let googleMissingClientIdError = "Não foi possível iniciar o login com Google. Por favor, tente mais tarde."
    static let googlePresenterError = "Não foi possível abrir a tela de login do Google."
    static let googleTokenError = "Não foi possível validar as credenciais da conta Google."
    static let googleLoginFailedError = "Falha ao autenticar com Google. "
    static let firebaseGoogleLoginFailedError = "Falha ao concluir o login com Google no Firebase."
    static let googleLoginCanceled = "Login com Google cancelado."
    static let googleLogoutFailedError = "Falha ao sair da conta Google. "
}
