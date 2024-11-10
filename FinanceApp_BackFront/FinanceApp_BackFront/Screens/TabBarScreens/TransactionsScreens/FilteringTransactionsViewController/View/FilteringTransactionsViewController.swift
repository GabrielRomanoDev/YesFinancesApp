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
    
    var calculatedStackViewHeight: CGFloat {
        return 200 + timeIntervalHeightConstraint.constant + valueHeightConstraint.constant + accountsViewHeightConstraint.constant + creditCardsViewHeightConstraint.constant + categoriesViewHeightConstraint.constant
    }
    
    init?(coder: NSCoder, parameters: FilteringParameters?) {
        self.parameters = parameters ?? FilteringParameters()
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
    @IBOutlet weak var allAccountsSelectedLabel: UILabel!
    @IBOutlet weak var accountsCollectionView: UICollectionView!
    @IBOutlet weak var accountsViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var accountsButton: UIButton!
    @IBOutlet weak var creditCardsLabel: UILabel!
    @IBOutlet weak var allCreditCardsLabel: UILabel!
    @IBOutlet weak var creditCardsCollectionView: UICollectionView!
    @IBOutlet weak var creditCardsViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardsButton: UIButton!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var allCategoriesLabel: UILabel!
    @IBOutlet weak var categoriesCollectionView: UICollectionView!
    @IBOutlet weak var categoriesViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var categoriesButton: UIButton!
    @IBOutlet weak var timeIntervalView: UIView!
    @IBOutlet weak var timeIntervalHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeIntervalLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var valueHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var timeIntervalSwitch: UISwitch!
    @IBOutlet weak var fromDateTextField: UITextField!
    @IBOutlet weak var toDateTextField: UITextField!
    @IBOutlet weak var timeIntervalHiddenStackView: UIStackView!
    @IBOutlet weak var valueSwitch: UISwitch!
    @IBOutlet weak var minValueTextField: UITextField!
    @IBOutlet weak var maxValueTextField: UITextField!
    @IBOutlet weak var valueHiddenStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStrings()
        setupElements()
        setupCollectionView(collectionView: accountsCollectionView)
        setupCollectionView(collectionView: creditCardsCollectionView)
        setupCollectionView(collectionView: categoriesCollectionView)
        updateCollectionViewContent()
        setupDataPicker()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        delegate?.didFilter(parameters: parameters)
        dismiss(animated: true)
    }
    
    @IBAction func tappedResolvedTransactionsButton(_ sender: UIButton) {
        
//        parameters.resolvedTransactions.toggle()
        
//        togleButton(resolvedTransactionsButton, value: resolvedTransactions)
        
    }
    
    @IBAction func tappedPendingTransactionsButton(_ sender: UIButton) {
        
        //        parameters.pendingTransactions.toggle()
        
//        togleButton(pendingTransactionsButton, value: pendingTransactions)
    }
    
    @IBAction func tappedFutureTransactionsButton(_ sender: UIButton) {
        
        //        parameters.futureTransactions.toggle()
        
//        togleButton(futureTransactionsButton, value: futureTransactions)
    }
    
    @IBAction func tappedEarningButton(_ sender: UIButton) {
        
        if let types = parameters.types {
            parameters.types?.incomes = !types.incomes
            updateButtonCollor(incomesButton, value: !types.incomes)
        } else {
            parameters.types = TransactionFilteringTypes(incomes: true)
            updateButtonCollor(incomesButton, value: true)
        }
        
    }
    
    @IBAction func tappedExpensesButton(_ sender: UIButton) {
        
        if let types = parameters.types {
            parameters.types?.expenses = !types.expenses
            updateButtonCollor(expensesButton, value: !types.expenses)
        } else {
            parameters.types = TransactionFilteringTypes(expenses: true)
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
        
        updateTimeIntervalViewHeight(value: sender.isOn)
        
    }
    
    @IBAction func tappedValueFilterSwitch(_ sender: UISwitch) {
        
        updateValueViewHeight(value: sender.isOn)
        
    }
    
    @IBAction func tappedFilterButton(_ sender: UIButton) {
        delegate?.didFilter(parameters: parameters)
        dismiss(animated: true)
    }
    
    
    private func setupStrings() {
        
    }
    
    private func setupElements() {
        
        setupButton(resolvedTransactionsButton, value: false)
        setupButton(pendingTransactionsButton, value: false)
        setupButton(futureTransactionsButton, value: false)
        setupButton(incomesButton, value: parameters.types?.incomes)
        setupButton(expensesButton, value: parameters.types?.expenses)
        setupButton(creditExpensesButton, value: false)
        
        timeIntervalSwitch.isOn = parameters.dates != nil
        updateTimeIntervalViewHeight(value: timeIntervalSwitch.isOn)
        fromDateTextField.text = parameters.dates?.from ?? ""
        toDateTextField.text = parameters.dates?.to ?? ""
        
        valueSwitch.isOn = parameters.limits != nil
        updateValueViewHeight(value: valueSwitch.isOn)
        minValueTextField.delegate = self
        maxValueTextField.delegate = self
        minValueTextField.text = parameters.limits?.min.toStringMoney() ?? 0.0.toStringMoney()
        maxValueTextField.text = parameters.limits?.max.toStringMoney() ?? 0.0.toStringMoney()
        
    }
    
    private func setupCollectionView(collectionView: UICollectionView) {
        collectionView.delegate = self
        collectionView.dataSource = self
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.estimatedItemSize = .zero
            layout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: 0, right: 15)
        }
        collectionView.register(FilteringTransacitonsCollectionViewCell.nib(), forCellWithReuseIdentifier: FilteringTransacitonsCollectionViewCell.identifier)
        
        updateCollectionViewContent()
        
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
    
    private func updateCollectionViewContent() {
        
        DispatchQueue.main.async { [weak self] in
            
            guard let self = self else { return }
            
            if let selectedAccounts = self.parameters.accounts {
                accountsCollectionView.isHidden = false
                allAccountsSelectedLabel.isHidden = true
                self.accountsViewHeightConstraint.constant = 45 + 50 * CGFloat(selectedAccounts.count)
            } else {
                accountsCollectionView.isHidden = true
                allAccountsSelectedLabel.isHidden = false
                self.accountsViewHeightConstraint.constant = 85
            }
            
            if let selectedCards = self.parameters.creditCards {
                creditCardsCollectionView.isHidden = false
                allCreditCardsLabel.isHidden = true
                self.creditCardsViewHeightConstraint.constant = 45 + 50 * CGFloat(selectedCards.count)
            } else {
                creditCardsCollectionView.isHidden = true
                allCreditCardsLabel.isHidden = false
                self.creditCardsViewHeightConstraint.constant = 85
            }
            
            if let selectedCategories = self.parameters.categories {
                categoriesCollectionView.isHidden = false
                allCategoriesLabel.isHidden = true
                self.categoriesViewHeightConstraint.constant = 45 + 50 * CGFloat(selectedCategories.count)
            } else {
                categoriesCollectionView.isHidden = true
                allCategoriesLabel.isHidden = false
                self.categoriesViewHeightConstraint.constant = 85
            }
            
            self.stackViewHeightConstraint.constant = self.calculatedStackViewHeight
            
            self.accountsCollectionView.reloadData()
            self.creditCardsCollectionView.reloadData()
            self.categoriesCollectionView.reloadData()
            
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
        
        let selectedDateText = datePickerChange(date: datePicker.date)
        let isFromDate = activeTextField == fromDateTextField
        let oppositeTextField = isFromDate ? toDateTextField : fromDateTextField
        
        activeTextField.text = selectedDateText
        updateParametersDate(for: isFromDate, with: selectedDateText)
        
        if let oppositeDate = oppositeTextField?.text?.toDate(),
           (isFromDate && datePicker.date > oppositeDate) || (!isFromDate && datePicker.date < oppositeDate) {
            oppositeTextField?.text = selectedDateText
            updateParametersDate(for: !isFromDate, with: selectedDateText)
        }
        
        activeTextField.resignFirstResponder()
        
    }

    private func updateParametersDate(for isFromDate: Bool, with date: String) {
        
        if parameters.dates == nil {
            parameters.dates = TransactionFilteringDates(from: date, to: date)
        } else if isFromDate {
            parameters.dates?.from = date
        } else {
            parameters.dates?.to = date
        }
        
    }
    
    private func datePickerChange(date: Date) -> String {
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
    
    private func updateTimeIntervalViewHeight(value: Bool) {
        
        if value {
            timeIntervalHeightConstraint.constant = 140
            timeIntervalHiddenStackView.isHidden = false
            
            
        } else {
            timeIntervalHeightConstraint.constant = 70
            timeIntervalHiddenStackView.isHidden = true
        }
        
        stackViewHeightConstraint.constant = calculatedStackViewHeight
        
    }
    
    private func updateValueViewHeight(value: Bool) {
        
        if value {
            valueHeightConstraint.constant = 140
            valueHiddenStackView.isHidden = false
            let minValue = minValueTextField.text?.toDouble() ?? 0.0
            let maxValue = maxValueTextField.text?.toDouble() ?? 0.0
            parameters.limits = TransactionFilteringValue(min: minValue, max: maxValue)
        } else {
            valueHeightConstraint.constant = 70
            valueHiddenStackView.isHidden = true
            parameters.limits = nil
        }
        
        stackViewHeightConstraint.constant = calculatedStackViewHeight
        
    }

}

// Funções auxiliares
extension FilteringTransactionsViewController {
//
//    private func updateSelectionText(from selectionResult: [Bool], items: [String]) -> String {
//        let selectedItems = items.enumerated().compactMap { selectionResult[$0.offset] ? $0.element : nil }
//        return selectedItems.isEmpty ? "" : selectedItems.joined(separator: ", ")
//    }
//    
    private func updateParameters<T>(selectionResult: [Bool], items: [T], updateClosure: (T) -> Void) {
        
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
            
            parameters.accounts = []
            updateParameters(selectionResult: selectionResult, items: bankAccountsList) { account in
                parameters.accounts?.append(account)
            }
            
            updateCollectionViewContent()
            
        } else if button === categoriesButton {
            
            parameters.categories = []
            updateParameters(selectionResult: selectionResult, items: expenseCategories) { category in
                parameters.categories?.append(category)
            }
            updateCollectionViewContent()
        }
//        } else if button === cardsButton {
//            let cards = creditCardsList.map { $0.desc }
//            let text = updateSelectionText(from: selectionResult, items: cards)
//            allCreditCardsLabel.text = text.isEmpty ? "Todos Cartões" : text
//
//            parameters.creditCards = []
//            updateViewModel(selectionResult: selectionResult, items: creditCardsList) { card in
//                parameters.creditCards?.append(card.getId)
//            }
//
//        } else if button === categoriesButton {
//            let categories = expenseCategories.map { $0.name } + incomeCategories.map { $0.name }
//            let text = updateSelectionText(from: selectionResult, items: categories)
//            allCategoriesLabel.text = text.isEmpty ? "Todas Categorias" : text
//
//            parameters.categories = []
//            updateViewModel(selectionResult: selectionResult, items: categories) { category in
//                parameters.categories?.append(category)
//            }
//        }
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
            guard let self = self, let limits = self.parameters.limits else { return }

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

            self.parameters.limits = updatedLimits
        }
    }
}

