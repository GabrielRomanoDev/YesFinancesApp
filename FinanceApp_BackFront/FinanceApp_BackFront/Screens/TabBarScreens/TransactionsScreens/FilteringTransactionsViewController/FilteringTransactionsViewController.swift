//
//  FilteringTransactionsViewController.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 12/07/24.
//

import UIKit

protocol FilterTransactionsDelegate: AnyObject {
    func didFilter()
}

class FilteringTransactionsViewController: UIViewController {

    static let identifier:String = String(describing: FilteringTransactionsViewController.self)
    
    weak var delegate: FilterTransactionsDelegate?
    
    var resolvedTransactions = false
    var pendingTransactions = false
    var futureTransactions = false
    var earnings = false
    var expenses = false
    var creditExpenses = false
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @IBOutlet weak var filtersLabel: UILabel!
    @IBOutlet weak var situationLabel: UILabel!
    @IBOutlet weak var resolvedTransactionsButton: UIButton!
    @IBOutlet weak var pendingTransactionsButton: UIButton!
    @IBOutlet weak var futureTransactionsButton: UIButton!
    @IBOutlet weak var transactionTypeLabel: UILabel!
    @IBOutlet weak var earningsButton: UIButton!
    @IBOutlet weak var expensesButton: UIButton!
    @IBOutlet weak var creditExpensesButton: UIButton!
    @IBOutlet weak var accountsLabel: UILabel!
    @IBOutlet weak var allAccountsLabel: UILabel!
    @IBOutlet weak var creditCardsLabel: UILabel!
    @IBOutlet weak var allCreditCardsLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var allCategoriesLabel: UILabel!
    @IBOutlet weak var timeIntervalView: UIView!
    @IBOutlet weak var timeIntervalHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeIntervalLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStrings()
        setupElements()
        
    }
    
    @IBAction func tappedResolvedTransactionsButton(_ sender: UIButton) {
        
        resolvedTransactions.toggle()
        
        togleButton(resolvedTransactionsButton, value: resolvedTransactions)
        
    }
    
    @IBAction func tappedPendingTransactionsButton(_ sender: UIButton) {
        
        pendingTransactions.toggle()
        
        togleButton(pendingTransactionsButton, value: pendingTransactions)
    }
    
    @IBAction func tappedFutureTransactionsButton(_ sender: UIButton) {
        
        futureTransactions.toggle()
        
        togleButton(futureTransactionsButton, value: futureTransactions)
    }
    
    @IBAction func tappedEarningButton(_ sender: UIButton) {
        
        earnings.toggle()
        
        togleButton(earningsButton, value: earnings)
        
    }
    
    @IBAction func tappedExpensesButton(_ sender: UIButton) {
        
        expenses.toggle()
        
        togleButton(expensesButton, value: expenses)
        
    }
    
    @IBAction func tappedCreditExpensesButton(_ sender: UIButton) {
        
        creditExpenses.toggle()
        
        togleButton(creditExpensesButton, value: creditExpenses)
        
    }
    
    @IBAction func tappedAccountsModalButton(_ sender: UIButton) {
        
        let list = bankAccountsList.compactMap { accountItem in
            return accountItem.desc
        }
        
        var selectedItens: [Bool] = Array(repeating: true, count: bankAccountsList.count)
        
        selectedItens[0] = false 
        
        let storyboard = UIStoryboard(name: SelectionModalScreen.identifier, bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: SelectionModalScreen.identifier) {coder -> SelectionModalScreen? in
            return SelectionModalScreen(coder: coder, titleName: "Contas Bancarias", list: list, selectedItens: selectedItens, selectionType: .multiSelection)
        }
        
        vc.delegate = self
        if let presentationController = vc.presentationController as? UISheetPresentationController{
            presentationController.detents = [.medium()]
        }
        self.present(vc, animated: true)
        
    }
    
    @IBAction func tappedCardsModalButton(_ sender: UIButton) {
        
        
        let list = creditCardsList.compactMap { card in
            return card.desc
        }
        
        let storyboard = UIStoryboard(name: SelectionModalScreen.identifier, bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: SelectionModalScreen.identifier) {coder -> SelectionModalScreen? in
            return SelectionModalScreen(coder: coder, titleName: "Cartões", list: list, selectionType: .multiSelection)
        }
        vc.delegate = self
        if let presentationController = vc.presentationController as? UISheetPresentationController{
            presentationController.detents = [.medium()]
        }
        self.present(vc, animated: true)
        
        
    }
    
    @IBAction func tappedCategoriesModalButton(_ sender: UIButton) {
        
        var list = expenseCategories.compactMap { category in
            return category.name
        }
        
        for category in incomeCategories {
            list.append(category.name)
        }
        
        let storyboard = UIStoryboard(name: SelectionModalScreen.identifier, bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: SelectionModalScreen.identifier) {coder -> SelectionModalScreen? in
            return SelectionModalScreen(coder: coder, titleName: "Cartões", list: list, selectionType: .multiSelection)
        }
        vc.delegate = self
        if let presentationController = vc.presentationController as? UISheetPresentationController{
            presentationController.detents = [.medium()]
        }
        self.present(vc, animated: true)
        
    }
    
    @IBAction func tappedTimeIntervalSwitch(_ sender: UISwitch) {
        
        if sender.isOn {
            print("Switch pressed ON")
            timeIntervalHeightConstraint.constant = 200
        } else {
            print("Switch pressed off")        
            timeIntervalHeightConstraint.constant = 70
        }
        
    }
    
    @IBAction func tappedValueFilterSwitch(_ sender: UISwitch) {
        print(timeIntervalView.frame.size.height)
        
        
        
    }
    
    
    
    private func setupStrings() {
        
    }
    
    private func setupElements() {
        setupButton(resolvedTransactionsButton)
        setupButton(pendingTransactionsButton)
        setupButton(futureTransactionsButton)
        setupButton(earningsButton)
        setupButton(expensesButton)
        setupButton(creditExpensesButton)
        
    }
    
    private func setupButton(_ button: UIButton) {
        button.layer.cornerRadius = 15
        button.clipsToBounds = true
        button.layer.masksToBounds = true
        
        button.backgroundColor = .systemGray6
        button.tintColor = .black
        
        button.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private func togleButton(_ button: UIButton, value: Bool) {
    
        if value {
            button.backgroundColor = .systemBlue
            button.tintColor = .white
        } else {
            button.backgroundColor = .systemGray6
            button.tintColor = .black
        }
        
        
    }

}

extension FilteringTransactionsViewController: SelectionModalDelegate {
    
    func didSelectItem(_ selectionResult: [Bool]) {
        print("item selected: \(selectionResult)")
    }
    
}
