//
//  FilteringComposite.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 27/03/25.
//

import Foundation

protocol Specification {
    func isSatisfied(by item: any Transactions) -> Bool
}

struct TypeSpecification: Specification {
    let types: TransactionFilteringTypes
    
    func isSatisfied(by item: any Transactions) -> Bool {
        if !types.incomes && !types.expenses { return true }
        if types.incomes { return item.amount > 0 }
        if types.expenses { return item.amount < 0 }
        return false
    }
}

struct SourceSpecification: Specification {
    let accounts: [BankAccount]
    
    func isSatisfied(by item: any Transactions) -> Bool {
        return accounts.contains { account in
            account.id == item.sourceId
        }
    }
}

struct CategorySpecification: Specification {
    let categories: [TransactionCategory]
    
    func isSatisfied(by item: any Transactions) -> Bool {
        return categories.contains { category in
            category.name == CategoriesRepository.shared.expenses[item.categoryIndex].name
        }
    }
}

struct ValueSpecification: Specification {
    let min: Double
    let max: Double
    
    func isSatisfied(by item: any Transactions) -> Bool {
        return abs(item.amount) > min && abs(item.amount) < max
    }
}

struct DateSpecification: Specification {
    let initialDate: Date
    let finalDate: Date
    
    func isSatisfied(by item: any Transactions) -> Bool {
        guard let date = item.date.toDate() else { return false }
        return date >= initialDate && date <= finalDate
    }
}

struct MonthSpecification: Specification {
    let monthDisplayed: MonthDate?
    
    func isSatisfied(by item: any Transactions) -> Bool {
        guard let date = item.date.toDate(), let monthDisplayed = monthDisplayed else { return false }
        let components = Calendar.current.dateComponents([.month, .year], from: date)
        return components.month == monthDisplayed.month && components.year == monthDisplayed.year
    }
}

class CompositeSpecification: Specification {
    private var specifications: [Specification] = []

    func add(_ spec: Specification) {
        specifications.append(spec)
    }

    func isSatisfied(by item: any Transactions) -> Bool {
        return specifications.allSatisfy { $0.isSatisfied(by: item) }
    }
}
