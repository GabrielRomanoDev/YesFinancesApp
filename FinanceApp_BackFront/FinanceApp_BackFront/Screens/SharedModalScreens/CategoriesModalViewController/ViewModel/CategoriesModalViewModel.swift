//
//  CategoriesModalViewModel.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 23/04/23.
//

import Foundation

class CategoriesModalViewModel{
    
    var filteredCategories: [TransactionCategory]
    
    init(transactionType:TransactionType) {
        
        if transactionType == .expense {
            self.filteredCategories = CategoriesRepository.shared.expenses
        } else{
            self.filteredCategories = CategoriesRepository.shared.incomes
        }
        
    }
    
    func getCategoriesCount() -> Int {
        return filteredCategories.count
    }
    
    func getItemCategory(_ index:Int) -> TransactionCategory {
        return filteredCategories[index]
    }
    
    func getHeightSize() -> CGFloat {
        return 60
    }
}
