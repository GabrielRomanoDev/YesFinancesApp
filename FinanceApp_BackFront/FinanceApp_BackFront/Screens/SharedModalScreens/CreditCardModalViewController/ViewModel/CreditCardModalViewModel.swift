//
//  CreditCardModalViewModel.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 30/05/23.
//

import Foundation

class CreditCardModalViewModel {
    func getCreditCardsCount() -> Int {
        return CreditCardsRepository.shared.list.count
    }
    
    func getItemCard(_ index:Int) -> CreditCard {
        return CreditCardsRepository.shared.list[index]
    }
    
    func getHeightSize() -> CGFloat {
        return 60
    }
}
