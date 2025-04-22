//
//  AddStrings.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 27/05/23.
//

import Foundation

enum addStrings {
    static let accountIncomeButtonTitle = "Receita na Conta"
    static let accountExpenseButtonTitle = "Despesa na Conta"
    static let cardExpenseButtonTitle = "Despesa no Cartão"
    
    static let accountIncomeRegisterText = "Cadastro de Receita"
    static let accountExpenseRegisterText = "Cadastro de Despesa"
    static let cardExpenseRegisterText = "Cadastro de Gasto no Cartão"
    static let descriptionText = "Descrição"
    static let valueText = "Valor"
    static let observationsText = "Observações"
    static let registerTransactionButtonTitle = "Enviar"
    
    static let forgotIncomeAmountValue = "Opa, esqueceu de informar valor recebido!"
    static let forgotExpenseAmountValue = "Opa, esqueceu de informar valor gasto!"
    static let amountMustBeHigherThenZero = "Opa, informe um valor positivo!"
    
    static let bankText = "Banco"
    static let incomeTransactionRegisterTitle = "Cadastro de Receita"
    static let expenseTransactionRegisterTitle = "Cadastro de Despesa"
    static let incomeTransactionEditTitle = "Editar de Receita"
    static let expenseTransactionEditTitle = "Editar de Despesa"
    static let creditCardExpenseRegisterTitle = "Cadastro de Despesa no Cartão"
    static let descriptionPlaceholder = "Descrição"
    static let selectDateButtonTitle = "Selecionar data"
    static let installmentLabel = "Parcelamento"
    static let fixedExpenseLabel = "Despesa Fixa"
    static let dividedInto = "Numero de Parcelas:"
    static let invoiceOf = "Fatura de"
    static let currentInstallment = "Parcela atual:"
    static let missingAmountErrorMessage = "Esqueceu de informar o valor da despesa!"
    static let missingDescriptionErrorMessage = "Esqueceu de informar a descrição da despesa! Deseja continuar assim mesmo?"

    static let observationsPlaceholder = "Observações"
    
    static let bankAccountsTitle = "Contas Bancárias"
    static let creditCardsTitle = "Cartões de Credito"
    
    static func firstInstallmentText(amount: String, installmentTotal: Int) -> String {
        return "Um total de \(installmentTotal) parcelas no valor de \(amount)."
    }
    
    static func intermediateInstallmentText(amount: String, currentInstallment: Int) -> String {
        return "A \(currentInstallment)ª parcela no valor de \(amount)."
    }
    
    static func lastInstallmentText(amount: String) -> String {
        return "A ultima parcela no valor de \(amount)."
    }
    
}
