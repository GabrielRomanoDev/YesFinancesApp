//
//  ConfigBankAccountsScreen.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 27/04/23.
//

import UIKit

class EditBankAccountsViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var balanceTextField: UITextField!
    @IBOutlet weak var overdrawTextField: UITextField!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var bankDescLabel: UILabel!
    @IBOutlet weak var bankBackground: UIView!
    @IBOutlet weak var bankLabel: UILabel!
    @IBOutlet weak var standardAccountSwitch: UISwitch!
    @IBOutlet weak var obsLabel: UITextField!
    @IBOutlet weak var titleScreenLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    
    static let identifier:String = String(describing: EditBankAccountsViewController.self)
    var viewModel:EditBankAccountsViewModel
    var alert=Alert()
    var selectedBank:Banks = .bancoDoBrasil
    
    init?(coder:NSCoder, indexAccount:Int, configType:ConfigType){
        self.viewModel = EditBankAccountsViewModel(configType: configType,indexAccount: indexAccount)
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alert.viewController = self
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableview.isHidden=true
        updateBankField(viewModel.self.popBankAccountBank)
        setupScreenLabels()
        populateFields()
    }
    
    @IBAction func tappedChangeBankButton(_ sender: UIButton) {
        toggleTableViewVisibility()
    }
    
    @IBAction func tappedSaveButton(_ sender: UIButton) {
        if stringIsEmpty(text: nameTextField.text ?? ""){
            alert.showAlertWithCancelOption(title: "Atenção", message: "O campo de descrição está vazio, deseja continuar assim mesmo?",completion: {
                self.saveValues()
            })
        } else{
            saveValues()
        }
    }
    
    func saveValues(){
        self.viewModel.saveBankAccount(desc: self.nameTextField.text.orEmpty, balance: Double(self.balanceTextField.text.orEmpty) ?? 0.0, overdraft: Double(self.overdrawTextField.text.orEmpty) ?? 0.0, bank: selectedBank, stardardBank: self.standardAccountSwitch.isOn, Obs: self.obsLabel.text.orEmpty)
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setupTableView(){
        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(BanksCell.nib(), forCellReuseIdentifier: BanksCell.identifier)
    }
    
    private  func setupScreenLabels(){
        switch viewModel.configType {
        case .createNew:
            titleScreenLabel.text = "Nova Conta Bancária"
            balanceLabel.text = "Saldo Inicial na conta"
        case .editExisting:
            titleScreenLabel.text = "Editar Conta Bancária"
            balanceLabel.text = "Ajustar saldo na conta"
        }
        
    }
    
    private func populateFields(){
        if viewModel.configType == .editExisting{
            nameTextField.text = viewModel.popBankAccountDesc
            balanceTextField.text = viewModel.popBankAccountBalance
            overdrawTextField.text = viewModel.popBankAccountOverdraft
            standardAccountSwitch.isOn = viewModel.popBankAccountStardardBank
            obsLabel.text = viewModel.popBankAccountObs
            selectedBank = viewModel.popBankAccountBank
            updateBankField(selectedBank)
        }
    }
    
    private func toggleTableViewVisibility(){
        if tableview.isHidden == false {
            tableview.isHidden = true
        } else {
            tableview.isHidden = false
        }
    }
    
    private func updateBankField(_ bank:Banks){
        bankDescLabel.text = viewModel.getBankName(bank)
        bankLabel.text = viewModel.getBankLabelText(bank)
        bankLabel.font = viewModel.getBankLabelTextFont(bank)
        bankLabel.textColor = viewModel.getBankLabelColor(bank)
        bankBackground.backgroundColor = viewModel.getBankBackColor(bank)
    }
}

extension EditBankAccountsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getBankListCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BanksCell.identifier, for: indexPath) as? BanksCell
        cell?.setupCell(name: viewModel.getBankName(bankList[indexPath.row]))
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.getRowHeight()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableview.deselectRow(at: indexPath, animated: true)
        selectedBank = bankList[indexPath.row]
        updateBankField(selectedBank)
        tableview.isHidden=true
        
    }
    
    
}

extension Optional where Wrapped == String {
    var orEmpty:String{
        switch self{
        case .some(let value):
            return value
        case .none:
            return ""
        }
    }
}
