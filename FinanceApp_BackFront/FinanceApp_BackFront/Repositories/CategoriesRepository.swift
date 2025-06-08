//
//  CategoriesRepository.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 22/02/25.
//

class CategoriesRepository {
    
    static let shared = CategoriesRepository()
    
    var expenses: [TransactionCategory] = []
    var incomes: [TransactionCategory] = []
    
    private var fixedExpenses: [TransactionCategory] = [
        TransactionCategory(name: "Pagamento de Fatura", imageName: "image15", colorIndex: 6)
    ]
    
    private init(){}
    
    func expense(_ index: Int) -> TransactionCategory {
        
        if index >= 30 && (index < (fixedExpenses.count + 30)) {
            return fixedExpenses[index-30]
        } else if index < expenses.count {
            return expenses[index]
        } else {
            fatalError("Index out of bounds")
        }
        
    }
    
    func income(_ index: Int) -> TransactionCategory {
        
        if index < incomes.count {
            return incomes[index]
        } else {
            fatalError("Index out of bounds")
        }
        
    }
    
}
