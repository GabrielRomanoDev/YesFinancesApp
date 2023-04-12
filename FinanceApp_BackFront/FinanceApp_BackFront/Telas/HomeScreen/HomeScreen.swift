//
//  Tela_Inicio.swift
//  FinanceApp_BackFront
//
//  Created by Yuri Alencar on 2023-03-12.
//


import UIKit
import Charts

class HomeScreen: UIViewController {

    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var expensesLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var backgroundBalanceView: UIView!
    
//    var transactions: [Transaction] = [
//        Transaction(type: .income, amount: 100.0),
//        Transaction(type: .expense, amount: 50.0),
//        Transaction(type: .income, amount: 0.0),
//        Transaction(type: .expense, amount: 50.0)
//    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tabBarController?.navigationItem.hidesBackButton = true
        updateLabels()
        //sumExpensesByCategory()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationController?.isNavigationBarHidden = true
    }

    @IBAction func tappedShowGraphScreen(_ sender: UIButton) {
        let vc: CategoriesGraphScreen? = UIStoryboard(name: "CategoriesGraphScreen", bundle: nil).instantiateViewController(withIdentifier: "CategoriesGraphScreen") as? CategoriesGraphScreen
        navigationController?.pushViewController(vc ?? UIViewController(), animated: true)
    }

    func updateLabels() {
        var incomeTotal = 0.0
        var expensesTotal = 0.0

        for transaction in transactions {
            if transaction.type == .income {
                incomeTotal += transaction.amount
            } else if transaction.type == .expense {
                expensesTotal += transaction.amount
            }
        }

        let balance = incomeTotal - (-expensesTotal)

        incomeLabel.text = String(format: "%.2f", incomeTotal)
        expensesLabel.text = String(format: "%.2f", expensesTotal)
        balanceLabel.text = String(format: "%.2f", balance)
        
        if balance > 0 {
            backgroundBalanceView.backgroundColor = UIColor(named: "PositiveBalance")
            } else if balance < 0 {
                backgroundBalanceView.backgroundColor = UIColor(named: "NegativeBalance")
            } else {
                backgroundBalanceView.backgroundColor = UIColor(named: "GreyInformations")
            }
    }
    
    
}