extension FilteringTransactionsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch collectionView {
        case accountsCollectionView:
            return parameters.accounts?.count ?? 0
        case creditCardsCollectionView:
            return parameters.creditCards?.count ?? 0
        case categoriesCollectionView:
            return parameters.categories?.count ?? 0
        default:
            return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell: FilteringTransacitonsCollectionViewCell
        var item: Any?
        
        switch collectionView {
        case accountsCollectionView:
            cell = accountsCollectionView.dequeueReusableCell(withReuseIdentifier: FilteringTransacitonsCollectionViewCell.identifier, for: indexPath) as! FilteringTransacitonsCollectionViewCell
            item = parameters.accounts?[indexPath.row]
        case creditCardsCollectionView:
            cell = creditCardsCollectionView.dequeueReusableCell(withReuseIdentifier: FilteringTransacitonsCollectionViewCell.identifier, for: indexPath) as! FilteringTransacitonsCollectionViewCell
            item = parameters.creditCards?[indexPath.row]
        case categoriesCollectionView:
            cell = categoriesCollectionView.dequeueReusableCell(withReuseIdentifier: FilteringTransacitonsCollectionViewCell.identifier, for: indexPath) as! FilteringTransacitonsCollectionViewCell
            item = parameters.categories?[indexPath.row]
        default:
            return UICollectionViewCell()
        }
        
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.delegate = self
        cell.index = indexPath.row
        cell.setupCell(item: item)
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width - 30, height: 35)
    }
    
}

extension FilteringTransactionsViewController: FilteringTransacitonsCollectionViewCellProtocol {
    
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
        
        updateCollectionViewContent()
        
    }
    
}
