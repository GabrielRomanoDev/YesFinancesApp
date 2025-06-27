//
//  Tela_Inicio.swift
//  FinanceApp_BackFront
//
//  Created by Yuri Alencar on 2023-03-12.
//


import UIKit
import Charts
import Lottie

class HomeViewController: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var helloTextLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var hideInformationsButton: UIButton!
    @IBOutlet weak var horizontalCollectionView: UICollectionView!
    @IBOutlet weak var verticalCollectionView: UICollectionView!
    
    static let identifier:String = String(describing: HomeViewController.self)
    var  viewModel : HomeViewModel = HomeViewModel()
    let animationView: LottieAnimationView = .init(name: globalStrings.loadingLottie)
    var hideInformations = false
    var dataLoaded: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStrings()
        setupUIComponents()
        setupObservers()
        setupLottie()
        viewModel.getAllData {
            self.nameLabel.text = AuthenticationManager.shared.getCurrentUser()?.name
            self.viewModel.updateBalanceValues()
            self.setupHorizontalCollectionView()
            self.setupVerticalCollectionView()
            self.dataLoaded = true
            self.showData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        if dataLoaded {
            self.nameLabel.text = AuthenticationManager.shared.getCurrentUser()?.name
            self.viewModel.updateBalanceValues()
            self.horizontalCollectionView.reloadData()
            self.verticalCollectionView.reloadData()
        }
    }

    @IBAction func tappedShowGraphScreen(_ sender: UIButton) {
        let vc: CategoriesGraphViewController? = UIStoryboard(name: CategoriesGraphViewController.identifier, bundle: nil).instantiateViewController(withIdentifier: CategoriesGraphViewController.identifier) as? CategoriesGraphViewController
        navigationController?.pushViewController(vc ?? UIViewController(), animated: true)
    }

    @IBAction func tappedHideNumbersButton(_ sender: UIButton) {
        hideInformations.toggle()
        updateInformationsVisibility(informationsHidden: hideInformations)
    }
    
    private func setupStrings() {
        navigationItem.backButtonTitle = globalStrings.backButtonTitle
        helloTextLabel.text = homeStrings.helloText
    }
    
    private func setupUIComponents(){
        profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
        profileImage.clipsToBounds = true
        
        horizontalCollectionView.isHidden = true
        verticalCollectionView.isHidden = true
    }
    
    private func setupHorizontalCollectionView() {
        DispatchQueue.main.async { [weak self] in
            
            guard let self = self else { return }
            
            self.horizontalCollectionView.delegate = self
            self.horizontalCollectionView.dataSource = self
            if let layout = self.horizontalCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .horizontal
                layout.estimatedItemSize = .zero
                layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom:0, right: 15)
            }
            self.horizontalCollectionView.backgroundColor = .none
            self.horizontalCollectionView.showsHorizontalScrollIndicator = false
            self.horizontalCollectionView.register(resumeBalanceCollectionViewCell.nib(), forCellWithReuseIdentifier: resumeBalanceCollectionViewCell.identifier)
        }
    }
    
    private func setupVerticalCollectionView(){
        DispatchQueue.main.async { [weak self] in
            
            guard let self = self else { return }
            
            self.verticalCollectionView.delegate = self
            self.verticalCollectionView.dataSource = self
            if let layout = self.verticalCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = .vertical
                layout.estimatedItemSize = .zero
                layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
            }
            self.verticalCollectionView.backgroundColor = .backgroundColor
            self.verticalCollectionView.showsVerticalScrollIndicator = false
            self.verticalCollectionView.register(TitleHeaderCollectionReusableView.nib(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TitleHeaderCollectionReusableView.identifier)
            self.verticalCollectionView.register(AccountsBallanceCollectionViewCell.nib(), forCellWithReuseIdentifier: AccountsBallanceCollectionViewCell.identifier)
            self.verticalCollectionView.register(CardsBallanceCollectionViewCell.nib(), forCellWithReuseIdentifier: CardsBallanceCollectionViewCell.identifier)
            self.verticalCollectionView.register(CategoriesGraphCollectionViewCell.nib(), forCellWithReuseIdentifier: CategoriesGraphCollectionViewCell.identifier)
            self.verticalCollectionView.register(TransactionsCollectionViewCell.nib(), forCellWithReuseIdentifier: TransactionsCollectionViewCell.identifier)
        }
    }
    
    private func setupLottie() {
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.frame = view.frame
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 1.0
        view.addSubview(animationView)
        animationView.play()
        
        NSLayoutConstraint.activate([
            animationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animationView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 60),
            animationView.heightAnchor.constraint(equalToConstant: 100),
            animationView.widthAnchor.constraint(equalToConstant: 100),
        ])
    }
    
    private func showData() {
        DispatchQueue.main.async { [weak self] in
            
            guard let self = self else { return }
            
            self.animationView.isHidden = true
            self.horizontalCollectionView.isHidden = false
            self.verticalCollectionView.isHidden = false
        }
    }
    
    private func updateInformationsVisibility(informationsHidden: Bool) {
        DispatchQueue.main.async { [weak self] in
            
            guard let self = self else { return }
            
            if informationsHidden == true {
                self.hideInformationsButton.setImage(.closedEye, for: .normal)
            } else {
                self.hideInformationsButton.setImage(.eye, for: .normal)
            }
            self.horizontalCollectionView.reloadData()
            self.verticalCollectionView.reloadData()
        }
    }
    
    private func setupObservers(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfileImage), name: Notification.Name(rawValue: homeStrings.profileImageUpdatedNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTransactionsData), name: .updateTransactionsData, object: nil)
        
    }
    
    @objc func updateProfileImage(notification:NSNotification) {
        DispatchQueue.main.async { [weak self] in
            
            guard let self = self else { return }
            
            self.profileImage.image = notification.object as? UIImage
            
        }
    }
    
    @objc private func updateTransactionsData() {
        updateData()
    }
    
    private func updateData() {
        viewModel.reordenateTransactions()
        
        DispatchQueue.main.async {
            self.verticalCollectionView.reloadData()
        }
    }
    
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch collectionView {
        case horizontalCollectionView:
            return 1
        case verticalCollectionView:
            if TransactionsRepository.shared.list.count > 0 {
                return CreditCardsRepository.shared.list.isEmpty ? 3 : 4
            } else {
                return 2
            }
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case horizontalCollectionView:
            return 3
        case verticalCollectionView:
            
            if section <= 1 || (section == 2 && !TransactionsRepository.shared.list.isEmpty) {
                return 1
            } else {
                //last transactions
                let maxVisibleTransactions = 4
                return min(TransactionsRepository.shared.list.count, maxVisibleTransactions)
            }
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == horizontalCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: resumeBalanceCollectionViewCell.identifier, for: indexPath) as? resumeBalanceCollectionViewCell
            cell?.layer.cornerRadius = 10
            cell?.layer.masksToBounds = true
            cell?.setupCell(card: viewModel.getCardInformation(cardNumber: indexPath.row), hideInformations: self.hideInformations)
            return cell ?? UICollectionViewCell()
        } else {
            
            let adjustedSection = !CreditCardsRepository.shared.list.isEmpty ? indexPath.section : (indexPath.section >= 1 ? indexPath.section + 1 : indexPath.section)
            
            switch adjustedSection {
            case 0:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AccountsBallanceCollectionViewCell.identifier, for: indexPath) as? AccountsBallanceCollectionViewCell
                cell?.setupCell(accountsList: BankAccountsRepository.shared.list, hideInformations: self.hideInformations)
                cell?.layer.cornerRadius = 10
                cell?.layer.masksToBounds = true
                return cell ?? UICollectionViewCell()
            case 1:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardsBallanceCollectionViewCell.identifier, for: indexPath) as? CardsBallanceCollectionViewCell
                cell?.setupCell(cardsList: CreditCardsRepository.shared.list, hideInformations: self.hideInformations)
                cell?.layer.cornerRadius = 10
                cell?.layer.masksToBounds = true
                return cell ?? UICollectionViewCell()
            case 2:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoriesGraphCollectionViewCell.identifier, for: indexPath) as? CategoriesGraphCollectionViewCell
                cell?.updateChartData()
                cell?.layer.cornerRadius = 10
                cell?.layer.masksToBounds = true
                return cell ?? UICollectionViewCell()
            case 3:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TransactionsCollectionViewCell.identifier, for: indexPath) as! TransactionsCollectionViewCell
                cell.layer.cornerRadius = 10
                cell.layer.masksToBounds = true
                cell.setup(with: TransactionsRepository.shared.list[indexPath.row])
                return cell
            default:
                return UICollectionViewCell()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == horizontalCollectionView{
            return CGSize(width: 250, height: 150)
        } else {
            
            let adjustedSection = !CreditCardsRepository.shared.list.isEmpty ? indexPath.section : (indexPath.section >= 1 ? indexPath.section + 1 : indexPath.section)
            
            switch adjustedSection {
            case 0:
                var height: Int
                if BankAccountsRepository.shared.list.isEmpty {
                    height = 110
                } else {
                    height = (60 + BankAccountsRepository.shared.list.count * 60)
                }
                return CGSize(width: Int(view.frame.width) - 30, height: height)
            case 1:
                var height = (60 + CreditCardsRepository.shared.list.count * 60)
                return CGSize(width: Int(view.frame.width) - 30, height: height)
            case 2:
                return CGSize(width: Int(view.frame.width) - 30, height: 200)
            case 3:
                return CGSize(width: Int(view.frame.width) - 30, height: 85)
            default:
                return CGSize(width: view.frame.width - 30, height: 50)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var title:String
        
        if collectionView == verticalCollectionView {
            if kind == UICollectionView.elementKindSectionHeader {
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TitleHeaderCollectionReusableView.identifier, for: indexPath) as? TitleHeaderCollectionReusableView
                
                let adjustedSection = !CreditCardsRepository.shared.list.isEmpty ? indexPath.section : (indexPath.section >= 1 ? indexPath.section + 1 : indexPath.section)
                
                switch adjustedSection {
                case 0:
                    title = homeStrings.bankAccountsText
                case 1:
                    title = homeStrings.creditCardsText
                case 2:
                    title = homeStrings.expensesPerCategoryText
                case 3:
                    title = homeStrings.lastTransactionsText
                default:
                    title = globalStrings.emptyString
                }
                headerView?.setupCell(title: title)
                return headerView ?? UICollectionReusableView()
            }
        }
        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if collectionView == verticalCollectionView {
            return CGSize(width: collectionView.frame.width, height: 50)
        }
        return CGSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        
        if indexPath.section == 2 {
            let vc: CategoriesGraphViewController? = UIStoryboard(name: CategoriesGraphViewController.identifier, bundle: nil).instantiateViewController(withIdentifier: CategoriesGraphViewController.identifier) as? CategoriesGraphViewController
            navigationController?.pushViewController(vc ?? UIViewController(), animated: true)
        }
    }
    
}
