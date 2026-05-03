//
//  TransactionFormViewModel.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 21/04/25.
//

import Foundation
import UIKit
import SwiftUI

class TransactionFormViewModel: ObservableObject {
    
    @Published var transaction: AccountTransaction
    @Published var sourceIndex: Int = 0
    var isEditing: Bool
    var isInvoicePayment: Bool
    
    var selectedDate: Date {
        get { self.transaction.date.toDate() ?? Date() }
        set { transaction.date = newValue.toString() }
    }
    
    init(transaction: AccountTransaction?, isInvoicePayment: Bool, type: TransactionType) {
        
        if let editingTransaction = transaction {
            self.isEditing = !isInvoicePayment ? true : false
            self.transaction = editingTransaction
        } else {
            self.isEditing = false
            self.transaction = AccountTransaction(
                desc: globalStrings.emptyString,
                amount: 0,
                categoryIndex: 0,
                date: Date().toString(),
                type: type,
                isMonthly: false,
                sourceId: "",
                obs: globalStrings.emptyString
            )
        }
        
        self.isInvoicePayment = isInvoicePayment
        self.sourceIndex = standardAccountIndex
        self.setSourceID(index: self.sourceIndex)
        
    }
    
    func screenTitle() -> String {
        
        if isInvoicePayment {
            return addStrings.invoicePaymentTitle
        } else {
            switch transaction.type {
            case .income:
                return self.isEditing ? addStrings.incomeTransactionEditTitle : addStrings.incomeTransactionRegisterTitle
            case .expense:
                return self.isEditing ? addStrings.expenseTransactionEditTitle : addStrings.expenseTransactionRegisterTitle
            }
        }
        
    }
    
    func screenTitleBackgroundColor() -> Color {
        switch transaction.type {
        case .income:
            return Color.greenAddIncomes
        case .expense:
            return Color.redAddExpenses
        }
    }
    
    func selectedCategory() -> TransactionCategory {
        switch transaction.type {
        case .income:
            return CategoriesRepository.shared.income(transaction.categoryIndex)
        case .expense:
            return CategoriesRepository.shared.expense(transaction.categoryIndex)
        }
    }
    
    func categories() -> [TransactionCategory] {
        switch transaction.type {
        case .income:
            return CategoriesRepository.shared.incomes
        case .expense:
            return CategoriesRepository.shared.expenses
        }
    }
    
    func saveExpense(completion: @escaping () -> Void) {
        
        var finalTransaction = self.transaction
        
        if finalTransaction.desc.isEmptyTest() {
            
            switch finalTransaction.type {
            case .expense:
                finalTransaction.desc = CategoriesRepository.shared.expense(finalTransaction.categoryIndex).name
            case .income:
                finalTransaction.desc = CategoriesRepository.shared.income(finalTransaction.categoryIndex).name
            }
            
        }

        self.transaction = finalTransaction
        
        if isEditing {
            
            if let index = TransactionsRepository.shared.list.firstIndex(where: {$0.id == self.transaction.id} ) {
                TransactionsRepository.shared.list[index] = finalTransaction
            }
             
        } else {
            TransactionsRepository.shared.list.append(finalTransaction)
        }
        
        FirestoreService.shared.setObject(finalTransaction, subCollection: firebaseSubCollectionNames.transactions) { result in
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .updateTransactionsData, object: nil)
                
                if case .failure(let error) = result {
                    print(error.localizedDescription)
                    //TODO: Adicionar no UserDefaults para sincronizar no futuro
                    completion()
                    return
                }
                completion()
            }
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
    
    func setSourceID(index: Int) {
        transaction.sourceId = BankAccountsRepository.shared.list[index].id
        sourceIndex = index
    }
    
}
