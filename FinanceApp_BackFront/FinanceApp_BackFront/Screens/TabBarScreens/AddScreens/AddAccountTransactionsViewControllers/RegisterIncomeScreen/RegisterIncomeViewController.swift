//
//  RegisterIncomeScreen.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 12/04/23.
//

import UIKit

class RegisterIncomeViewController: UIViewController {
    
    @IBOutlet weak var descTextField: UITextField!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var amountContainerView: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var categoryContainerView: UIView!
    @IBOutlet weak var categoryBackgroung: UIView!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var accountContainerView: UIView!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var bankLabel: UILabel!
    @IBOutlet weak var accountBackground: UIView!
    @IBOutlet weak var obsTextField: UITextField!
    @IBOutlet weak var registerIncomeButton: UIButton!
    
    static let identifier:String = String(describing: RegisterIncomeViewController.self)
    var viewModel:AddAccountTransactionsViewModel=AddAccountTransactionsViewModel(type: .income)
    
    private var indexCategorySelected:Int = 0
    private var idAccountSelected:String = globalStrings.emptyString
    private var amount: Double
    
    init?(coder: NSCoder, amount: Double) {
        self.amount = amount
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError(globalStrings.initError)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStrings()
        setupElements()
        setupTextFields()
        setupDataPicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async { [weak self] in
            
            guard let self = self else { return }
            
            let today = Date()
            self.dateField.text = self.viewModel.datePickerChange(date: today)
            self.updateCategoryField(self.indexCategorySelected)
            self.updateAccountField(self.viewModel.standardAccountIndex)
            self.idAccountSelected = self.viewModel.standardAccountId
            self.updateAmountValue(amount)
        }
    }
    
    @IBAction func tappedInsertAmountButton(_ sender: UIButton) {
        amountContainerView.layer.borderColor = UIColor.systemGray6.cgColor
        let storyboard = UIStoryboard(name: InsertNumbersModalViewController.identifier, bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: InsertNumbersModalViewController.identifier) {coder ->
            InsertNumbersModalViewController? in
            return InsertNumbersModalViewController(coder: coder)
        }
        vc.delegate = self
        self.present(vc, animated: true)
    }
    
    @IBAction func tappedCategoryButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: CategoriesModalViewController.identifier, bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: CategoriesModalViewController.identifier) {coder -> CategoriesModalViewController? in
            return CategoriesModalViewController(coder: coder, transactionType: .income)
        }
        vc.delegate = self
        if let presentationController = vc.presentationController as? UISheetPresentationController{
            presentationController.detents = [.medium()]
        }
        self.present(vc, animated: true)
    }
    
    @IBAction func tappedAccountButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: AccountsModalViewController.identifier, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: AccountsModalViewController.identifier) as? AccountsModalViewController
        vc?.delegate = self
        if let presentationController = vc?.presentationController as? UISheetPresentationController{
            presentationController.detents = [.medium()]
        }
        self.present(vc ?? UIViewController(), animated: true)
    }
    
    @IBAction func tappedRegisterIncomeButton(_ sender: UIButton) {
        if amount == 0 {
            amountContainerView.layer.borderColor = UIColor.red.cgColor
            showSimpleAlert(title: globalStrings.attention, message: addStrings.forgotIncomeAmountValue)
        } else if amount < 0 {
            amountContainerView.layer.borderColor = UIColor.red.cgColor
            showSimpleAlert(title: globalStrings.attention, message: addStrings.amountMustBeHigherThenZero)
        } else {
            viewModel.setTransactionsValues(transaction: Transactions(
                desc: descTextField.text.orEmpty,
                amount: amount,
                categoryIndex: indexCategorySelected,
                date: viewModel.dataSelecionada.toString(format: globalStrings.dateFormat),
                type: .income,
                accountId: idAccountSelected,
                obs: obsTextField.text.orEmpty
            )) {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    private func setupStrings() {
        navigationItem.backButtonTitle = globalStrings.backButtonTitle
        descTextField.placeholder = addStrings.descriptionText
        obsTextField.placeholder = addStrings.observationsText
        registerIncomeButton.setTitle(addStrings.registerTransactionButtonTitle, for: .normal)
    }
    
    private func setupElements() {
        amountContainerView.layer.borderWidth = 1
        amountContainerView.layer.borderColor = UIColor.systemGray6.cgColor
        amountContainerView.layer.cornerRadius = 5
        amountContainerView.layer.masksToBounds = true
        
        categoryContainerView.layer.borderWidth = 1
        categoryContainerView.layer.borderColor = UIColor.systemGray6.cgColor
        categoryContainerView.layer.cornerRadius = 5
        categoryContainerView.layer.masksToBounds = true
        
        accountContainerView.layer.borderWidth = 1
        accountContainerView.layer.borderColor = UIColor.systemGray6.cgColor
        accountContainerView.layer.cornerRadius = 5
        accountContainerView.layer.masksToBounds = true
    }
    
    private func setupTextFields() {
        descTextField.delegate = self
        obsTextField.delegate = self
        
        descTextField.returnKeyType = .done
        obsTextField.returnKeyType = .done
    }
    
    private func updateAmountValue(_ value: Double) {
        amount = value
        amountLabel.text = value.toStringMoney()
    }
    
    private func updateCategoryField(_ indexCategory:Int){
        categoryLabel.text = viewModel.getCategoryLabel(indexCategory)
        categoryImage.image = viewModel.getCategoryImageName(indexCategory)
        categoryBackgroung.backgroundColor = viewModel.getCategoryBackgroungColor(indexCategory)
    }
    
    private func updateAccountField(_ indexAccount:Int){
        accountLabel.text = viewModel.getAccountLabel(indexAccount)
        bankLabel.text = viewModel.getBankLabelText(indexAccount)
        bankLabel.font = viewModel.getBankLabelTextFont(indexAccount)
        bankLabel.textColor = viewModel.getBankLabelColor(indexAccount)
        accountBackground.backgroundColor = viewModel.getBankBackColor(indexAccount)
    }
    
    private func setupDataPicker(){
        let datePicker = UIDatePicker ()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(dateChange (datePicker:)), for: UIControl.Event.valueChanged)
        datePicker.frame.size = CGSize(width: 0, height: 300)
        datePicker.preferredDatePickerStyle = .inline
        dateField.inputView = datePicker
    }
    
    @objc func dateChange (datePicker: UIDatePicker) {
        dateField.text = viewModel.datePickerChange(date: datePicker.date)
        dateField.resignFirstResponder()
    }
}

extension RegisterIncomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


extension RegisterIncomeViewController:CategoriesModalDelegate, AccountsModalDelegate, InsertNumbersModalProtocol {
    func didSelectCategory(_ indexCategory: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.indexCategorySelected = indexCategory
            self.updateCategoryField(self.indexCategorySelected)
        }
    }
    
    func didSelectAccount(_ indexAccount: Int) {
        DispatchQueue.main.async { [weak self] in
            self?.updateAccountField(indexAccount)
            self?.idAccountSelected = bankAccountsList[indexAccount].getId()
        }
    }
    
    func didSelectedNumber(_ value: Double, id: Int) {
        DispatchQueue.main.async { [weak self] in
            self?.updateAmountValue(value)
        }
    }
}
