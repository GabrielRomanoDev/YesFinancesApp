//
//  creditCard.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 22/04/23.
//

import Foundation

struct CreditCard: Codable, Equatable {
    
    private(set) var id: String = UUID().uuidString
    var desc: String
    var limit: Double
    var bank: Banks
    var closingDay: Int
    var dueDay: Int
    var standardCard: Bool
    var obs: String
    
    init(desc: String, limit: Double, bank: Banks, closingDay: Int, dueDay: Int, standardCard: Bool, obs: String) {
        self.desc = desc
        self.limit = limit
        self.bank = bank
        self.closingDay = closingDay
        self.dueDay = dueDay
        self.standardCard = standardCard
        self.obs = obs
    }
    
    func invoiceTotal(monthDate: MonthDate = Date().getMonth()) -> Double {
        var endDate = Date().setDate(day: closingDay, month: monthDate)
        var startDate = Calendar.current.date(byAdding: .month, value: -1, to: endDate)!
        endDate = Calendar.current.date(byAdding: .day, value: -1, to: endDate)!
        
        
        let filteredExpenses = CreditCardExpensesRepository.shared.list.filter { expense in
            if let transactionDate = expense.date.toDate() {
                return expense.sourceId == self.id && transactionDate >= startDate && transactionDate <= endDate
            }
            return false
        }
        
        return filteredExpenses.reduce(0, { $0 + $1.amount })
    }
    
    func adjustInvoice(newValue: Double) {
        let valueNewTransaction: Double = newValue - invoiceTotal()
        
        CreditCardExpensesRepository.shared.list.append(CreditCardExpense(
            desc: moreOptionsStrings.updateAccountAmount,
            amount: valueNewTransaction,
            categoryIndex: 0,
            date: Date().toString(format: globalStrings.dateFormat),
            type: .expense,
            sourceId: id,
            paymentStatus: .pendent,
            invoiceMonth: Date().getMonth(),
            obs: globalStrings.emptyString
        ))
    }
    
    
    
    func getInvoice(month: MonthDate) -> Invoice {
        return Invoice(
            desc: transactionsStrings.invoiceTitle + " " + self.desc,
            amount: self.invoiceTotal(monthDate: month),
            closingDate: Date().setDate(day: self.closingDay, month: month).toString(),//card.closingDay.getNextDate().toString(),
            dueDate: Date().setDate(day: self.dueDay, month: month).toString(),
            sourceId: self.id,
            paymentStatus: .future,
            month: month
        )
        
    }
    
}
