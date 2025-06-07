//
//  HomeViewModel.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 19/04/23.
//

import Foundation

struct HomeViewModel {
    
    private var service: FirestoreService = FirestoreService()
    
    private var incomesTotal: Double = 0.0
    private var expensesTotal: Double = 0.0
    private var balanceTotal: Double = 0.0
    private var lastIncomeDate: String = globalStrings.emptyString
    private var lastExpenseDate: String = globalStrings.emptyString
    
    func getAllData(completion: @escaping () -> Void) {
        let group = DispatchGroup()
        
        group.enter()
        getTransactions() {
            group.leave()
        }
        
        group.enter()
        getCreditCardExpenses() {
            group.leave()
        }
        
        group.enter()
        getAccounts() {
            group.leave()
        }
        
        group.enter()
        getCreditCards() {
            group.leave()
        }
        
        group.enter()
        getProfileInformations() {
            group.leave()
        }
        
        getCategories()
        
        group.notify(queue: .main) {
            reordenateTransactions()
            completion()
        }
    }
    
    private func getTransactions(completion: @escaping () -> Void) {
        
        service.getObjectsList(forObjectType: AccountTransaction.self, documentReadName: firebaseSubCollectionNames.transactions) { result in
            switch result {
            case .success(let objectsArray):
                TransactionsRepository.shared.list = objectsArray
            case .failure(let error):
                print(error.localizedDescription)
            }
            completion()
        }
    }
    
    func reordenateTransactions() {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = globalStrings.dateFormat
        
        let ordenatedTransactions = TransactionsRepository.shared.list.sorted(by: { transaction1, transaction2 in
            if let date1 = dateFormatter.date(from: transaction1.date), let date2 = dateFormatter.date(from: transaction2.date) {
                return date1 > date2
            }
            
            return true
        })
        
        TransactionsRepository.shared.list = ordenatedTransactions
        
    }
    
    private func getCreditCardExpenses(completion: @escaping () -> Void) {
        
        service.getObjectsList(forObjectType: CreditCardExpense.self, documentReadName: firebaseSubCollectionNames.creditCardExpenses) { result in
            switch result {
            case .success(let objectsArray):
                CreditCardExpensesRepository.shared.list = objectsArray
            case .failure(let error):
                print(error.localizedDescription)
            }
            completion()
        }
    }
    
    private func addFieldToObjects() {
        
        for transaction in TransactionsRepository.shared.list {
            service.updateObjectField(change: ["isMonthly": false], objectID: transaction.id, documentReadName: firebaseSubCollectionNames.transactions)
        }
        
        service.setObjectsList(objects: CreditCardExpensesRepository.shared.list) { _ in
            
        }
        
    }
    
    private func getAccounts(completion: @escaping () -> Void) {
        service.getObjectsList(forObjectType: BankAccount.self, documentReadName: firebaseSubCollectionNames.bankAccounts) { result in
            switch result {
            case .success(let accounts):
                BankAccountsRepository.shared.list = accounts
            case .failure(let error):
                print(error.localizedDescription)
                BankAccountsRepository.shared.list = []
            }
            completion()
        }
    }
    
    private func getCreditCards(completion: @escaping () -> Void) {
        service.getObjectsList(forObjectType: CreditCard.self, documentReadName: firebaseSubCollectionNames.creditCards) { result in
            switch result {
            case .success(let creditCards):
                CreditCardsRepository.shared.list = creditCards
            case .failure(let error):
                print(error.localizedDescription)
                CreditCardsRepository.shared.list = []
            }
            completion()
        }
    }
    
    private func getCategories() {
        
        CategoriesRepository.shared.expenses = [
            TransactionCategory(name: "Alimentação", imageName: "image35", colorIndex: 0),
            TransactionCategory(name: "Assinaturas", imageName: "image13", colorIndex: 1),
            TransactionCategory(name: "Casa", imageName: "image4", colorIndex: 2),
            TransactionCategory(name: "Educação", imageName: "image46", colorIndex: 3),
            TransactionCategory(name: "Esportes", imageName: "image8", colorIndex: 4),
            TransactionCategory(name: "Lazer", imageName: "image3", colorIndex: 5),
            TransactionCategory(name: "Serviços", imageName: "image40", colorIndex: 6),
            TransactionCategory(name: "Transferências", imageName: "image43", colorIndex: 7),
            TransactionCategory(name: "Transporte", imageName: "image0", colorIndex: 8),
            TransactionCategory(name: "Vestuario", imageName: "image1", colorIndex: 9),
            TransactionCategory(name: "Viagem", imageName: "image21", colorIndex: 10),
            TransactionCategory(name: "Outros", imageName: "image37", colorIndex: 11),
        ]

        CategoriesRepository.shared.incomes = [
            TransactionCategory(name: "Salario", imageName: "image7", colorIndex: 0),
            TransactionCategory(name: "Seguro Desemprego", imageName: "image15", colorIndex: 1),
            TransactionCategory(name: "Transferência", imageName: "image43", colorIndex: 2),
            TransactionCategory(name: "Apostas", imageName: "image3", colorIndex: 3),
            TransactionCategory(name: "Vendas", imageName: "image11", colorIndex: 4),
            TransactionCategory(name: "Outros", imageName: "image37", colorIndex: 5),
        ]
        
    }
    
    func getProfileInformations(completion: @escaping () -> Void) {
        service.getObject(subCollectionName: firebaseSubCollectionNames.profile, objectType: Profile.self) { profile in
            
            Utils.saveUserDefaults(value: profile.name, key: "userName")
            Utils.saveUserDefaults(value: profile.email, key: "userEmail")
            completion()
        }
    }
    
    public mutating func updateBalanceValues() {
        incomesTotal = 0.0
        expensesTotal = 0.0
        balanceTotal = 0.0
        lastIncomeDate = globalStrings.emptyString
        lastExpenseDate = globalStrings.emptyString
        
        for transaction in TransactionsRepository.shared.list {
            if transaction.type == .income {
                incomesTotal += transaction.amount
                if lastIncomeDate.isEmpty {
                    lastIncomeDate = transaction.date
                }
            } else if transaction.type == .expense {
                expensesTotal -= transaction.amount
                if lastExpenseDate.isEmpty {
                    lastExpenseDate = transaction.date
                }
            }
        }

        balanceTotal = incomesTotal - expensesTotal
        
    }
    
    func getCardInformation(cardNumber: Int) -> BalanceCard {
        switch cardNumber {
        case 0:
            return BalanceCard(type: .incomes, balance: self.incomesTotal, lastTransaction: self.lastIncomeDate)
        case 1:
            return BalanceCard(type: .expenses, balance: self.expensesTotal, lastTransaction: self.lastExpenseDate)
        default:
            return BalanceCard(type: .balance, balance: self.balanceTotal, lastTransaction: globalStrings.emptyString)
        }
    }
}
