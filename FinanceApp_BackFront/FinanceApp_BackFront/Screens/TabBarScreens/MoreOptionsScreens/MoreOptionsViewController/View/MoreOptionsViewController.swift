//
//  Mais_Tela.swift
//  FinanceApp_BackFront
//
//  Created by Yuri Alencar on 2023-03-12.
//

import UIKit

class MoreOptionsViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var resourcesLabel: UILabel!
    @IBOutlet weak var accountsButton: UIButton!
    @IBOutlet weak var creditCardsButton: UIButton!
    @IBOutlet weak var expensesPerCategoryButton: UIButton!
    @IBOutlet weak var currencyConverterButton: UIButton!
    @IBOutlet weak var settingsLabel: UILabel!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    
    var viewModel: MoreOptionsViewModel = MoreOptionsViewModel()
    
    static let identifier:String = String(describing: MoreOptionsViewController.self)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupStrings()
        setupUIComponents()
        setupObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        setupUserInformation()
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
        viewModel.logoutUser { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success:
                    let presentingViewController = self.tabBarController?.presentingViewController
                    self.tabBarController?.dismiss(animated: false) {
                        self.redirectToMainMenu(from: presentingViewController)
                    }
                case .failure(let error):
                    self.showSimpleAlert(title: globalStrings.error, message: error.localizedDescription)
                }
            }
        }
    }
    
    private func setupStrings() {
        navigationItem.backButtonTitle = globalStrings.backButtonTitle
        titleLabel.text = moreOptionsStrings.moreOptionsTitle
        resourcesLabel.text = moreOptionsStrings.resourcesText
        accountsButton.setTitle(moreOptionsStrings.accountsText, for: .normal)
        creditCardsButton.setTitle(moreOptionsStrings.creditCardsText, for: .normal)
        expensesPerCategoryButton.setTitle(moreOptionsStrings.expensesPerCategoryText, for: .normal)
        currencyConverterButton.setTitle(moreOptionsStrings.currencyExchangeText, for: .normal)
        settingsLabel.text = moreOptionsStrings.settingsText
        profileButton.setTitle(moreOptionsStrings.profileText, for: .normal)
        logoutButton.setTitle(moreOptionsStrings.logoutText, for: .normal)
    }
    
    private func setupUIComponents(){
        profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
        profileImage.clipsToBounds = true
    }
    
    private func setupUserInformation() {
        self.nameLabel.text = AuthenticationManager.shared.getCurrentUser()?.name ?? globalStrings.error
        self.emailLabel.text = AuthenticationManager.shared.getCurrentUser()?.email ?? globalStrings.error
    }
    
    private func setupObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfileImage), name: Notification.Name(rawValue: homeStrings.profileImageUpdatedNotification), object: nil)
    }
    
    @objc func updateProfileImage(notification:NSNotification) {
        profileImage.image = notification.object as? UIImage
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
