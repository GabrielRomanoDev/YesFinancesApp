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
    
    private var service: FirestoreService = FirestoreService(subCollectionName: firebaseSubCollectionNames.transactions)
    
    @Published var transaction: AccountTransaction
    @Published var sourceIndex: Int = 0
    private var isEditing: Bool
    
    var selectedDate: Date {
        get { self.transaction.date.toDate() ?? Date() }
        set { transaction.date = newValue.toString() }
    }
    
    init(transaction: AccountTransaction?, type: TransactionType) {
        
        if let editingTransaction = transaction {
            self.isEditing = true
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
        
        self.sourceIndex = standardAccountIndex
        setSourceID(index: self.sourceIndex)
        
    }
    
    func screenTitle() -> String {
        switch transaction.type {
        case .income:
            return self.isEditing ? addStrings.incomeTransactionEditTitle : addStrings.incomeTransactionRegisterTitle
        case .expense:
            return self.isEditing ? addStrings.expenseTransactionEditTitle : addStrings.expenseTransactionRegisterTitle
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
            return CategoriesRepository.shared.incomes[transaction.categoryIndex]
        case .expense:
            return CategoriesRepository.shared.expenses[transaction.categoryIndex]
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
    
    func addExpense(completion: @escaping () -> Void) {
        
        var newExpense = self.transaction
        
        if newExpense.desc.isEmptyTest() {
            
            switch newExpense.type {
            case .expense:
                newExpense.desc = CategoriesRepository.shared.expenses[newExpense.categoryIndex].name
            case .income:
                newExpense.desc = CategoriesRepository.shared.incomes[newExpense.categoryIndex].name
            }
            
        }
        
        TransactionsRepository.shared.list.append(self.transaction)
        
        service.setObject(self.transaction) { result in
            
            if result != "Success" {
                print(result)
                //TODO: Adicionar no UserDefaults para sincronizar no futuro
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
    
    func setSourceID(index: Int) {
        transaction.sourceId = BankAccountsRepository.shared.list[index].id
        sourceIndex = index
    }
    
}
