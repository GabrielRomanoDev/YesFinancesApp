//
//  FilteringTransactionsViewController.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 12/07/24.
//

import UIKit

protocol FilterTransactionsDelegate: AnyObject {
    func didFilter(parameters: FilteringParameters?)
}

class FilteringTransactionsViewController: UIViewController {

    static let identifier:String = String(describing: FilteringTransactionsViewController.self)
    
    weak var delegate: FilterTransactionsDelegate?
    var parameters: FilteringParameters
    
    init?(coder: NSCoder, parameters: FilteringParameters?) {
        self.parameters = parameters ?? FilteringParameters()
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError(globalStrings.initError)
    }
    
    @IBOutlet weak var filtersLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStrings()
        setupTableView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.didFilter(parameters: parameters)
        dismiss(animated: true)
    }
    
    private func openSelectAccountsModal() {
        
        let list = bankAccountsList.compactMap { accountItem in
            return accountItem.desc
        }
        
        var selectedItens: [Bool] = Array(repeating: false, count: bankAccountsList.count)
        
        if let accounts = parameters.accounts {
            selectedItens = bankAccountsList.map{ account in
                accounts.contains(where: { $0.id == account.id })
            }
        }
        
        let storyboard = UIStoryboard(name: SelectionModalScreen.identifier, bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: SelectionModalScreen.identifier) {coder -> SelectionModalScreen? in
            return SelectionModalScreen(coder: coder, titleName: FilteringTransactionsStrings.accounts, list: list, selectedItens: selectedItens, selectionType: .multiSelection)
        }
        
        vc.delegate = self
        vc.selectionItemType = .accounts
        
        if let presentationController = vc.presentationController as? UISheetPresentationController{
            presentationController.detents = [.medium()]
        }
        self.present(vc, animated: true)
        
    }
    
    private func openSelectCardsModal() {
        
        let list = creditCardsList.compactMap { cardItem in
            return cardItem.desc
        }
        
        var selectedItens: [Bool] = Array(repeating: false, count: creditCardsList.count)
        
        if let creditCards = parameters.creditCards {
            selectedItens = creditCardsList.map{ card in
                creditCards.contains(where: { $0.id == card.id })
            }
        }
        
        let storyboard = UIStoryboard(name: SelectionModalScreen.identifier, bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: SelectionModalScreen.identifier) {coder -> SelectionModalScreen? in
            return SelectionModalScreen(coder: coder, titleName: FilteringTransactionsStrings.creditCards, list: list, selectedItens: selectedItens, selectionType: .multiSelection)
        }
        
        vc.delegate = self
        vc.selectionItemType = .creditCards
        
        if let presentationController = vc.presentationController as? UISheetPresentationController{
            presentationController.detents = [.medium()]
        }
        self.present(vc, animated: true)
        
    }

    func openSelectCategoriesModal() {
        
        var list = expenseCategories.compactMap { category in
            return category.name
        }
        
        for category in incomeCategories {
            list.append(category.name)
        }
        
        var selectedItens: [Bool] = Array(repeating: false, count: list.count)
        
        if let categories = parameters.categories {
            selectedItens = list.map{ category in
                categories.contains(where: { $0.name == category })
            }
        }
        
        let storyboard = UIStoryboard(name: SelectionModalScreen.identifier, bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: SelectionModalScreen.identifier) {coder -> SelectionModalScreen? in
            return SelectionModalScreen(coder: coder, titleName: FilteringTransactionsStrings.categories, list: list, selectedItens: selectedItens,selectionType: .multiSelection)
        }
        
        vc.delegate = self
        vc.selectionItemType = .categories
        
        if let presentationController = vc.presentationController as? UISheetPresentationController{
            presentationController.detents = [.medium()]
        }
        self.present(vc, animated: true)
        
    }
    
    private func setupStrings() {
        filtersLabel.text = FilteringTransactionsStrings.filters
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ButtonsTableViewCell.nib(), forCellReuseIdentifier: ButtonsTableViewCell.identifier)
        tableView.register(SelectItensTableViewCell.nib(), forCellReuseIdentifier: SelectItensTableViewCell.identifier)
        tableView.register(ValueFilteringTableViewCell.nib(), forCellReuseIdentifier: ValueFilteringTableViewCell.identifier)
        tableView.register(DateFilteringTableViewCell.nib(), forCellReuseIdentifier: DateFilteringTableViewCell.identifier)
        tableView.register(ButtonTableViewCell.nib(), forCellReuseIdentifier: ButtonTableViewCell.identifier)
    }
    
    private func openSelectScreen(itemType: ModalSelectionItemOptions) {
        
        switch itemType {
        case .accounts:
            openSelectAccountsModal()
        case .creditCards:
            openSelectCardsModal()
        case .categories:
            openSelectCategoriesModal()
        case .other:
            break
        }
        
    }
    
    private func updateTableViewContent() {
        
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
        
    }

}


