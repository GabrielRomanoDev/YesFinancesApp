//
//  RegisterCardExpViewModel.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 25/04/23.
//

import Foundation
import UIKit
import SwiftUI

class RegisterCardExpViewModel: ObservableObject {
    
    private var service: FirestoreService = FirestoreService(subCollectionName: firebaseSubCollectionNames.creditCardExpenses)
    
    @Published var expense: CreditCardExpense
    @Published var cardIndex: Int = 0
    
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
    
    init(expense: CreditCardExpense) {
        self.expense = expense
        self.cardIndex = standardCardIndex
        setSourceID(index: self.cardIndex)
    }
    
    var formattedInstallmentValue: String {
        guard expense.installment.total > 0 else { return "0,00" }
        
        if expense.installment.current == expense.installment.total {
            return "A ultima parcela no valor de \(abs(expense.amount / Double(expense.installment.total)).toStringMoney())."
        } else if expense.installment.current > 1 {
            
            if expense.installment.total - expense.installment.current > 1 {
                return "A \(expense.installment.current)ª parcela de \(abs(expense.amount / Double(expense.installment.total)).toStringMoney()). Restam mais \(expense.installment.total - expense.installment.current) parcelas."
            } else {
                return "A \(expense.installment.current)ª parcela de \(abs(expense.amount / Double(expense.installment.total)).toStringMoney()). Resta somente mais uma parcela."
            }
            
        } else {
            return "Um total de \(expense.installment.total) parcelas de \(abs(expense.amount / Double(expense.installment.total)).toStringMoney())."
        }
        
    }
    
    func handleSubmit(completion: @escaping () -> Void) {
        if expense.installment.total < 2 {
            expense.installment.enabled = false
        } else {
            expense.amount = expense.amount / Double(expense.installment.total)
        }
        
        addExpense(expense: expense) {
            completion()
        }
    }
    
    private func addExpense(expense: CreditCardExpense, completion: @escaping () -> Void) {
        
        var baseExpense = expense
        
        if baseExpense.desc.isEmptyTest() {
            baseExpense.desc = CategoriesRepository.shared.expenses[baseExpense.categoryIndex].name
        }
        
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
        
        service.setObjectsList(objects: newExpenses) { result in
            if result != "Success" {
                print(result)
                //TODO: Adicionar no UserDefaults para sincronizar no futuro
                completion()
                return
            }
            completion()
        }
        
        completion()
        
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
        cardIndex = index
    }
    
}
