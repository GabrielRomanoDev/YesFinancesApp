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
    
    var currentInvoiceTotal: Double {
        var endDate = getNextDateFor(day: closingDay)!
        var startDate = Calendar.current.date(byAdding: .month, value: -1, to: endDate)!
        endDate = Calendar.current.date(byAdding: .day, value: -1, to: endDate)!
        
        
        let filteredExpenses = CreditCardExpensesRepository.shared.list.filter { expense in
            if let transactionDate = expense.date.toDate() {
                return expense.sourceId == id && transactionDate >= startDate && transactionDate <= endDate
            }
            return false
        }
        
        return filteredExpenses.reduce(0, { $0 + $1.amount })
    }
    
    func printStartAndEndDates() {
        var endDate = getNextDateFor(day: closingDay)!
        var startDate = Calendar.current.date(byAdding: .month, value: -1, to: endDate)!
        endDate = Calendar.current.date(byAdding: .day, value: -1, to: endDate)!
        
        print("Gastos entre \(startDate.toString()) e \(endDate.toString()) serão fechados no dia \(getNextDateFor(day: closingDay)!.toString())")
    }
    
    var nextDueDate: Date {
        return getNextDateFor(day: dueDay)!
    }
    
    func adjustInvoice(newInvoice: Double) {
        let valueNewTransaction: Double = newInvoice - currentInvoiceTotal
        let transactionType: TransactionType = valueNewTransaction >= 0 ? .income : .expense
        
        CreditCardExpensesRepository.shared.list.append(CreditCardExpense(
            desc: moreOptionsStrings.updateAccountAmount,
            amount: valueNewTransaction,
            categoryIndex: 0,
            date: Date().toString(format: globalStrings.dateFormat),
            type: transactionType,
            sourceId: id,
            paymentStatus: .pendent,
            invoiceMonth: Date().getMonth(),
            obs: globalStrings.emptyString
        ))
    }
    
    private func getNextDateFor(day: Int) -> Date? {
        let currentDate = Date()
        let calendar = Calendar.current
        let currentDay = calendar.component(.day, from: Date())

        return calendar.date(bySetting: .day, value: day, of: currentDate)
    }
    
//    private func getStartDateAndEndDate() -> (startDate: Date, endDate: Date)? {
//        guard let startOfThisMonth = getNextDateFor(day: closingDay) else { return nil }
//        
//        let calendar = Calendar.current
//        let currentDate = Date()
//        
//        var startDate: Date
//        var endDate: Date
//        
//        if currentDate >= startOfThisMonth {
//            endDate = calendar.date(byAdding: .month, value: 1, to: startOfThisMonth)!
//            endDate = calendar.date(bySetting: .day, value: closingDay - 1, of: endDate)!
//            startDate = startOfThisMonth
//        } else {
//            let lastMonth = calendar.date(byAdding: .month, value: -1, to: startOfThisMonth)!
//            startDate = calendar.date(bySetting: .day, value: closingDay, of: lastMonth)!
//            endDate = calendar.date(byAdding: .month, value: 1, to: startDate)!
//            endDate = calendar.date(bySetting: .day, value: closingDay - 1, of: endDate)!
//        }
//        
//        return (startDate, endDate)
//    }
    
    
}
