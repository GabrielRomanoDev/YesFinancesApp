//
//  ProfileScreen.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 10/04/23.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var changeProfileImageButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteAccountButton: UIButton!
    
    static let identifier:String = String(describing: ProfileViewController.self)
    let imagePicker = UIImagePickerController()
    let viewModel = ProfileViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupStrings()
        setupElements()
        setupImagePicker()
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
        setupUserInformation()
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
                
                AuthenticationManager.shared.updateUserInfo(user: newInformationUser) { [weak self] result in
                    guard let self = self else { return }
                    
                    switch result {
                    case .success:
                        self.navigationController?.popViewController(animated: true)
                    case .failure(let error):
                        self.showSimpleAlert(title: globalStrings.error, message: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    @IBAction func tappedDeleteAccountButton(_ sender: UIButton) {
        showAlertWithCancelOption(title: globalStrings.attention, message: moreOptionsStrings.deleteAccountConfirmationMessage) { [weak self] in
            guard let self = self else { return }

            self.viewModel.deleteAccount { result in
                DispatchQueue.main.async(execute: {
                    switch result {
                    case .success:
                        self.showSimpleAlert(title: moreOptionsStrings.profileTitle, message: moreOptionsStrings.deleteAccountSuccessMessage) {
                            let presentingViewController = self.tabBarController?.presentingViewController
                            self.tabBarController?.dismiss(animated: false) {
                                self.redirectToMainMenu(from: presentingViewController)
                            }
                        }
                    case .failure(let error):
                        self.showSimpleAlert(title: globalStrings.error, message: error.localizedDescription)
                    }
                })
            }
        }
    }
    
    
    private func setupStrings() {
        navigationItem.backButtonTitle = globalStrings.backButtonTitle
        titleLabel.text = moreOptionsStrings.profileTitle
        nameLabel.text = moreOptionsStrings.fullNameText
        emailLabel.text = moreOptionsStrings.emailText
        passwordLabel.text = moreOptionsStrings.passwordText
        changeProfileImageButton.setTitle(moreOptionsStrings.changeProfileImageButtonTitle, for: .normal)
        saveButton.setTitle(moreOptionsStrings.saveButtonTitle, for: .normal)
        deleteAccountButton.setTitle(moreOptionsStrings.deleteAccount, for: .normal)
    }
    
    private func setupElements() {
        profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
        profileImage.clipsToBounds = true
        
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        nameTextField.returnKeyType = .done
        emailTextField.returnKeyType = .done
        passwordTextField.returnKeyType = .done
    }
    
    private func setupImagePicker(){
        imagePicker.delegate = self
    }
    
    private func setupUserInformation() {
        self.nameTextField.text = AuthenticationManager.shared.getCurrentUser()?.name ?? globalStrings.error
        self.emailTextField.text = AuthenticationManager.shared.getCurrentUser()?.email ?? globalStrings.error
    }
    
    private func someTextFieldIsEmpty() -> Bool {
        return nameTextField.text.orEmpty.isEmptyTest() || emailTextField.text.orEmpty.isEmptyTest() || passwordTextField.text.orEmpty.isEmptyTest()
    }

}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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

extension ProfileViewController: UITextFieldDelegate {
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

    private func redirectToMainMenu(from presentingViewController: UIViewController?) {
        let storyboard = UIStoryboard(name: MainViewController.identifier, bundle: nil)
        let mainViewController = storyboard.instantiateViewController(withIdentifier: MainViewController.identifier)

        if let navigationController = ApplicationViewControllerResolver.getRootNavigationController() {
            navigationController.setViewControllers([mainViewController], animated: false)
        } else if let navigationController = presentingViewController?.navigationController {
            navigationController.setViewControllers([mainViewController], animated: false)
        } else {
            let navigationController = UINavigationController(rootViewController: mainViewController)
            ApplicationViewControllerResolver.getKeyWindow()?.rootViewController = navigationController
            ApplicationViewControllerResolver.getKeyWindow()?.makeKeyAndVisible()
        }
    }
}
