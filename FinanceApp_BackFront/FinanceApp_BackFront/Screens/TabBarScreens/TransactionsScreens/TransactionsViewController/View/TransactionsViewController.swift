//
//  Registros.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 29/03/23.
//

import UIKit

class TransactionsViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var transactionsFilterButton: UIButton!
    @IBOutlet weak var transactionsCollectionView: UICollectionView!
    @IBOutlet weak var noTransactionsLabel: UILabel!
    
    static let identifier:String = String(describing: TransactionsViewController.self)
    private var viewModel: TransactionsViewModel = TransactionsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStrings()
        setupSearchBar()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        showNoTransactionsMessage(title: transactionsStrings.noTransactionsRegistered)
        viewModel.checkInvoices()
        viewModel.reordenateTransactions()
        setupCollectionView()
        transactionsCollectionView.reloadData()
    }
    
    @IBAction func tappedTransactionsFilterButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: FilteringTransactionsViewController.identifier, bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: FilteringTransactionsViewController.identifier) { [weak self] coder -> FilteringTransactionsViewController? in
            guard let self else { return nil }
            return FilteringTransactionsViewController(coder: coder, parameters: self.viewModel.filteringWorker.parameters)
        }
        vc.delegate = self
        present(vc, animated: true)
        
    }
    
    private func setupStrings() {
        navigationItem.backButtonTitle = globalStrings.backButtonTitle
        titleLabel.text = transactionsStrings.title
        noTransactionsLabel.text = transactionsStrings.noTransactionsRegistered
    }
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
    }
    
    private func showNoTransactionsMessage(title: String) {
        if viewModel.getTransactionsCount() <= 0 {
            noTransactionsLabel.isHidden = false
            transactionsCollectionView.isHidden = true
            searchBar.isHidden = true
            transactionsFilterButton.isHidden = true
        } else {
            noTransactionsLabel.isHidden = true
            transactionsCollectionView.isHidden = false
            searchBar.isHidden = false
            transactionsFilterButton.isHidden = false
        }
        noTransactionsLabel.text = title
    }
    
    private func setupCollectionView() {
        transactionsCollectionView.delegate = self
        transactionsCollectionView.dataSource = self

        if let layout = transactionsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.estimatedItemSize = .zero
            layout.sectionInset = UIEdgeInsets(top: 15, left: 15, bottom: 0, right: 15)
        }
        transactionsCollectionView.register(TransactionsCollectionViewCell.nib(), forCellWithReuseIdentifier: TransactionsCollectionViewCell.identifier)
        transactionsCollectionView.register(CardExpensesCollectionViewCell.nib(), forCellWithReuseIdentifier: CardExpensesCollectionViewCell.identifier)
        transactionsCollectionView.register(PendingInvoicesCollectionViewCell.nib(), forCellWithReuseIdentifier: PendingInvoicesCollectionViewCell.identifier)
        
    }

}

extension TransactionsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getTransactionsCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row < viewModel.pendingInvoices.count {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PendingInvoicesCollectionViewCell.identifier, for: indexPath) as! PendingInvoicesCollectionViewCell
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true
            
            cell.setup(with: viewModel.pendingInvoices[indexPath.row])
            return cell
        } else {
            
            let transactionsIndex = indexPath.row - viewModel.pendingInvoices.count
            
            if let accountTransaction = viewModel.getItemTransactions(transactionsIndex) as? AccountTransaction {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TransactionsCollectionViewCell.identifier, for: indexPath) as! TransactionsCollectionViewCell
                cell.layer.cornerRadius = 10
                cell.layer.masksToBounds = true
                
                cell.setup(with: accountTransaction)
                return cell
            }
            
            if let creditCardTransaction = viewModel.getItemTransactions(transactionsIndex) as? CreditCardExpense {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardExpensesCollectionViewCell.identifier, for: indexPath) as! CardExpensesCollectionViewCell
                cell.layer.cornerRadius = 10
                cell.layer.masksToBounds = true
                
                cell.setup(with: creditCardTransaction)
                return cell
            }
        }
        
        return UICollectionViewCell()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.row < viewModel.pendingInvoices.count {
            return CGSize(width: view.frame.width - 30, height: 100)
        } else {
            return CGSize(width: view.frame.width - 30, height: 85)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
}

extension TransactionsViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        viewModel.searchForTransactions(searchBar.text)
        transactionsCollectionView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchForTransactions(searchBar.text)
        transactionsCollectionView.reloadData()
    }
    
}

extension TransactionsViewController: FilterTransactionsDelegate {
    func didFilter(parameters: FilteringParameters?) {
        
        guard let parameters = parameters else { return }
        
        viewModel.filterTransactions(parameters: parameters, textSearch: searchBar.text)
        showNoTransactionsMessage(title: transactionsStrings.noTransactionsFiltered)
        transactionsCollectionView.reloadData()
    }
    
}
