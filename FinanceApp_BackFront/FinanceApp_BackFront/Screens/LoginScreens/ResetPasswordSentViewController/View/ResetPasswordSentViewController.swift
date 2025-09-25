//
//  LoginScreen.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 11/04/23.
//

import UIKit

class ResetPasswordSentViewController: UIViewController {
    
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var instructionsSentLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var verifySpamLabel: UILabel!
    @IBOutlet weak var enterButton: UIButton!
    
    static let identifier:String = String(describing: ResetPasswordSentViewController.self)
    
    init?(coder: NSCoder, email: String) {
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStrings()
    }
    
    @IBAction func tappedEnterButton(_ sender: UIButton) {
        view.endEditing(true)
        
        
    }
    
    private func setupStrings() {
        navigationItem.backButtonTitle = globalStrings.backButtonTitle
        enterButton.setTitle(loginStrings.enterButtonTitle, for: .normal)
    }

}








