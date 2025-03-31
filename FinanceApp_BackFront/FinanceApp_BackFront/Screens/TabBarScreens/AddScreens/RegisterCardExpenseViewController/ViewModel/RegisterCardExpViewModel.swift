//
//  RegisterCardExpViewModel.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 25/04/23.
//

import Foundation
import UIKit

class RegisterCardExpViewModel{
    
    public var selectedDate = Date()
    private var service: FirestoreService = FirestoreService(subCollectionName: firebaseSubCollectionNames.creditCardExpenses)
    
    func addExpense(expense: CreditCardExpense, completion: @escaping () -> Void) {
        var newExpense: CreditCardExpense = expense
        
        if newExpense.desc.isEmptyTest() {
            newExpense.desc = CategoriesRepository.shared.expenses[newExpense.categoryIndex].name
        }
        CreditCardExpensesRepository.shared.list.append(newExpense)
        
        service.setObject(newExpense) { result in
            if result != "Success" {
                print(result)
                completion()
                return
            }
            completion()
        }
        
    }
    
    var standardCardIndex: Int {
        for (index, card) in CreditCardsRepository.shared.list.enumerated(){
            if card.standardCard == true {
                return index
            }
        }
        return 0
    }
    
    var standardCardId: String {
        for card in CreditCardsRepository.shared.list{
            if card.standardCard == true{
                return card.id
            }
        }
        return CreditCardsRepository.shared.list[0].id
    }
    
    func getCategoryLabel(_ indexCategory:Int) -> String {
        return CategoriesRepository.shared.expenses[indexCategory].name
    }
    
    func getCategoryImageName(_ indexCategory:Int) -> UIImage{
        return UIImage(imageLiteralResourceName: CategoriesRepository.shared.expenses[indexCategory].imageName)
    }
    
    func getCategoryBackgroungColor(_ indexCategory:Int) -> UIColor{
        return categoryColors[CategoriesRepository.shared.expenses[indexCategory].colorIndex] ?? UIColor.cyan
    }
    
    func getCardLabel(_ indexAccount:Int) -> String{
        return CreditCardsRepository.shared.list[indexAccount].desc
    }
    
    func getBankLabelText(_ indexCard:Int) -> String{
        return bankProperties[CreditCardsRepository.shared.list[indexCard].bank]?.logoTextLabel ?? addStrings.bankText
    }
    
    func getBankLabelTextFont(_ indexCard:Int) -> UIFont{
        
        return UIFont.systemFont(ofSize: bankProperties[CreditCardsRepository.shared.list[indexCard].bank]?.logoTextSize ?? 16, weight: .bold)
    }
    
    func getBankLabelColor(_ indexCard:Int) -> UIColor{
        return bankProperties[CreditCardsRepository.shared.list[indexCard].bank]?.labelBankColor ?? .black
    }
    
    func getBankBackColor(_ indexCard:Int) -> UIColor{
        return bankProperties[CreditCardsRepository.shared.list[indexCard].bank]?.backgroundColor ?? .gray
    }
    
    func setValueToString(_ value: Double) -> String {
        var amount: String = String(value)
        if amount.hasSuffix(".0") {
            amount = String(amount.dropLast(2))
        }
        return amount
    }
    
    func datePickerChange(date: Date) -> String {
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        selectedDate = date
        
        switch formatDate(date: selectedDate){
        case formatDate(date: today):
            return globalStrings.todayText
        case formatDate(date: yesterday):
            return globalStrings.yesterdayText
        case formatDate(date: tomorrow):
            return globalStrings.tomorrowText
        default:
            return formatDate(date: date)
        }
    }
    
    private func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = globalStrings.dateFormat
        
        return formatter.string(from: date)
    }
}
