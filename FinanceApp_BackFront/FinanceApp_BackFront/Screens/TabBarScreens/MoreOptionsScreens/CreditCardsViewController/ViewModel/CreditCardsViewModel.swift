//
//  CreditCardsViewModel.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 08/05/23.
//

import Foundation
import UIKit

class CreditCardsViewModel {
    
    private var service: FirestoreService = FirestoreService(subCollectionName: firebaseSubCollectionNames.creditCards)
    
    public func updateCards(completion: @escaping () -> Void) {
        service.getObjectsList(forObjectType: CreditCard.self, documentReadName: firebaseSubCollectionNames.creditCards) { result in
            switch result {
            case .success(let objectArray):
                creditCardsList = objectArray
            case .failure(let error):
                print(error.localizedDescription)
            }
            completion()
        }
    }
    
    public func getCardsCount() -> Int {
            return creditCardsList.count
    }
    
    public func getCard(_ index:Int) -> CreditCard {
        return creditCardsList[index]
    }
    
    public func getCellSize(viewWidth:CGFloat) -> CGSize {
        return CGSize(width: viewWidth - 30, height: 80)
    }
    
    public func getCellCornerRadius()-> CGFloat {
        return 10
    }
    
    public func getCollectionEdgeInsets()-> UIEdgeInsets {
        return UIEdgeInsets(top: 15, left: 15, bottom: 0, right: 15)
    }
    
    public func getNewCardButtonText() -> String {
        return moreOptionsStrings.newCreditCardButtonTitle
    }
    
    public func createNewCard(_ newCard: CreditCard, completion: @escaping () -> Void) {
        if newCard.standardCard {
            clearStandardCard()
        }
        
        creditCardsList.append(newCard)
        service.addObject(newCard, id: newCard.getId) { result in
            if result != "Success" {
                print(result)
            }
            completion()
        }
    }
    
    public func editCard(card: CreditCard, indexCard: Int, completion: @escaping () -> Void) {
        if card.standardCard {
            clearStandardCard()
        }
        
        var updatedCard = creditCardsList[indexCard]
        updatedCard.desc = card.desc
        updatedCard.limit = card.limit
        updatedCard.bank = card.bank
        updatedCard.closingDay = card.closingDay
        updatedCard.dueDate = card.dueDate
        updatedCard.standardCard = card.standardCard
        updatedCard.obs = card.obs
        
        service.updateObject(updatedCard, id: updatedCard.getId) { result in
            if result != "Success" {
                print(result)
            }
            creditCardsList[indexCard] = card
            completion()
        }
    }
    
    public func deleteCard(index: Int, completion: @escaping () -> Void) {
        
        service.deleteObject(id: creditCardsList[index].getId) { result in
            if result != "Success" {
                print(result)
            }
            creditCardsList.remove(at: index)
            completion()
        }
    }
    
    private func clearStandardCard() {
        for i in 0..<creditCardsList.count {
            creditCardsList[i].standardCard = false
        }
    }
}

var creditCardsList : [CreditCard] = []
