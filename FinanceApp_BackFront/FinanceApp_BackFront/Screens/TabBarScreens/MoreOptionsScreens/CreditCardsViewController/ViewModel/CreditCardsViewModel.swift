//
//  CreditCardsViewModel.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 08/05/23.
//

import Foundation
import UIKit

class CreditCardsViewModel {
    
    func updateCards(completion: @escaping () -> Void) {
        FirestoreService.shared.getObjectsList(forObjectType: CreditCard.self, subCollection: firebaseSubCollectionNames.creditCards) { result in
            switch result {
            case .success(let objectArray):
                CreditCardsRepository.shared.list = objectArray
            case .failure(let error):
                print(error.localizedDescription)
            }
            completion()
        }
    }
    
    func getCardsCount() -> Int {
            return CreditCardsRepository.shared.list.count
    }
    
    func getCard(_ index:Int) -> CreditCard {
        return CreditCardsRepository.shared.list[index]
    }
    
    func getCellSize(viewWidth:CGFloat) -> CGSize {
        return CGSize(width: viewWidth - 30, height: 80)
    }
    
    func getCellCornerRadius()-> CGFloat {
        return 10
    }
    
    func getCollectionEdgeInsets()-> UIEdgeInsets {
        return UIEdgeInsets(top: 15, left: 15, bottom: 0, right: 15)
    }
    
    func getNewCardButtonText() -> String {
        return moreOptionsStrings.newCreditCardButtonTitle
    }
    
    func createNewCard(_ newCard: CreditCard, completion: @escaping () -> Void) {
        if newCard.standardCard {
            clearStandardCard()
        }
        
        CreditCardsRepository.shared.list.append(newCard)
        FirestoreService.shared.setObject(newCard, subCollection: firebaseSubCollectionNames.creditCards) { result in
            if result != "Success" {
                print(result)
            }
            completion()
        }
    }
    
    func editCard(card: CreditCard, indexCard: Int, completion: @escaping () -> Void) {
        if card.standardCard {
            clearStandardCard()
        }
        
        var updatedCard = CreditCardsRepository.shared.list[indexCard]
        updatedCard.desc = card.desc
        updatedCard.limit = card.limit
        updatedCard.bank = card.bank
        updatedCard.closingDay = card.closingDay
        updatedCard.dueDay = card.dueDay
        updatedCard.standardCard = card.standardCard
        updatedCard.obs = card.obs
        
        FirestoreService.shared.setObject(updatedCard, subCollection: firebaseSubCollectionNames.creditCards) { result in
            if result != "Success" {
                print(result)
            }
            CreditCardsRepository.shared.list[indexCard] = card
            completion()
        }
    }
    
    func deleteCard(index: Int, completion: @escaping () -> Void) {
        
        FirestoreService.shared.deleteObject(id: CreditCardsRepository.shared.list[index].id, subCollection: firebaseSubCollectionNames.creditCards) { result in
            if result != "Success" {
                print(result)
            }
            CreditCardsRepository.shared.list.remove(at: index)
            completion()
        }
    }
    
    private func clearStandardCard() {
        
        for i in 0..<CreditCardsRepository.shared.list.count {
            CreditCardsRepository.shared.list[i].standardCard = false
            FirestoreService.shared.updateObjectField(change: ["standardCard":false], objectID: CreditCardsRepository.shared.list[i].id, subCollection: firebaseSubCollectionNames.creditCards)
        }
        
    }
    
}
