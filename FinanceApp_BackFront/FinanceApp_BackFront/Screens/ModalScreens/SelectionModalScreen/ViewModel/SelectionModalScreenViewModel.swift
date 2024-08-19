//
//  SelectionModalScreenViewModel.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 18/08/24.
//

import Foundation

class SelectionModalScreenViewModel {
    
    private let selectionType: SelectionType
    var listSelections: [Bool]
    
    init(selectionType: SelectionType, listSelections: [Bool]) {
        self.selectionType = selectionType
        self.listSelections = listSelections
    }
    
    func updateSelections(indexPressed: Int) {
       
        var result: [Bool] = listSelections
        
        switch selectionType {
        case .uniqueSelection:
            
            for i in 0..<listSelections.count {
                result[i] = false
            }
            
            result[indexPressed] = true
            
        case .multiSelection:
            result[indexPressed].toggle()
        }
        
        self.listSelections = result
        
    }
    
}
