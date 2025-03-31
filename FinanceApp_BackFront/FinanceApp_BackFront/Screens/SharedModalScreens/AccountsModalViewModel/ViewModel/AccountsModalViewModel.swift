//
//  AccountsModalViewModel.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 23/04/23.
//

import Foundation

class AccountsModalViewModel {
    
    func getAccountsCount() -> Int {
        return BankAccountsRepository.shared.list.count
    }
    
    func getItemAccount(_ index:Int) -> BankAccount {
        return BankAccountsRepository.shared.list[index]
    }
    
    func getHeightSize() -> CGFloat {
        return 60
    }
}
