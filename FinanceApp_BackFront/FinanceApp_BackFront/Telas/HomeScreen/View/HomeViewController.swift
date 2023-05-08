//
//  Tela_Inicio.swift
//  FinanceApp_BackFront
//
//  Created by Yuri Alencar on 2023-03-12.
//


import UIKit
import Charts

class HomeViewController: UIViewController {
    
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var expensesLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var backgroundBalanceView: UIView!
    @IBOutlet weak var hideInformationsButton: UIButton!
    
    static let identifier:String = String(describing: HomeViewController.self)
    var  viewModel : HomeViewModel = HomeViewModel()
    var informationsHidden = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationController?.isNavigationBarHidden = true
        updateLabels()
        
    }

    @IBAction func tappedShowGraphScreen(_ sender: UIButton) {
        let vc: CategoriesGraphViewController? = UIStoryboard(name: CategoriesGraphViewController.identifier, bundle: nil).instantiateViewController(withIdentifier: CategoriesGraphViewController.identifier) as? CategoriesGraphViewController
        navigationController?.pushViewController(vc ?? UIViewController(), animated: true)
    }

    @IBAction func tappedHideNumbersButton(_ sender: UIButton) {
        hideNumers()
    }
    
    func hideNumers(){
        if informationsHidden == false {
            informationsHidden = true
            incomeLabel.text = "•••••"
            expensesLabel.text  = "•••••"
            hideInformationsButton.setImage(UIImage(imageLiteralResourceName: "closed eye"), for: .normal)
        } else {
            informationsHidden = false
            updateLabels()
            hideInformationsButton.setImage(UIImage(imageLiteralResourceName: "eye"), for: .normal)
        }
    }
    
    public func updateLabels() {
        let balance = viewModel.updateBalance()

        incomeLabel.text = String(format: "%.2f", balance.incomesTotal)
        expensesLabel.text = String(format: "%.2f", balance.expensesTotal)
        balanceLabel.text = String(format: "%.2f", balance.total)
        
        if balance.total > 0 {
            backgroundBalanceView.backgroundColor = UIColor(named: "PositiveBalance")
        } else if balance.total < 0 {
                backgroundBalanceView.backgroundColor = UIColor(named: "NegativeBalance")
            } else {
                backgroundBalanceView.backgroundColor = UIColor(named: "GreyInformations")
            }
    }
}