extension FilteringTransactionsViewController: FilteringTransactionsCollectionViewCellProtocol {
    
    func didRemoveItem(index: Int?, item: Any?) {
        
        guard let index = index else { return }
        
        if let _ = item as? BankAccount {
            parameters.accounts?.remove(at: index)
            
            if let accounts = parameters.accounts?.count, accounts <= 0 {
                parameters.accounts = nil
            }
        } else if let _ = item as? CreditCard {
            parameters.creditCards?.remove(at: index)
            
            if let creditCards = parameters.creditCards?.count, creditCards <= 0 {
                parameters.creditCards = nil
            }
        } else if let _ = item as? TransactionCategory {
            parameters.categories?.remove(at: index)
            
            if let categories = parameters.categories?.count, categories <= 0 {
                parameters.categories = nil
            }
        }
        
        updateTableViewContent()
        
    }
    
}

extension FilteringTransactionsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: ButtonsTableViewCell.identifier, for: indexPath) as? ButtonsTableViewCell
            cell?.setupCell(configuration: ButtonsCellConfiguration(filteringTypes: parameters.types) )
            cell?.delegate = self
            return cell ?? UITableViewCell()
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: SelectItensTableViewCell.identifier, for: indexPath) as? SelectItensTableViewCell
            cell?.setupCell(accounts: parameters.accounts)
            cell?.screenWidth = view.layer.bounds.width
            cell?.selectionStyle = .none
            cell?.delegate = self
            return cell ?? UITableViewCell()
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: SelectItensTableViewCell.identifier, for: indexPath) as? SelectItensTableViewCell
            cell?.setupCell(creditCards: parameters.creditCards)
            cell?.screenWidth = view.layer.bounds.width
            cell?.selectionStyle = .none
            cell?.delegate = self
            return cell ?? UITableViewCell()
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: SelectItensTableViewCell.identifier, for: indexPath) as? SelectItensTableViewCell
            cell?.setupCell(categories: parameters.categories)
            cell?.screenWidth = view.layer.bounds.width
            cell?.selectionStyle = .none
            cell?.delegate = self
            return cell ?? UITableViewCell()
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: DateFilteringTableViewCell.identifier, for: indexPath) as? DateFilteringTableViewCell
            cell?.setupCell(filteringDates: parameters.dates)
            cell?.delegate = self
            return cell ?? UITableViewCell()
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: ValueFilteringTableViewCell.identifier, for: indexPath) as? ValueFilteringTableViewCell
            cell?.setupCell(filteringValues: parameters.limits)
            cell?.delegate = self
            return cell ?? UITableViewCell()
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.identifier, for: indexPath) as? ButtonTableViewCell
            cell?.setupCell(title: globalStrings.apply)
            cell?.delegate = self
            return cell ?? UITableViewCell()
        default:
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.row {
        case 0:
            return 90
        case 1:
            var count = parameters.accounts?.count ?? 1
            if count <= 0 { count = 1 }
            return CGFloat(50 + 45 * count)
        case 2:
            var count = parameters.creditCards?.count ?? 1
            if count <= 0 { count = 1 }
            return CGFloat(50 + 45 * count)
        case 3:
            var count = parameters.categories?.count ?? 1
            if count <= 0 { count = 1 }
            return CGFloat(50 + 45 * count)
        case 4:
            return parameters.dates.enabled ? 130 : 70
        case 5:
            return parameters.limits.enabled ? 130 : 70
        case 6:
            return 60
        default:
            return 70
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        switch indexPath.row {
        case 1:
            openSelectScreen(itemType: .accounts)
        case 2:
            openSelectScreen(itemType: .creditCards)
        case 3:
            openSelectScreen(itemType: .categories)
        default:
            break //Does not execute anything to other cells
        }
        
    }
    
}

