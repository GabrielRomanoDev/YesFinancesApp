//
//  Mais_Tela.swift
//  FinanceApp_BackFront
//
//  Created by Yuri Alencar on 2023-03-12.
//

import UIKit

class MoreOptionsViewController: UIViewController {
    
    var viewModel: MoreOptionsViewModel = MoreOptionsViewModel()
    
    static let identifier:String = String(describing: MoreOptionsViewController.self)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Voltar", style: .plain, target: nil, action: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func tappedCategoriesButton(_ sender: UIButton) {
        let vc: CategoriesGraphViewController? = UIStoryboard(name: CategoriesGraphViewController.identifier, bundle: nil).instantiateViewController(withIdentifier: CategoriesGraphViewController.identifier) as? CategoriesGraphViewController
        navigationController?.pushViewController(vc ?? UIViewController(), animated: true)
    }
    @IBAction func tappedCurrencyButton(_ sender: UIButton) {
        let vc: CurrencyViewController? = UIStoryboard(name: CurrencyViewController.identifier, bundle: nil).instantiateViewController(withIdentifier: CurrencyViewController.identifier) as? CurrencyViewController
        navigationController?.pushViewController(vc ?? UIViewController(), animated: true)
    }
    @IBAction func tappedProfileButton(_ sender: UIButton) {
        let vc: ProfileViewController? = UIStoryboard(name: ProfileViewController.identifier, bundle: nil).instantiateViewController(withIdentifier: ProfileViewController.identifier) as? ProfileViewController
        navigationController?.pushViewController(vc ?? UIViewController(), animated: true)
    }
    @IBAction func tappedAccountsButton(_ sender: UIButton) {
        let vc: BankAccountsViewController? = UIStoryboard(name: BankAccountsViewController.identifier, bundle: nil).instantiateViewController(withIdentifier: BankAccountsViewController.identifier) as? BankAccountsViewController
        navigationController?.pushViewController(vc ?? UIViewController(), animated: true)
    }
    
    @IBAction func tappedCreditCardsButton(_ sender: UIButton) {
        let vc: CreditCardsViewController? = UIStoryboard(name: CreditCardsViewController.identifier, bundle: nil).instantiateViewController(withIdentifier: CreditCardsViewController.identifier) as? CreditCardsViewController
        navigationController?.pushViewController(vc ?? UIViewController(), animated: true)
    }
    
    @IBAction func tappedLogoutButton(_ sender: UIButton) {
        if !viewModel.tryLogoutUser(){
            showSimpleAlert(title: "Atenção", message: "Erro para deslogar usuário!")
        }
        dismiss(animated: false)
    }
    
    
    
}


