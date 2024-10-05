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
    var viewModel: FilteringTransactionsViewModel
    
    var calculatedStackViewHeight: CGFloat {
        return 470 + timeIntervalHeightConstraint.constant + valueHeightConstraint.constant
    }
    
    init?(coder: NSCoder, parameters: FilteringParameters?) {
        self.viewModel = FilteringTransactionsViewModel(parameters: parameters)
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet weak var filtersLabel: UILabel!
    @IBOutlet weak var situationLabel: UILabel!
    @IBOutlet weak var resolvedTransactionsButton: UIButton!
    @IBOutlet weak var pendingTransactionsButton: UIButton!
    @IBOutlet weak var futureTransactionsButton: UIButton!
    @IBOutlet weak var transactionTypeLabel: UILabel!
    @IBOutlet weak var incomesButton: UIButton!
    @IBOutlet weak var expensesButton: UIButton!
    @IBOutlet weak var creditExpensesButton: UIButton!
    @IBOutlet weak var accountsLabel: UILabel!
    @IBOutlet weak var allAccountsLabel: UILabel!
    @IBOutlet weak var accountsButton: UIButton!
    @IBOutlet weak var creditCardsLabel: UILabel!
    @IBOutlet weak var allCreditCardsLabel: UILabel!
    @IBOutlet weak var cardsButton: UIButton!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var allCategoriesLabel: UILabel!
    @IBOutlet weak var categoriesButton: UIButton!
    @IBOutlet weak var timeIntervalView: UIView!
    @IBOutlet weak var timeIntervalHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeIntervalLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var valueHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var fromDateTextField: UITextField!
    @IBOutlet weak var toDateTextField: UITextField!
    @IBOutlet weak var timeIntervalHiddenStackView: UIStackView!
    @IBOutlet weak var minValueTextField: UITextField!
    @IBOutlet weak var maxValueTextField: UITextField!
    @IBOutlet weak var valueHiddenStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStrings()
        setupElements()
        setupDataPicker()
    }
    
    @IBAction func tappedResolvedTransactionsButton(_ sender: UIButton) {
        
//        viewModel.parameters.resolvedTransactions.toggle()
        
//        togleButton(resolvedTransactionsButton, value: resolvedTransactions)
        
    }
    
    @IBAction func tappedPendingTransactionsButton(_ sender: UIButton) {
        
        //        viewModel.parameters.pendingTransactions.toggle()
        
//        togleButton(pendingTransactionsButton, value: pendingTransactions)
    }
    
    @IBAction func tappedFutureTransactionsButton(_ sender: UIButton) {
        
        //        viewModel.parameters.futureTransactions.toggle()
        
//        togleButton(futureTransactionsButton, value: futureTransactions)
    }
    
    @IBAction func tappedEarningButton(_ sender: UIButton) {
        
        if let types = viewModel.parameters.types {
            viewModel.parameters.types?.incomes = !types.incomes
            updateButtonCollor(incomesButton, value: !types.incomes)
        } else {
            viewModel.parameters.types = TransactionFilteringTypes(incomes: true)
            updateButtonCollor(incomesButton, value: true)
        }
        
    }
    
    @IBAction func tappedExpensesButton(_ sender: UIButton) {
        
        if let types = viewModel.parameters.types {
            viewModel.parameters.types?.expenses = !types.expenses
            updateButtonCollor(expensesButton, value: !types.expenses)
        } else {
            viewModel.parameters.types = TransactionFilteringTypes(expenses: true)
            updateButtonCollor(expensesButton, value: true)
        }
        
    }
    
    @IBAction func tappedCreditExpensesButton(_ sender: UIButton) {
        
//        creditExpenses.toggle()
//        
//        togleButton(creditExpensesButton, value: creditExpenses)
        
    }
    
    @IBAction func tappedAccountsModalButton(_ sender: UIButton) {
        
        let list = bankAccountsList.compactMap { accountItem in
            return accountItem.desc
        }
        
        let selectedItens: [Bool] = Array(repeating: false, count: bankAccountsList.count)
        
        let storyboard = UIStoryboard(name: SelectionModalScreen.identifier, bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: SelectionModalScreen.identifier) {coder -> SelectionModalScreen? in
            return SelectionModalScreen(coder: coder, titleName: "Contas Bancarias", list: list, selectedItens: selectedItens, selectionType: .multiSelection)
        }
        
        vc.delegate = self
        vc.triggeringButton = sender
        
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
        vc.triggeringButton = sender
        
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
        vc.triggeringButton = sender
        
        if let presentationController = vc.presentationController as? UISheetPresentationController{
            presentationController.detents = [.medium()]
        }
        self.present(vc, animated: true)
        
    }
    
    @IBAction func tappedTimeIntervalSwitch(_ sender: UISwitch) {
        
        if sender.isOn {
            timeIntervalHeightConstraint.constant = 140
            timeIntervalHiddenStackView.isHidden = false
            
            
        } else {
            timeIntervalHeightConstraint.constant = 70
            timeIntervalHiddenStackView.isHidden = true
        }
        
        stackViewHeightConstraint.constant = calculatedStackViewHeight
        
        
        
    }
    
    @IBAction func tappedValueFilterSwitch(_ sender: UISwitch) {
        
        if sender.isOn {
            valueHeightConstraint.constant = 140
            valueHiddenStackView.isHidden = false
            let minValue = minValueTextField.text?.toDouble() ?? 0.0
            let maxValue = maxValueTextField.text?.toDouble() ?? 0.0
            viewModel.parameters.limits = TransactionFilteringValue(min: minValue, max: maxValue)
        } else {
            valueHeightConstraint.constant = 70
            valueHiddenStackView.isHidden = true
            viewModel.parameters.limits = nil
        }
        
        stackViewHeightConstraint.constant = calculatedStackViewHeight
        
    }
    
    @IBAction func tappedFilterButton(_ sender: UIButton) {
        delegate?.didFilter(parameters: viewModel.parameters)
        dismiss(animated: true)
    }
    
    
    private func setupStrings() {
        
    }
    
    private func setupElements() {
        setupButton(resolvedTransactionsButton, value: false)
        setupButton(pendingTransactionsButton, value: false)
        setupButton(futureTransactionsButton, value: false)
        setupButton(incomesButton, value: viewModel.parameters.types?.incomes)
        setupButton(expensesButton, value: viewModel.parameters.types?.expenses)
        setupButton(creditExpensesButton, value: false)
        minValueTextField.delegate = self
        minValueTextField.text = 0.0.toStringMoney()
        maxValueTextField.delegate = self
        maxValueTextField.text = 0.0.toStringMoney()
        
    }
    
    private func setupButton(_ button: UIButton, value: Bool?) {
        button.layer.cornerRadius = 15
        button.clipsToBounds = true
        button.layer.masksToBounds = true
        
        updateButtonCollor(button, value: value ?? false)
        
        button.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private func updateButtonCollor(_ button: UIButton, value: Bool) {
    
        if value {
            button.backgroundColor = .systemBlue
            button.tintColor = .white
        } else {
            button.backgroundColor = .systemGray6
            button.tintColor = .black
        }
        
    }
    
    var activeTextField: UITextField?

    private func setupDataPicker(){
        let datePickerFrom = UIDatePicker()
        datePickerFrom.datePickerMode = .date
        datePickerFrom.addTarget(self, action: #selector(dateChange(datePicker:)), for: UIControl.Event.valueChanged)
        datePickerFrom.frame.size = CGSize(width: 0, height: 300)
        datePickerFrom.preferredDatePickerStyle = .inline
        fromDateTextField.inputView = datePickerFrom
        
        let datePickerTo = UIDatePicker()
        datePickerTo.datePickerMode = .date
        datePickerTo.addTarget(self, action: #selector(dateChange(datePicker:)), for: UIControl.Event.valueChanged)
        datePickerTo.frame.size = CGSize(width: 0, height: 300)
        datePickerTo.preferredDatePickerStyle = .inline
        toDateTextField.inputView = datePickerTo
        
        // Adicionar observador para saber qual textField está ativo
        fromDateTextField.addTarget(self, action: #selector(textFieldShouldBeginEditing(_:)), for: .editingDidBegin)
        toDateTextField.addTarget(self, action: #selector(textFieldShouldBeginEditing(_:)), for: .editingDidBegin)
    }
    
    @objc func dateChange(datePicker: UIDatePicker) {
        guard let activeTextField = activeTextField else { return }
        
        if activeTextField == fromDateTextField {
            fromDateTextField.text = datePickerChange(date: datePicker.date)
            viewModel.parameters.dates?.from =  fromDateTextField.text.orEmpty
            
            if let toDate = toDateTextField.text?.toDate(), datePicker.date > toDate {
                toDateTextField.text = fromDateTextField.text.orEmpty
                viewModel.parameters.dates?.to =  fromDateTextField.text.orEmpty
            }
        } else if activeTextField == toDateTextField {
            toDateTextField.text = datePickerChange(date: datePicker.date)
            viewModel.parameters.dates?.to =  toDateTextField.text.orEmpty
            
            if let fromDate = fromDateTextField.text?.toDate(), datePicker.date < fromDate {
                fromDateTextField.text = toDateTextField.text
                viewModel.parameters.dates?.from =  fromDateTextField.text.orEmpty
            }
        }
        
        activeTextField.resignFirstResponder()
    }

    
    func datePickerChange(date: Date) -> String {
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        switch date.toString(format: globalStrings.dateFormat) {
        case today.toString(format: globalStrings.dateFormat):
            return globalStrings.todayText
        case yesterday.toString(format: globalStrings.dateFormat):
            return globalStrings.yesterdayText
        case tomorrow.toString(format: globalStrings.dateFormat):
            return globalStrings.tomorrowText
        default:
            return date.toString(format: globalStrings.dateFormat)
        }
    }

}

// Funções auxiliares
extension FilteringTransactionsViewController {

    private func updateSelectionText(from selectionResult: [Bool], items: [String]) -> String {
        let selectedItems = items.enumerated().compactMap { selectionResult[$0.offset] ? $0.element : nil }
        return selectedItems.isEmpty ? "" : selectedItems.joined(separator: ", ")
    }
    
    private func updateViewModel<T>(selectionResult: [Bool], items: [T], updateClosure: (T) -> Void) {
        for (index, item) in items.enumerated() {
            if selectionResult[index] {
                updateClosure(item)
            }
        }
    }
}

// Recebendo resultados da seleção
extension FilteringTransactionsViewController: SelectionModalDelegate {

    func didSelectItem(_ selectionResult: [Bool], fromButton button: UIButton?) {

        guard let button = button else { return }

        if button === accountsButton {
            let accounts = bankAccountsList.map { $0.desc }
            let text = updateSelectionText(from: selectionResult, items: accounts)
            allAccountsLabel.text = text.isEmpty ? "Todas Contas" : text

            viewModel.parameters.accounts = []
            updateViewModel(selectionResult: selectionResult, items: bankAccountsList) { account in
                viewModel.parameters.accounts?.append(account.getId)
            }

        } else if button === cardsButton {
            let cards = creditCardsList.map { $0.desc }
            let text = updateSelectionText(from: selectionResult, items: cards)
            allCreditCardsLabel.text = text.isEmpty ? "Todos Cartões" : text

            viewModel.parameters.creditCards = []
            updateViewModel(selectionResult: selectionResult, items: creditCardsList) { card in
                viewModel.parameters.creditCards?.append(card.getId)
            }

        } else if button === categoriesButton {
            let categories = expenseCategories.map { $0.name } + incomeCategories.map { $0.name }
            let text = updateSelectionText(from: selectionResult, items: categories)
            allCategoriesLabel.text = text.isEmpty ? "Todas Categorias" : text

            viewModel.parameters.categories = []
            updateViewModel(selectionResult: selectionResult, items: categories) { category in
                viewModel.parameters.categories?.append(category)
            }
        }
    }
}

extension FilteringTransactionsViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        activeTextField = textField
        
        switch textField {
        case minValueTextField:
            
            let storyboard = UIStoryboard(name: InsertNumbersModalViewController.identifier, bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: InsertNumbersModalViewController.identifier) {coder ->
                InsertNumbersModalViewController? in
                return InsertNumbersModalViewController(coder: coder, id: 0)
            }
            vc.delegate = self
            self.present(vc, animated: true)
            
        case maxValueTextField:
            
            let storyboard = UIStoryboard(name: InsertNumbersModalViewController.identifier, bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: InsertNumbersModalViewController.identifier) {coder ->
                InsertNumbersModalViewController? in
                return InsertNumbersModalViewController(coder: coder, id: 1)
            }
            vc.delegate = self
            self.present(vc, animated: true)
            
        default:
            break
        }
        
        return false
        
    }
    
}

extension FilteringTransactionsViewController: InsertNumbersModalProtocol {

    func didSelectNumber(_ value: Double, id: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, let limits = self.viewModel.parameters.limits else { return }

            var updatedLimits = limits

            switch id {
            case 0:
                self.minValueTextField.text = value.toStringMoney()
                updatedLimits.min = value

                if updatedLimits.max < value {
                    self.maxValueTextField.text = value.toStringMoney()
                    updatedLimits.max = value
                }

            case 1:
                self.maxValueTextField.text = value.toStringMoney()
                updatedLimits.max = value

                if updatedLimits.min > value {
                    self.minValueTextField.text = value.toStringMoney()
                    updatedLimits.min = value
                }

            default:
                break
            }

            self.viewModel.parameters.limits = updatedLimits
        }
    }
}