extension FilteringTransactionsViewController: ButtonTableViewCellDelegate {
    
    func didTappedButton() {
        delegate?.didFilter(parameters: parameters)
        dismiss(animated: true)
    }
    
}

extension FilteringTransactionsViewController: ButtonsTableViewCellDelegate {
    
    func didTappedButton1(value: Bool) {
        parameters.types.incomes = value
    }
    
    func didTappedButton2(value: Bool) {
        parameters.types.expenses = value
    }
    
    func didTappedButton3(value: Bool) {
        parameters.types.creditCard = value
    }
    
    
}

extension FilteringTransactionsViewController: SelectionModalDelegate {
    
    func didSelectItem(_ selectionResult: [Bool], itemType: ModalSelectionItemOptions) {
        
        switch itemType {
        case .accounts:
            parameters.accounts = []
            updateParameters(selectionResult: selectionResult, items: bankAccountsList) { account in
                parameters.accounts?.append(account)
            }
            
            updateTableViewContent()
            
        case .creditCards:
            break
//            let cards = creditCardsList.map { $0.desc }
            //            let text = updateSelectionText(from: selectionResult, items: cards)
            //            allCreditCardsLabel.text = text.isEmpty ? "Todos Cartões" : text
            //
            //            parameters.creditCards = []
            //            updateViewModel(selectionResult: selectionResult, items: creditCardsList) { card in
            //                parameters.creditCards?.append(card.id)
            //            }
        case .categories:
            parameters.categories = []
            updateParameters(selectionResult: selectionResult, items: expenseCategories) { category in
                parameters.categories?.append(category)
            }
            updateTableViewContent()
        case .other:
            break
        }

    }
    
}

extension FilteringTransactionsViewController {

    private func updateParameters<T>(selectionResult: [Bool], items: [T], updateClosure: (T) -> Void) {
        for (index, item) in items.enumerated() {
            if selectionResult[index] {
                updateClosure(item)
            }
        }
    }
    
}

extension FilteringTransactionsViewController: SelectItensTableViewCellDelegate {
    
    func didSelectCell(type: ModalSelectionItemOptions) {
        openSelectScreen(itemType: type)
    }
    
}

extension FilteringTransactionsViewController: InsertNumbersModalProtocol {

    func didSelectNumber(_ value: Double, id: Int) {

            switch id {
            case 0:
                parameters.limits.min = value

                if parameters.limits.max < value {
                    parameters.limits.max = value
                }
            case 1:
                parameters.limits.max = value

                if parameters.limits.min > value {
                    parameters.limits.min = value
                }
            default:
                break
            }

            updateTableViewContent()
    }
    
}

extension FilteringTransactionsViewController: DateFilteringTableViewCellDelegate {
    
    func didUpdateDates(isInitialDate: Bool, date: String) {
            
        if isInitialDate {
            parameters.dates.initial = date
        } else {
            parameters.dates.final = date
        }
            
    }
    
    
    func didTapDateSwitch(_ value: Bool) {
        
        self.parameters.dates.enabled = value
        updateTableViewContent()
        
    }
    
}

extension FilteringTransactionsViewController: ValueFilteringTableViewCellDelegate {
    
    func didTapValueSwitch(_ value: Bool) {
        
        self.parameters.limits.enabled = value
        updateTableViewContent()
        
    }
    
    func didTapTextField(cell: ValueFilteringTableViewCell, type: FieldType) {
        let storyboard = UIStoryboard(name: InsertNumbersModalViewController.identifier, bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: InsertNumbersModalViewController.identifier) { coder in
            InsertNumbersModalViewController(coder: coder, id: type == .minValue ? 0 : 1)
        }
        vc.delegate = self
        self.present(vc, animated: true)
    }
    
}
