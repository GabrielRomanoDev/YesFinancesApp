//
//  LoginScreen.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 11/04/23.
//

import UIKit

class ResetPasswordViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    static let identifier:String = String(describing: ResetPasswordViewController.self)
    let viewModel: ResetPasswordViewModel = ResetPasswordViewModel()
    let email: String
    
    init?(coder: NSCoder, email: String) {
        self.email = email
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        self.email = "" // Valor default para evitar crash
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStrings()
        setupElements()
    }
    
    @IBAction func tappedSendButton(_ sender: UIButton) {
        view.endEditing(true)
        
        if validadeTextField() == true {
            
            let email = emailTextField.text.orEmpty
            
            viewModel.sendResetPasswordEmail(email: email) { resultLogin in
                
                switch resultLogin {
                case .success:
                    
                    DispatchQueue.main.async {
                        let storyboard: UIStoryboard = UIStoryboard(name: TabBarController.identifier, bundle: nil)
                        if let tbc = storyboard.instantiateViewController(withIdentifier: TabBarController.identifier) as? UITabBarController {
                            self.present(tbc, animated: false)
                        }
                    }
                    
                case .failure(let error):
                    self.showSimpleAlert(title: loginStrings.atention, message: error.localizedDescription)
                }
                
            }
            
//            viewModel.forgetPassword(email: emailTextField.text.orEmpty) { [weak self] result in
//                
//                guard let self = self else { return }
//                
//                switch result {
//                case .success:
//                    self.showSimpleAlert(title: loginStrings.atention, message: "Um email de redefinição de senha foi enviado para o email especificado.")
//                case .failure(let error):
//                    self.showSimpleAlert(title: loginStrings.atention, message: "Não foi possivel enviar o email de redefinição, verifique o status de sua conexão com a internet.")
//                }
//            }
            
        } else {
            self.showSimpleAlert(title: loginStrings.atention, message: loginStrings.emptyFieldsErrorMessage)
        }
    }
    
    private func setupStrings() {
        navigationItem.backButtonTitle = globalStrings.backButtonTitle
        
        titleLabel.text = resetPasswordStrings.forgotPasswordButtonTitle
        
        if emailTextField.text.orEmpty.isEmpty {
            messageLabel.text = resetPasswordStrings.insertEmailMessage
        } else {
            messageLabel.text = resetPasswordStrings.confirmEmailMessage
        }
        
        sendButton.setTitle(globalStrings.send, for: .normal)
    }
    
    private func setupElements(){
        self.view.backgroundColor = UIColor.backgroundColor
        
        emailTextField.delegate = self
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = UIColor.greyInformations?.cgColor
        emailTextField.keyboardType = .emailAddress
        emailTextField.layer.cornerRadius = 5
        emailTextField.autocorrectionType = .no
        
        emailTextField.text = self.email
        
        sendButton.layer.cornerRadius = 10
        sendButton.layer.masksToBounds = true
    }
    
    private func validadeTextField() -> Bool {
        
        if emailTextField.text.orEmpty.isEmptyTest() {
            emailTextField.layer.borderWidth = 1
            emailTextField.layer.borderColor = UIColor.red.cgColor
            return false
        }
        
        return true
    }
}

extension ResetPasswordViewController : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.blue.cgColor
        textField.layer.borderWidth = 1
        //        logoBottomConstraint.constant = 50
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //        logoBottomConstraint.constant = 100
        if textField.text?.isEmpty ?? true {
            textField.layer.borderWidth = 1
            textField.layer.borderColor = UIColor.red.cgColor
        } else {
            textField.layer.borderWidth = 0
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}






