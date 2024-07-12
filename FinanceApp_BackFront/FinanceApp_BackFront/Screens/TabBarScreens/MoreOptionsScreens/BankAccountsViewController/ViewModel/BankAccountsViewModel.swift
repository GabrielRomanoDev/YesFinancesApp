//
//  BankAccountsViewModel.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 08/05/23.
//

import Foundation
import UIKit
 
class BankAccountsViewModel {
    
    private var service: FirestoreService = FirestoreService(subCollectionName: firebaseSubCollectionNames.bankAccounts)
    
    
    public func updateAccounts(completion: @escaping () -> Void) {
        service.getObjectsList(forObjectType: BankAccount.self, documentReadName: firebaseSubCollectionNames.bankAccounts) { result in
            switch result {
            case .success(let objectArray):
                bankAccountsList = objectArray
            case .failure(let error):
                print(error.localizedDescription)
            }
            completion()
        }
    }
    
    public func getAccountsCount() -> Int {
        return bankAccountsList.count
    }
    
    public func getAccount(_ index:Int) -> BankAccount {
        if index < bankAccountsList.count {
            return bankAccountsList[index]
        } else {
            return BankAccount(desc: "", bank: .bancoDoBrasil, overdraft: 0, standardAccount: false, obs: "")
        }
        
    }
    
    public func getCellSize(viewWidth:CGFloat) -> CGSize {
        return CGSize(width: viewWidth - 30, height: 80)
    }
    
    public func getCellCornerRadius()-> CGFloat {
        return 10
    }
    
    public func getCollectionEdgeInsets()-> UIEdgeInsets {
        return UIEdgeInsets(top: 15, left: 15, bottom: 0, right: 15)
    }
    
    public func getNewAccountButtonText() -> String {
        return moreOptionsStrings.newBankAccountButtonTitle
    }
    
    public func createNewAccount(_ newAccount: BankAccount, newBalance: Double, completion: @escaping () -> Void) {
        if newAccount.standardAccount {
            clearStandardAccount()
        }
        
        service.setSubCollectionName(firebaseSubCollectionNames.bankAccounts)
        service.addObject(newAccount, id: newAccount.getId) { [weak self] result in
            if result != "Success" {
                print(result)
            }
            bankAccountsList.append(newAccount)
            
            if newBalance != 0{
                self?.service.setSubCollectionName(firebaseSubCollectionNames.transactions)
                self?.adjustBalance(newBalance: newBalance, oldBalance: 0, account: newAccount, completion: completion)
            }
            
            completion()
        }
    }
    
    public func editAccount(account: BankAccount, indexAccount: Int, newBalance: Double, completion: @escaping () -> Void) {
        let oldBalance: Double = bankAccountsList[indexAccount].balance
        
        if account.standardAccount {
            clearStandardAccount()
        }
        
        var updatedAccount = bankAccountsList[indexAccount]
        updatedAccount.desc = account.desc
        updatedAccount.overdraft = account.overdraft
        updatedAccount.bank = account.bank
        updatedAccount.standardAccount = account.standardAccount
        updatedAccount.obs = account.obs
        
        service.setSubCollectionName(firebaseSubCollectionNames.bankAccounts)
        service.updateObject(updatedAccount, id: updatedAccount.getId) { [weak self] result in
            if result != "Success" {
                print(result)
            }
            
            bankAccountsList[indexAccount] = updatedAccount
            
            if newBalance != oldBalance {
                self?.adjustBalance(newBalance: newBalance, oldBalance: oldBalance, account: updatedAccount, completion: completion)
            }
            
            completion()
        }
        
    }
    
    private func adjustBalance(newBalance: Double, oldBalance: Double, account: BankAccount, completion: @escaping () -> Void) {
        let valueNewTransaction: Double = newBalance - oldBalance
        var transactionType: TransactionType
        
        if valueNewTransaction >= 0 {
            transactionType = .income
        } else{
            transactionType = .expense
        }
        
        let newTransaction = Transactions(
            desc: "Ajuste de saldo na Conta",
            amount: valueNewTransaction,
            categoryIndex: 0,
            date: Date().toString(format: "dd/MM/yyyy"),
            type: transactionType,
            accountId: account.getId,
            obs: "Conta: \(account.desc)"
        )
        
        service.setSubCollectionName(firebaseSubCollectionNames.transactions)
        service.addObject(newTransaction, id: newTransaction.getId) { result in
            if result != "Success" {
                print(result)
            }
            transactionsList.append(newTransaction)
            completion()
        }
    }
    
    public func deleteAccount(index: Int, completion: @escaping () -> Void) {
        service.setSubCollectionName(firebaseSubCollectionNames.bankAccounts)
        service.deleteObject(id: bankAccountsList[index].getId) { result in
            if result != "Success" {
                print(result)
            }
            bankAccountsList.remove(at: index)
            completion()
        }
    }
    
    private func clearStandardAccount() {
        
        for i in 0..<bankAccountsList.count {
            bankAccountsList[i].standardAccount = false
            service.updateObjectField(change: ["standardAccount":false], objectID: bankAccountsList[i].getId)
        }
        
    }
    
}

var bankAccountsList: [BankAccount] = []
