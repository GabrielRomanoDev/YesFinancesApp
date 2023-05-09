//
//  bankAccounts.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 22/04/23.
//

import Foundation

struct BankAccount {
    var id: String
    var desc : String
    var bank : Banks
    var overdraft: Double
    var standardAccount: Bool
    var obs: String

    public func getBalance() -> Double {
        let filteredTransactions = transactions.filter{ $0.accountId == id}
        return filteredTransactions.reduce(0, {$0 + $1.amount})
    }
    
    public func adjustBalance(newBalance:Double){
        let valueNewTransaction:Double = newBalance - getBalance()
        var transactionType:TransactionType
        
        if valueNewTransaction >= 0{
            transactionType = .income
        } else{
            transactionType = .expense
        }
        
        transactions.append(Transactions(desc: "Ajuste de saldo na Conta", amount: valueNewTransaction, categoryIndex: 0, date: formatDate(date: Date()), type: transactionType, accountId: id, obs: ""))
    }
}

var bankAccountsList : [BankAccount] = [
    BankAccount(id: "account00", desc: "Conta Banco do Brasil", bank: .bancoDoBrasil, overdraft: 100.0, standardAccount: true, obs:""),
    BankAccount(id: "account01", desc: "Conta Bradesco", bank: .bradesco, overdraft: 100.0, standardAccount: false, obs:""),
    BankAccount(id: "account02", desc: "Conta Caixa", bank: .caixa, overdraft: 100.0, standardAccount: false, obs:"")
]
