//
//  SelectionModalScreenViewModel.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 18/08/24.
//

import Foundation

class SelectionModalScreenViewModel {
    
    private let list: [String]
    private let selectionType: SelectionType
    var selectedItens: [Bool]
    
    init(list: [String], selectionType: SelectionType, selectedItens: [Bool]?) {
        
        self.list = list
        self.selectionType = selectionType
        
        if let selectedItens = selectedItens {
            self.selectedItens = selectedItens
        } else {
            let falseArray: [Bool] = Array(repeating: false, count: list.count)
            self.selectedItens = falseArray
        }
        
    }
    
    func updateSelections(indexPressed: Int) {
       
        var result: [Bool] = selectedItens
        
        switch selectionType {
        case .uniqueSelection:
            
            for i in 0..<selectedItens.count {
                result[i] = false
            }
            
            result[indexPressed] = true
            
        case .multiSelection:
            result[indexPressed].toggle()
        }
        
        self.selectedItens = result
        
    }
    
    func nameItem(index: Int) -> String {
        return list[index]
    }
    
    func itensCount() -> Int {
        return list.count
    }
    
}
