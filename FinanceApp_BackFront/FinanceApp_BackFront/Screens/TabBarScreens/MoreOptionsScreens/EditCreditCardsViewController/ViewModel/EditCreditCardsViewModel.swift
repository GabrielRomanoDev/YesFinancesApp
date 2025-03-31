//
//  EditCreditCardsViewModel.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 08/05/23.
//

import Foundation
import UIKit

class EditCreditCardsViewModel{
    
    public var configType: ConfigType
    private var card: CreditCard
    
    init(card: CreditCard, configType: ConfigType) {
        self.configType = configType
        self.card = card
    }
    
    func creditCardEmptyDesc(newCardBank: Banks) -> String {
            return "\(moreOptionsStrings.cardText) \(bankProperties[newCardBank]?.textNameBank ?? moreOptionsStrings.ofCreditText)"
    }
    
    func getBankListCount() -> Int {
        return bankList.count
    }
    
    func getBankName(_ bank:Banks) -> String {
        return bankProperties[bank]?.textNameBank ?? globalStrings.emptyString
    }
    
    func getRowHeight() ->CGFloat{
        return 44
    }
    
    func getBankLabelText(_ bank:Banks) -> String{
        return bankProperties[bank]?.logoTextLabel ?? globalStrings.emptyString
    }
    
    func getBankLabelTextFont(_ bank:Banks) -> UIFont{
        return UIFont.systemFont(ofSize: bankProperties[bank]?.logoTextSize ?? 17, weight: .bold)
    }
    
    func getBankLabelColor(_ bank:Banks) -> UIColor{
        return bankProperties[bank]?.labelBankColor ?? UIColor.white
    }
    
    func getBankBackColor(_ bank:Banks) -> UIColor{
        return bankProperties[bank]?.backgroundColor ??  UIColor.systemBlue
    }
}
