//
//  ProfileScreen.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 10/04/23.
//

import UIKit

class ConfirmProfileInfoViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var changeProfileImageButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    static let identifier:String = String(describing: ConfirmProfileInfoViewController.self)
    let imagePicker = UIImagePickerController()
    var userDto: UserData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStrings()
        setupElements()
        setupValues()
        setupImagePicker()
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
        setupUserInformation()
        userDto = AuthenticationManager.shared.getCurrentUser()
    }
    
    @IBAction func tappedChangeProfileImage(_ sender: UIButton) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func tappedSaveButton(_ sender: UIButton) {
        if someTextFieldIsEmpty() {
            showSimpleAlert(title: globalStrings.attention, message: "Algum campo está vazio!")
        } else {
            if var newInformationUser: UserData = AuthenticationManager.shared.getCurrentUser() {
                newInformationUser.name = nameTextField.text.orEmpty
                newInformationUser.email = emailTextField.text.orEmpty
                newInformationUser.phoneNumber = PhoneNumberData(formattedString: phoneTextField.text.orEmpty)!
                newInformationUser.infoValidated = true
                
                AuthenticationManager.shared.updateUserInfo(user: newInformationUser)
            }
            
            let storyboard: UIStoryboard = UIStoryboard(name: TabBarController.identifier, bundle: nil)
            if let tbc = storyboard.instantiateViewController(withIdentifier: TabBarController.identifier) as? UITabBarController {
                self.present(tbc, animated: false)
            }
        }
    }
    
    private func setupStrings() {
        navigationItem.backButtonTitle = globalStrings.backButtonTitle
        titleLabel.text = moreOptionsStrings.profileTitle
        nameLabel.text = moreOptionsStrings.fullNameText
        emailLabel.text = moreOptionsStrings.emailText
        phoneLabel.text = moreOptionsStrings.phoneNumberText
        saveButton.setTitle(globalStrings.save, for: .normal)
    }
    
    private func setupElements() {
        
        self.view.backgroundColor = UIColor.backgroundColor
        
        profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
        profileImage.clipsToBounds = true
        
        nameTextField.delegate = self
        emailTextField.delegate = self
        phoneTextField.delegate = self
        
        nameTextField.returnKeyType = .done
        emailTextField.returnKeyType = .done
        phoneTextField.returnKeyType = .done
    }
    
    private func setupValues() {
        nameTextField.text = userDto?.name ?? ""
        if let email = userDto?.email {
            emailTextField.text = email
            emailTextField.isEnabled = false
        }
        phoneTextField.text = userDto?.phoneNumber?.formatedLocal ?? ""
    }
    
    private func setupImagePicker(){
        imagePicker.delegate = self
    }
    
    private func setupUserInformation() {
        self.nameTextField.text = AuthenticationManager.shared.getCurrentUser()?.name ?? globalStrings.error
        self.emailTextField.text = AuthenticationManager.shared.getCurrentUser()?.email ?? globalStrings.error
    }
    
    private func someTextFieldIsEmpty() -> Bool {
        
        guard let phoneNumber = PhoneNumberData(formattedString: phoneTextField.text.orEmpty) else {
            return true
        }
        
        return nameTextField.text.orEmpty.isEmptyTest() || emailTextField.text.orEmpty.isEmptyTest() || phoneTextField.text.orEmpty.isEmptyTest()
        
    }

}

extension ConfirmProfileInfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImage.image = image
            profileImage.setNeedsLayout()
            setupElements()
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: moreOptionsStrings.notificationNameProfileImage), object: image)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ConfirmProfileInfoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text.orEmpty.isEmptyTest() {
            textField.layer.borderColor = UIColor.red.cgColor
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.systemGray.cgColor
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard textField == phoneTextField else { return true }

        guard let currentText = phoneTextField.text else { return false }

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
