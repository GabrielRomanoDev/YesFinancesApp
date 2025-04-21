//
//  Add_Tela.swift
//  FinanceApp_BackFront
//
//  Created by Yuri Alencar on 2023-03-12.
//

import UIKit
import SwiftUI

class AddViewController: UIViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var accountIncomeButton: UIButton!
    @IBOutlet weak var accountExpenseButton: UIButton!
    @IBOutlet weak var cardExpenseButton: UIButton!
    
    static let identifier:String = String(describing: AddViewController.self)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupStrings()
    }

    @IBAction func tappedCloseButton(_ sender: UIButton) {
        let vc: HomeViewController? = UIStoryboard(name: HomeViewController.identifier, bundle: nil).instantiateViewController(withIdentifier: HomeViewController.identifier) as? HomeViewController
        navigationController?.pushViewController(vc ?? UIViewController(), animated: true)
    }
    
    @IBAction func tappedIncomeButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: RegisterIncomeViewController.identifier, bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: RegisterIncomeViewController.identifier) {coder ->
            RegisterIncomeViewController? in
            return RegisterIncomeViewController(coder: coder, amount: 0)
        }
        present(vc, animated: true)
    }
    
    @IBAction func tappedExpenseButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: RegisterExpenseViewController.identifier, bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: RegisterExpenseViewController.identifier) {coder ->
            RegisterExpenseViewController? in
            return RegisterExpenseViewController(coder: coder, amount: 0)
        }
        present(vc, animated: true)
    }
    
    @IBAction func tappedCardExpButton(_ sender: UIButton) {
        
        let newExpense = CreditCardExpense(
            desc: globalStrings.emptyString,
            amount: 0,
            categoryIndex: 0,
            date: Date().toString(),
            type: .expense,
            isMonthly: false,
            paymentStatus: .pendent,
            month: Date().getMonth(),
            installment: Installment(),
            sourceId: "",
            obs: globalStrings.emptyString
        )
        
        var hostingController: UIHostingController<CreditCardExpenseFormScreen>!

        let swiftUIView = CreditCardExpenseFormScreen(expense: newExpense) {
            DispatchQueue.main.async {
                hostingController.dismiss(animated: true)
            }
        }

        hostingController = UIHostingController(rootView: swiftUIView)
        present(hostingController, animated: true)
        
    }
    
    private func setupStrings() {
        navigationItem.backButtonTitle = globalStrings.backButtonTitle
        accountIncomeButton.setTitle(addStrings.accountIncomeButtonTitle, for: .normal)
        accountExpenseButton.setTitle(addStrings.accountExpenseButtonTitle, for: .normal)
        cardExpenseButton.setTitle(addStrings.cardExpenseButtonTitle, for: .normal)
        
    }

    
}
