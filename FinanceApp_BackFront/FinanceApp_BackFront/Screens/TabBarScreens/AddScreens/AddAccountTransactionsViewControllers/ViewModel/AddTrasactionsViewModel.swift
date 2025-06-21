//
//  AddTrasactionsViewModel.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 12/04/23.
//

import Foundation
import UIKit

class AddAccountTransactionsViewModel{
    
    private var service: FirestoreService = FirestoreService(subCollectionName: firebaseSubCollectionNames.transactions)
    
    public var dataSelecionada = Date()
    private var transactionType:TransactionType
    
    init(type: TransactionType) {
        transactionType=type
    }
    
    func addTransaction(transaction: AccountTransaction, completion: @escaping () -> Void) {
        var newTransaction: AccountTransaction = transaction
        
        if newTransaction.desc.isEmptyTest() {
            switch transactionType{
            case .expense:
                newTransaction.desc = CategoriesRepository.shared.expense(newTransaction.categoryIndex).name
                
            case .income:
                newTransaction.desc = CategoriesRepository.shared.income(newTransaction.categoryIndex).name
            }
        }
        
        TransactionsRepository.shared.list.append(newTransaction)
        service.setObject(newTransaction) { result in
            if result != "Success" {
                print(result)
                completion()
                return
            }
            completion()
        }
        
    }
    
    var standardAccountIndex: Int {
        for (index, account) in BankAccountsRepository.shared.list.enumerated() {
            if account.standardAccount == true {
                return index
            }
        }
        return 0
    }
    
    var standardAccountId: String {
        for account in BankAccountsRepository.shared.list {
            if account.standardAccount == true {
                return account.id
            }
        }
        return BankAccountsRepository.shared.list[0].id
    }
    
    func getCategoryLabel(_ indexCategory:Int) -> String {
        switch transactionType{
        case .expense:
            return CategoriesRepository.shared.expense(indexCategory).name
        case .income:
            return CategoriesRepository.shared.income(indexCategory).name
        }
    }
    
    func getCategoryImageName(_ indexCategory:Int) -> UIImage{
        switch transactionType{
        case .expense:
            return UIImage(imageLiteralResourceName: CategoriesRepository.shared.expense(indexCategory).imageName)
        case .income:
            return UIImage(imageLiteralResourceName: CategoriesRepository.shared.income(indexCategory).imageName)
        }
    }
    
    func getCategoryBackgroungColor(_ indexCategory:Int) -> UIColor{
        switch transactionType{
        case .expense:
            return categoryColors[CategoriesRepository.shared.expense(indexCategory).colorIndex] ?? UIColor.cyan
        case .income:
            return categoryColors[CategoriesRepository.shared.income(indexCategory).colorIndex] ?? UIColor.cyan
        }
    }
    
    func getAccountLabel(_ indexAccount:Int) -> String{
        return BankAccountsRepository.shared.list[indexAccount].desc
    }
    
    func getBankLabelText(_ indexAccount:Int) -> String{
        return bankProperties[BankAccountsRepository.shared.list[indexAccount].bank]?.logoTextLabel ?? addStrings.bankText
    }
    
    func getBankLabelTextFont(_ indexAccount:Int) -> UIFont{
        return UIFont.systemFont(ofSize: bankProperties[BankAccountsRepository.shared.list[indexAccount].bank]?.logoTextSize ?? 17, weight: .bold)
    }
    
    func getBankLabelColor(_ indexAccount:Int) -> UIColor{
        return bankProperties[BankAccountsRepository.shared.list[indexAccount].bank]?.labelBankColor ?? .black
    }
    
    func getBankBackColor(_ indexAccount:Int) -> UIColor{
        return bankProperties[BankAccountsRepository.shared.list[indexAccount].bank]?.backgroundColor ?? .gray
    }
    
    
    func datePickerChange(date: Date) -> String {
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        dataSelecionada = date
        
        switch dataSelecionada.toString(format: globalStrings.dateFormat) {
        case today.toString(format: globalStrings.dateFormat):
            return globalStrings.todayText
        case yesterday.toString(format: globalStrings.dateFormat):
            return globalStrings.yesterdayText
        case tomorrow.toString(format: globalStrings.dateFormat):
            return globalStrings.tomorrowText
        default:
            return date.toString(format: globalStrings.dateFormat)
        }
    }
    
    func setValueToString(_ value: Double) -> String {
        var amount: String = String(value)
        if amount.hasSuffix(".0") {
            amount = String(amount.dropLast(2))
        }
        return amount
    }
}
