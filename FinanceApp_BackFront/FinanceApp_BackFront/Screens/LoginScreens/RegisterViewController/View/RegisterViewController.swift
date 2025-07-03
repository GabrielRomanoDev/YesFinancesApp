//
//  RegisterScreen.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 11/04/23.
//

import UIKit

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var phoneNumberTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var passwordRepeatTextfield: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginScreenButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    var viewModel: RegisterViewModel = RegisterViewModel()
    
    static let identifier:String = String(describing: RegisterViewController.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStrings()
        setupElements()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        nameTextfield.text = globalStrings.emptyString
        emailTextfield.text = globalStrings.emptyString
        passwordTextfield.text = globalStrings.emptyString
        passwordRepeatTextfield.text = globalStrings.emptyString
    }
    
    @IBAction func tappedCreateButton(_ sender: UIButton) {
        view.endEditing(true)
        
        if !checkTextFields() {
            showSimpleAlert(title: globalStrings.attention, message: registerStrings.someEmptyTextFieldMessage)
            return
        }
        
        let email = emailTextfield.text.orEmpty
        let password = passwordTextfield.text.orEmpty
        guard let phoneNumber = PhoneNumberData(formattedString: phoneNumberTextfield.text.orEmpty) else {
            return
        }
        
        viewModel.createUser(email: email, password: password, phoneNumber: phoneNumber) { result in
            
            switch result {
            case .success():
                self.showSimpleAlert(title: registerStrings.registerSuccessMessage, message: globalStrings.emptyString) {
                    
                    let storyboard:UIStoryboard = UIStoryboard(name: TabBarController.identifier, bundle: nil)
                    if let tbc = storyboard.instantiateViewController(withIdentifier:TabBarController.identifier) as? UITabBarController{
                        self.present(tbc, animated: true)
                    }
                }
            case .failure(let error):
                self.showSimpleAlert(title: globalStrings.attention, message: error.localizedDescription)
            }
            
        }
    }
                                                
                                                

    @IBAction func tappedLoginButton(_ sender: UIButton) {
        let vc: LoginViewController? = UIStoryboard(name: LoginViewController.identifier, bundle: nil).instantiateViewController(withIdentifier: LoginViewController.identifier) as? LoginViewController
        navigationController?.pushViewController(vc ?? UIViewController(), animated: true)
    }
    
    private func setupStrings() {
        navigationItem.backButtonTitle = globalStrings.backButtonTitle
        nameTextfield.placeholder = registerStrings.namePlaceholderText
        emailTextfield.placeholder = registerStrings.emailPlaceholderText
        passwordTextfield.placeholder = registerStrings.passwordPlaceholderText
        passwordRepeatTextfield.placeholder = registerStrings.passwordRepeatPlaceholderText
        registerButton.setTitle(registerStrings.registerButtonTitle, for: .normal)
        loginScreenButton.setTitle(registerStrings.loginScreenButtonTitle, for: .normal)
    }
    
    private func setupElements() {
        nameTextfield.delegate = self
        nameTextfield.keyboardType = .default
        nameTextfield.layer.cornerRadius = 5
        
        emailTextfield.delegate = self
        emailTextfield.keyboardType = .emailAddress
        emailTextfield.layer.cornerRadius = 5
        
        phoneNumberTextfield.delegate = self
        phoneNumberTextfield.keyboardType = .default
        phoneNumberTextfield.layer.cornerRadius = 5
        
        passwordTextfield.delegate = self
        passwordTextfield.keyboardType = .default
        passwordTextfield.layer.cornerRadius = 5
        passwordTextfield.isSecureTextEntry = true
        
        passwordRepeatTextfield.delegate = self
        passwordRepeatTextfield.keyboardType = .default
        passwordRepeatTextfield.layer.cornerRadius = 5
        passwordRepeatTextfield.isSecureTextEntry = true
        
        let newConstraint = containerView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: 40)
        newConstraint.isActive = true
    }
    
    private func checkTextFields() -> Bool {
        let email = emailTextfield.text.orEmpty
        let password = passwordTextfield.text.orEmpty
        var fieldEmpty: Bool = false
        
        if !checkTextFieldEmpty(nameTextfield) {
            fieldEmpty = true
        }
        
        if !checkTextFieldEmpty(emailTextfield) {
            fieldEmpty = true
        }
        
        if !checkTextFieldEmpty(phoneNumberTextfield) {
            fieldEmpty = true
        }
        
        if !checkTextFieldEmpty(passwordTextfield) {
            fieldEmpty = true
        }
        
        if !checkTextFieldEmpty(passwordRepeatTextfield) {
            fieldEmpty = true
        }
        
        if fieldEmpty {
            return false
        }
        
        if !viewModel.checkEmail(email: email) {
            setErrorInTextField(textField: emailTextfield)
            showSimpleAlert(title: registerStrings.invalidEmailMessage, message: registerStrings.typeEmailAgainMessage)
            return false
        }
        
        if PhoneNumberData(formattedString: phoneNumberTextfield.text.orEmpty) == nil {
            setErrorInTextField(textField: phoneNumberTextfield)
            showSimpleAlert(title: registerStrings.invalidPhoneNumberMessage, message: registerStrings.typeValidNumberMessage)
            return false
        }
         
        if !viewModel.checkPassword(password: password) {
            setErrorInTextField(textField: passwordTextfield)
            setErrorInTextField(textField: passwordRepeatTextfield)
            showSimpleAlert(title: registerStrings.invalidPasswordMessage, message: registerStrings.password8CharsMessage)
            return false
        }

        if !checkEqualPasswords() {
            showSimpleAlert(title: registerStrings.incompatiblePasswordsMessage, message: registerStrings.differentPasswordsMessage)
            return false
        }
        
        return true
    }

    private func checkTextFieldEmpty(_ textField: UITextField) -> Bool {
        if textField.text.orEmpty.isEmptyTest() {
            textField.layer.borderWidth = 1
            textField.layer.borderColor = UIColor.red.cgColor
            return false
        } else {
            return true
        }
    }
    
    private func checkEqualPasswords() -> Bool {
        if passwordTextfield.text != passwordRepeatTextfield.text {
            setErrorInTextField(textField: passwordTextfield)
            setErrorInTextField(textField: passwordRepeatTextfield)
            return false
        } else {
            return true
        }
    }
    
    private func setErrorInTextField(textField:UITextField) {
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.red.cgColor
    }
}

extension RegisterViewController : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.blue.cgColor
        textField.layer.borderWidth = 1
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
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
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard textField == phoneNumberTextfield else { return true }

        guard let currentText = phoneNumberTextfield.text else { return false }

        // Texto após aplicar a alteração
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        // Remove tudo que não for número
        let digits = newText.filter { $0.isNumber }

        // Limita a 11 dígitos (ex: 11990909090)
        if digits.count > 11 { return false }

        // Aplica a formatação
        var formatted = ""
        let digitCount = digits.count

        if digitCount > 0 {
            formatted += "("
        }
        if digitCount >= 1 {
            formatted += String(digits.prefix(2))
        }
        if digitCount >= 3 {
            formatted += ") "
            formatted += String(digits.dropFirst(2).prefix(5))
        }
        if digitCount >= 8 {
            formatted += "-"
            formatted += String(digits.dropFirst(7))
        }

        textField.text = formatted
        return false // impede que o texto seja alterado automaticamente (nós já fizemos isso)
    }
    
}
    
    

