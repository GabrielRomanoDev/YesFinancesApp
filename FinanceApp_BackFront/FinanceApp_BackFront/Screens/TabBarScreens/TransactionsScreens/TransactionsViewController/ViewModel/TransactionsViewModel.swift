//
//  TransactionsViewModel.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 20/04/23.
//

import Foundation

struct TransactionsViewModel {
    
    var filteringWorker: TransactionsFilterWorker = TransactionsFilterWorker()
    var filteredTransactions: [AccountTransaction]? = nil
    
    public func reordenateTransactions(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = globalStrings.dateFormat

        TransactionsRepository.shared.list = TransactionsRepository.shared.list.sorted(by: { transaction1, transaction2 in
            let data1 = dateFormatter.date(from: transaction1.date)!
            let data2 = dateFormatter.date(from: transaction2.date)!
            return data1 > data2
        })
        
    }
    
    public func getTransactionsCount() -> Int {
        
        if let filtered = filteredTransactions {
            return filtered.count
        } else {
            return TransactionsRepository.shared.list.count
        }
       
    }
    
    public func getItemTransactions(_ index:Int) -> AccountTransaction {
        
        if let filtered = filteredTransactions {
            return filtered[index]
        } else {
            return TransactionsRepository.shared.list[index]
        }
        
    }
    
    public func getCellSize(viewWidth:CGFloat) -> CGSize {
        return CGSize(width: viewWidth - 30, height: 85)
    }
    
    mutating func filterTransactions(parameters: FilteringParameters, textSearch: String? = "") {
        filteredTransactions = filteringWorker.filterTransactions(parameters: parameters)
        filteredTransactions = filteringWorker.searchForTransactions(textSearch)
    }
    
    mutating func searchForTransactions(_ text: String?) {
        if filteringWorker.filteredTransactions.isEmpty {
            filteringWorker.filteredTransactions = TransactionsRepository.shared.list
        }
        filteredTransactions = filteringWorker.searchForTransactions(text)
    }
    
}

