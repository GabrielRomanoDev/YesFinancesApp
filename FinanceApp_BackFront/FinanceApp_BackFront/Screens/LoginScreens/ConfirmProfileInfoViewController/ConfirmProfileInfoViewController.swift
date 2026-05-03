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
    private var isSavingProfile = false
    private var didSelectLocalImage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userDto = AuthenticationManager.shared.getCurrentUser()
        setupStrings()
        setupElements()
        setupValues()
        setupImagePicker()
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
        userDto = AuthenticationManager.shared.getCurrentUser()
        setupUserInformation()
    }
    
    @IBAction func tappedChangeProfileImage(_ sender: UIButton) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func tappedSaveButton(_ sender: UIButton) {
        guard !isSavingProfile else { return }
        
        if someTextFieldIsEmpty() {
            showSimpleAlert(title: globalStrings.attention, message: "Algum campo está vazio!")
        } else {
            if var newInformationUser: UserData = AuthenticationManager.shared.getCurrentUser() {
                newInformationUser.name = nameTextField.text.orEmpty
                newInformationUser.email = emailTextField.text.orEmpty
                newInformationUser.phoneNumber = PhoneNumberData(formattedString: phoneTextField.text.orEmpty)!
                
                isSavingProfile = true
                saveButton.isEnabled = false
                
                AuthenticationManager.shared.updateUserInfo(user: newInformationUser) { [weak self] result in
                    guard let self = self else { return }
                    
                    self.isSavingProfile = false
                    self.saveButton.isEnabled = true
                    
                    switch result {
                    case .success:
                        let storyboard: UIStoryboard = UIStoryboard(name: TabBarController.identifier, bundle: nil)
                        if let tbc = storyboard.instantiateViewController(withIdentifier: TabBarController.identifier) as? UITabBarController {
                            self.present(tbc, animated: false)
                        }
                    case .failure(let error):
                        self.showSimpleAlert(title: globalStrings.error, message: error.localizedDescription)
                    }
                }
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
        applyStoredProfileImage()
    }
    
    private func setupImagePicker(){
        imagePicker.delegate = self
    }
    
    private func setupUserInformation() {
        let currentUser = AuthenticationManager.shared.getCurrentUser()
        self.nameTextField.text = currentUser?.name ?? globalStrings.error
        self.emailTextField.text = currentUser?.email ?? globalStrings.error
        self.phoneTextField.text = currentUser?.phoneNumber?.formatedLocal ?? ""
        applyStoredProfileImage()
    }
    
    private func someTextFieldIsEmpty() -> Bool {
        
        guard PhoneNumberData(formattedString: phoneTextField.text.orEmpty) != nil else {
            return true
        }
        
        return nameTextField.text.orEmpty.isEmptyTest() || emailTextField.text.orEmpty.isEmptyTest() || phoneTextField.text.orEmpty.isEmptyTest()
        
    }
    
    private func applyStoredProfileImage() {
        guard !didSelectLocalImage, let photoURL = AuthenticationManager.shared.getCurrentUser()?.photoURL else {
            return
        }
        
        loadProfileImage(from: photoURL)
    }
    
    private func loadProfileImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self, error == nil, let data, let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                guard !self.didSelectLocalImage else { return }
                self.profileImage.image = image
            }
        }.resume()
    }

}

extension ConfirmProfileInfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            didSelectLocalImage = true
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
