//
//  creditCard.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 22/04/23.
//

import Foundation

struct CreditCard: FirestoreObject, Codable, Equatable {
    
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
        let filteredExpenses = CreditCardExpensesRepository.shared.list.filter { expense in
            if let transactionDate = expense.date.toDate() {
                return expense.sourceId == self.id && expense.month == monthDate && expense.paymentStatus != .paid
            }
            return false
        }
        
        return filteredExpenses.reduce(0, { $0 + $1.amount })
    }
    
    func adjustInvoice(newValue: Double) {
        let valueNewTransaction: Double = newValue - invoiceTotal()
        let today = Calendar.current.component(.day, from: Date())
        
        var invoiceMonth = Date().getMonth()
        if today >= closingDay {
            invoiceMonth.nextMonth()
        }
        
        CreditCardExpensesRepository.shared.list.append(CreditCardExpense(
            desc: moreOptionsStrings.updateAccountAmount,
            amount: valueNewTransaction,
            categoryIndex: 0,
            date: Date().toString(format: globalStrings.dateFormat),
            type: .expense,
            paymentStatus: .pendent,
            month: invoiceMonth,
            sourceId: id,
            obs: globalStrings.emptyString
        ))
    }
    
    private func invoiceMonthPeriod(month: MonthDate) -> (Date, Date) {
        var closingDate = Date().setDate(day: self.closingDay, month: month)
        let openingDate = Calendar.current.date(byAdding: .month, value: -1, to: closingDate)!
        closingDate = Calendar.current.date(byAdding: .day, value: -1, to: closingDate)!
        
        return (openingDate, closingDate)
    }
    
    func getInvoice(month: MonthDate) -> Invoice {
        
        let invoiceAmount = self.invoiceTotal(monthDate: month)
        
        let (openingDate, closingDate) = invoiceMonthPeriod(month: month)
        let currentDate = Date()
        let dueDate = Date().setDate(day: self.dueDay, month: month)
        
        var status: PaymentStatus
        
        if currentDate > closingDate {
            
            if abs(invoiceAmount) > 0 {
                
                if currentDate >= dueDate {
                    status = .overdue
                } else {
                    status = .pendent
                }
                
            } else {
                let expensesPaid = CreditCardExpensesRepository.shared.list.first(where: { $0.sourceId == self.id && $0.paymentStatus == .paid }) != nil
                status = expensesPaid ? .paid : .zeroed
            }
            
        } else {
            status = (currentDate >= openingDate) ? .open : .future
        }
        
        return Invoice(
            desc: transactionsStrings.invoiceTitle + " " + self.desc,
            amount: invoiceAmount,
            closingDate: closingDate.toString(),
            dueDate: dueDate.toString(),
            sourceId: self.id,
            paymentStatus: status,
            month: month
        )
        
    }
    
}
