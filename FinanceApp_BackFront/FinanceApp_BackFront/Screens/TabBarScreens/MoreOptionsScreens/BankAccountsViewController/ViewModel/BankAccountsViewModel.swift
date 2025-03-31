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
    
    
    func updateAccounts(completion: @escaping () -> Void) {
        service.getObjectsList(forObjectType: BankAccount.self, documentReadName: firebaseSubCollectionNames.bankAccounts) { result in
            switch result {
            case .success(let objectArray):
                BankAccountsRepository.shared.list = objectArray
            case .failure(let error):
                print(error.localizedDescription)
            }
            completion()
        }
    }
    
    func getAccountsCount() -> Int {
        return BankAccountsRepository.shared.list.count
    }
    
    func getAccount(_ index:Int) -> BankAccount {
        if index < BankAccountsRepository.shared.list.count {
            return BankAccountsRepository.shared.list[index]
        } else {
            return BankAccount(desc: "", bank: .bancoDoBrasil, overdraft: 0, standardAccount: false, obs: "")
        }
        
    }
    
    func getCellSize(viewWidth:CGFloat) -> CGSize {
        return CGSize(width: viewWidth - 30, height: 80)
    }
    
    func getCellCornerRadius()-> CGFloat {
        return 10
    }
    
    func getCollectionEdgeInsets()-> UIEdgeInsets {
        return UIEdgeInsets(top: 15, left: 15, bottom: 0, right: 15)
    }
    
    func getNewAccountButtonText() -> String {
        return moreOptionsStrings.newBankAccountButtonTitle
    }
    
    func createNewAccount(_ newAccount: BankAccount, newBalance: Double, completion: @escaping () -> Void) {
        if newAccount.standardAccount {
            clearStandardAccount()
        }
        
        service.setSubCollectionName(firebaseSubCollectionNames.bankAccounts)
        service.setObject(newAccount) { [weak self] result in
            if result != "Success" {
                print(result)
            }
            BankAccountsRepository.shared.list.append(newAccount)
            
            if newBalance != 0{
                self?.service.setSubCollectionName(firebaseSubCollectionNames.transactions)
                self?.adjustBalance(newBalance: newBalance, oldBalance: 0, account: newAccount, completion: completion)
            }
            
            completion()
        }
    }
    
    func editAccount(account: BankAccount, indexAccount: Int, newBalance: Double, completion: @escaping () -> Void) {
        let oldBalance: Double = BankAccountsRepository.shared.list[indexAccount].balance
        
        if account.standardAccount {
            clearStandardAccount()
        }
        
        var updatedAccount = BankAccountsRepository.shared.list[indexAccount]
        updatedAccount.desc = account.desc
        updatedAccount.overdraft = account.overdraft
        updatedAccount.bank = account.bank
        updatedAccount.standardAccount = account.standardAccount
        updatedAccount.obs = account.obs
        
        service.setSubCollectionName(firebaseSubCollectionNames.bankAccounts)
        service.setObject(updatedAccount) { [weak self] result in
            if result != "Success" {
                print(result)
            }
            
            BankAccountsRepository.shared.list[indexAccount] = updatedAccount
            
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
        
        let newTransaction = AccountTransaction(
            desc: "Ajuste de saldo na Conta",
            amount: valueNewTransaction,
            categoryIndex: 0,
            date: Date().toString(format: globalStrings.dateFormat),
            type: transactionType,
            sourceId: account.id,
            obs: "Conta: \(account.desc)"
        )
        
        service.setSubCollectionName(firebaseSubCollectionNames.transactions)
        service.setObject(newTransaction) { result in
            if result != "Success" {
                print(result)
            }
            TransactionsRepository.shared.list.append(newTransaction)
            completion()
        }
    }
    
    func deleteAccount(index: Int, completion: @escaping () -> Void) {
        service.setSubCollectionName(firebaseSubCollectionNames.bankAccounts)
        service.deleteObject(id: BankAccountsRepository.shared.list[index].id) { result in
            if result != "Success" {
                print(result)
            }
            BankAccountsRepository.shared.list.remove(at: index)
            completion()
        }
    }
    
    private func clearStandardAccount() {
        
        for i in 0..<BankAccountsRepository.shared.list.count {
            BankAccountsRepository.shared.list[i].standardAccount = false
            service.updateObjectField(change: ["standardAccount": false], objectID: BankAccountsRepository.shared.list[i].id)
        }
        
    }
    
}
