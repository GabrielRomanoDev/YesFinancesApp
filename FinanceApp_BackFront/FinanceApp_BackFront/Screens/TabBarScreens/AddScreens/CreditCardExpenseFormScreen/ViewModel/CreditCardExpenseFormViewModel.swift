//
//  RegisterCardExpViewModel.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 25/04/23.
//

import Foundation
import UIKit
import SwiftUI

class CreditCardExpenseFormViewModel: ObservableObject {
    
    @Published var expense: CreditCardExpense
    @Published var cardIndex: Int = 0
    var isEditing: Bool
    
    var selectedDate: Date {
        get { self.expense.date.toDate() ?? Date() }
        set { expense.date = newValue.toString() }
    }
    
    var installmentBinding: Binding<Bool> {
        Binding(
            get: { self.expense.installment.enabled},
            set: { newValue in
                self.expense.installment.enabled = newValue
                if newValue {
                    self.expense.isMonthly = false
                }
            }
        )
    }

    var monthlyBinding: Binding<Bool> {
        Binding(
            get: { self.expense.isMonthly },
            set: { newValue in
                self.expense.isMonthly = newValue
                if newValue {
                    self.expense.installment.enabled = false
                }
            }
        )
    }
    
    init(expense: CreditCardExpense?) {
        
        if let editingExpense = expense {
            self.isEditing = true
            self.expense = editingExpense
            
            let index = CreditCardsRepository.shared.list.firstIndex(where: {$0.id == editingExpense.sourceId})
            setSourceID(index: index ?? self.standardCardIndex)
        } else {
            self.isEditing = false
            self.expense = CreditCardExpense(
                desc: globalStrings.emptyString,
                amount: 0,
                categoryIndex: 0,
                date: Date().toString(),
                type: .expense,
                isMonthly: false,
                paymentStatus: .pendent,
                month: Date().getMonth(),
                installment: Installment(),
                sourceId: "",
                obs: globalStrings.emptyString
            )
            
            self.cardIndex = self.standardCardIndex
            setSourceID(index: self.cardIndex)
        }
        
    }
    
    var formattedInstallmentValue: String {
        guard expense.installment.total > 0 else { return "0,00" }
        
        let amount = isEditing ? expense.amount : abs(expense.amount / Double(expense.installment.total))
        
        if expense.installment.current == expense.installment.total {
            return addStrings.lastInstallmentText(amount: amount.toStringMoney())
        } else if expense.installment.current > 1 {
            return addStrings.intermediateInstallmentText(amount: amount.toStringMoney(), currentInstallment: expense.installment.current)
        } else {
            return addStrings.firstInstallmentText(amount: amount.toStringMoney(), installmentTotal: expense.installment.total)
        }
        
    }
    
    func handleSubmit(completion: @escaping () -> Void) {
        if !isEditing {
            if expense.installment.total < 2 {
                expense.installment.enabled = false
            } else {
                expense.amount = expense.amount / Double(expense.installment.total)
            }
        }
        
        saveExpense() {
            completion()
        }
    }
    
    private func saveExpense(completion: @escaping () -> Void) {
        
        var baseExpense = self.expense
        
        if baseExpense.desc.isEmptyTest() {
            baseExpense.desc = CategoriesRepository.shared.expense(baseExpense.categoryIndex).name
        }
        
        if isEditing {
            
            if let index = CreditCardExpensesRepository.shared.list.firstIndex(where: {$0.id == self.expense.id}) {
                CreditCardExpensesRepository.shared.list[index] = baseExpense
                
                FirestoreService.shared.setObject(baseExpense, subCollection: firebaseSubCollectionNames.creditCardExpenses) { result in
                    if result != "Success" {
                        print(result)
                        //TODO: Adicionar no UserDefaults para sincronizar no futuro
                        completion()
                        return
                    }
                    completion()
                }
            }
            
        } else {
            
            let totalInstallments = baseExpense.installment.total - baseExpense.installment.current + 1
            var currentMonth = baseExpense.month
            
            let newExpenses: [CreditCardExpense] = (0..<totalInstallments).map { index in
                
                var installmentExpense = CreditCardExpense(
                    desc: baseExpense.desc,
                    amount: baseExpense.amount,
                    categoryIndex: baseExpense.categoryIndex,
                    date: baseExpense.date,
                    type: baseExpense.type,
                    isMonthly: baseExpense.isMonthly,
                    paymentStatus: baseExpense.paymentStatus,
                    month: baseExpense.month,
                    installment: baseExpense.installment,
                    sourceId: baseExpense.sourceId,
                    obs: baseExpense.obs
                )
                
                installmentExpense.installment.current += index
                installmentExpense.month = currentMonth
                
                if var date = installmentExpense.date.toDate() {
                    date.setMonth(month: currentMonth)
                    installmentExpense.date = date.toString()
                }
                
                if index < totalInstallments - 1 {
                    currentMonth.nextMonth()
                }
                
                return installmentExpense
            }
            
            CreditCardExpensesRepository.shared.list.append(contentsOf: newExpenses)
            
            FirestoreService.shared.setObjectsList(objects: newExpenses, subCollection: firebaseSubCollectionNames.creditCardExpenses) { result in
                if result != "Success" {
                    print(result)
                    //TODO: Adicionar no UserDefaults para sincronizar no futuro
                    completion()
                    return
                }
                completion()
            }
            
        }
        
    }
    
    var standardCardIndex: Int {
        for (index, card) in CreditCardsRepository.shared.list.enumerated(){
            if card.standardCard == true {
                return index
            }
        }
        return 0
    }
    
    func setSourceID(index: Int) {
        expense.sourceId = CreditCardsRepository.shared.list[index].id
        
        let currentDay = Calendar.current.component(.day, from: Date())
        
        var month = Date().getMonth()
        
        if CreditCardsRepository.shared.list[index].closingDay < currentDay {
            month.nextMonth()
        }
        
        expense.month = month
        cardIndex = index
    }
    
}
