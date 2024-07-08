//
//  MetasVC.swift
//  FinanceApp_BackFront
//
//  Created by Yuri Alencar on 2023-03-13.
//

import UIKit

class BankAccountsViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    static let identifier:String = String(describing: BankAccountsViewController.self)
    var viewModel: BankAccountsViewModel = BankAccountsViewModel()
    var dataLoaded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStrings()
        viewModel.updateAccounts() {
            self.setupCollectionView()
            self.dataLoaded = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if dataLoaded {
            updateCollectionView()
        }
        navigationController?.isNavigationBarHidden = false
    }
    
    private func setupStrings() {
        navigationItem.backButtonTitle = globalStrings.backButtonTitle
        titleLabel.text = moreOptionsStrings.accountsText
    }
    
    private func setupCollectionView() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.delegate = self
            self?.collectionView.dataSource = self
            if let layout = self?.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .vertical
                layout.estimatedItemSize = .zero
                layout.sectionInset = (self?.viewModel.getCollectionEdgeInsets()) ?? UIEdgeInsets(top: 15, left: 15, bottom: 0, right: 15)
            }
            self?.collectionView.register(AccountCollectionViewCell.nib(), forCellWithReuseIdentifier: AccountCollectionViewCell.identifier)
            self?.collectionView.register(NewItemButtonCell.nib(), forCellWithReuseIdentifier: NewItemButtonCell.identifier)
        }
    }
    
    private func updateCollectionView() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
}

extension BankAccountsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getAccountsCount() + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if  indexPath.row < viewModel.getAccountsCount() {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AccountCollectionViewCell.identifier, for: indexPath) as? AccountCollectionViewCell
            cell?.layer.cornerRadius = viewModel.getCellCornerRadius()
            cell?.layer.masksToBounds = true
            cell?.setupCell(account: viewModel.getAccount(indexPath.row))
            return cell ?? UICollectionViewCell()
        }

        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewItemButtonCell.identifier, for: indexPath) as? NewItemButtonCell
            cell?.setupCell(buttonText: viewModel.getNewAccountButtonText())
            cell?.delegate = self
            return cell ?? UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return viewModel.getCellSize(viewWidth: view.frame.width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        
        let storyboard = UIStoryboard(name: EditBankAccountsViewController.identifier, bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: EditBankAccountsViewController.identifier) {coder -> EditBankAccountsViewController? in
            return EditBankAccountsViewController(coder: coder, account: self.viewModel.getAccount(indexPath.row), indexAccount: indexPath.row, configType: .editExisting)
        }
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension BankAccountsViewController: CreateItemButtonCellDelegate, EditBankAccountsViewControllerProtocol {
    func didSaveAccount(account: BankAccount, indexAccount: Int, configType: ConfigType, newBalance: Double) {
        switch configType {
        case .createNew:
            viewModel.createNewAccount(account, newBalance: newBalance) { [weak self] in
                self?.updateCollectionView()
            }
        case .editExisting:
            viewModel.editAccount(account: account, indexAccount: indexAccount, newBalance: newBalance) { [weak self] in
                self?.updateCollectionView()
            }
        }
    }
    
    func didTappedNewItemButton() {
        let emptyAccount = BankAccount(desc: globalStrings.emptyString, bank: .bancoDoBrasil, overdraft: 0.0, standardAccount: false, obs: globalStrings.emptyString)
        let storyboard = UIStoryboard(name: EditBankAccountsViewController.identifier, bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: EditBankAccountsViewController.identifier) {coder -> EditBankAccountsViewController? in
            return EditBankAccountsViewController(coder: coder, account: emptyAccount, indexAccount: 0, configType: .createNew)
        }
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
}
