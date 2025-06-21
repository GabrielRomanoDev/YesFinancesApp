//
//  Registros.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 29/03/23.
//

import UIKit
import SwiftUI

class TransactionsViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var transactionsFilterButton: UIButton!
    @IBOutlet weak var transactionsCollectionView: UICollectionView!
    @IBOutlet weak var noTransactionsLabel: UILabel!
    
    static let identifier:String = String(describing: TransactionsViewController.self)
    private var viewModel: TransactionsViewModel = TransactionsViewModel()
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .updateTransactionsData, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStrings()
        setupSearchBar()
        setupKeyboardHinding()
        setupCollectionView()
        setupNotificationCenter()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        updateData()
    }
    
    @IBAction func tappedLastMonth(_ sender: UIButton) {
        viewModel.displayLastMonth()
        monthLabel.text = viewModel.getMonthName()
        updateData()
    }
    
    @IBAction func nextMonth(_ sender: UIButton) {
        viewModel.displayNextMonth()
        monthLabel.text = viewModel.getMonthName()
        updateData()
    }
    
    
    @IBAction func tappedTransactionsFilterButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: FilteringTransactionsViewController.identifier, bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: FilteringTransactionsViewController.identifier) { [weak self] coder -> FilteringTransactionsViewController? in
            guard let self else { return nil }
            return FilteringTransactionsViewController(coder: coder, parameters: self.viewModel.getParameters(), type: .transactions)
        }
        vc.delegate = self
        present(vc, animated: true)
        
    }
    
    private func setupStrings() {
        navigationItem.backButtonTitle = globalStrings.backButtonTitle
        titleLabel.text = transactionsStrings.transactionsTitle
        noTransactionsLabel.text = transactionsStrings.noTransactionsRegistered
        monthLabel.text = viewModel.getMonthName()
    }
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
    }
    
    private func setupNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateTransactionsData), name: .updateTransactionsData, object: nil)
    }
    
    @objc private func updateTransactionsData() {
        updateData()
    }
    
    private func showNoTransactionsMessage(title: String) {
        if viewModel.getTransactionsCount() <= 0 {
            noTransactionsLabel.isHidden = false
            transactionsCollectionView.isHidden = true
        } else {
            noTransactionsLabel.isHidden = true
            transactionsCollectionView.isHidden = false
        }
        noTransactionsLabel.text = title
    }
    
    private func setupCollectionView() {
        transactionsCollectionView.delegate = self
        transactionsCollectionView.dataSource = self

        if let layout = transactionsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.estimatedItemSize = .zero
            layout.sectionInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        }
        transactionsCollectionView.register(TransactionsCollectionViewCell.nib(), forCellWithReuseIdentifier: TransactionsCollectionViewCell.identifier)
        transactionsCollectionView.register(CardExpensesCollectionViewCell.nib(), forCellWithReuseIdentifier: CardExpensesCollectionViewCell.identifier)
        transactionsCollectionView.register(PendingInvoicesCollectionViewCell.nib(), forCellWithReuseIdentifier: PendingInvoicesCollectionViewCell.identifier)
        
    }
    
    private func updateData() {
        viewModel.checkInvoices()
        viewModel.filterTransactions(parameters: nil)
        transactionsCollectionView.reloadData()
        showNoTransactionsMessage(title: transactionsStrings.noTransactionsRegistered)
    }
    
    private func openEditTransactionScreen(transaction: AccountTransaction, index: Int) {
        
        var hostingController: UIHostingController<TransactionFormScreen>!
        
        var isPresented: Bool = true
        let isPresentedBinding = Binding<Bool>(
            get: { isPresented },
            set: { newValue in
                isPresented = newValue
            }
        )
        
        let swiftUIView = TransactionFormScreen(transaction: transaction, type: .income, isPresented: isPresentedBinding) {
            
            DispatchQueue.main.async { [weak self] in
               
                self?.updateData()
                isPresented = false
                
                hostingController.dismiss(animated: true)
                
            }
            
        }
        
        hostingController = UIHostingController(rootView: swiftUIView)
        
        present(hostingController, animated: true)
        
    }

}

extension TransactionsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getTransactionsCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let invoice = viewModel.getItemTransactions(indexPath.row) as? Invoice {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PendingInvoicesCollectionViewCell.identifier, for: indexPath) as! PendingInvoicesCollectionViewCell
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true
            
            cell.setup(with: invoice)
            return cell
            
        } else if let accountTransaction = viewModel.getItemTransactions(indexPath.row) as? AccountTransaction {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TransactionsCollectionViewCell.identifier, for: indexPath) as! TransactionsCollectionViewCell
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true
            
            cell.setup(with: accountTransaction)
            return cell
            
        }
        
        return UICollectionViewCell()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let _ = viewModel.getItemTransactions(indexPath.row) as? Invoice {
            return CGSize(width: view.frame.width - 30, height: 92)
        } else {
            return CGSize(width: view.frame.width - 30, height: 79)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let invoice = viewModel.getItemTransactions(indexPath.row) as? Invoice {
            
            let storyboard = UIStoryboard(name: InvoiceViewController.identifier, bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: InvoiceViewController.identifier) { [weak self] coder -> InvoiceViewController? in
                return InvoiceViewController(coder: coder, invoice: invoice)
            }
            navigationController?.pushViewController(vc, animated: true)
            
        } else if let accountTransaction = viewModel.getItemTransactions(indexPath.row) as? AccountTransaction {
            
            var hostingController: UIHostingController<DetailsTransactionView>!
            
            @State var isPresented: Bool = true
            
            let swiftUIView = DetailsTransactionView(transaction: accountTransaction, isPresented: isPresented) { [weak self] in
                // onEdit
                isPresented = false
                hostingController.dismiss(animated: true) { [weak self] in
                    self?.openEditTransactionScreen(transaction: accountTransaction, index: indexPath.row)
                }
                
            } onDelete: { [weak self] in
                // onDelete
                self?.viewModel.deleteTransaction(indexPath.row) { result in
                    if result != "Success" {
                        print("Error to edit transaction: \(result)")
                    }
                }
                self?.updateData()
                isPresented = false
                hostingController.dismiss(animated: true)
            }
            
            hostingController = UIHostingController(rootView: swiftUIView)
            
            if let sheet = hostingController.sheetPresentationController {
                sheet.detents = [.medium()] // ou [.medium(), .large()] se quiser permitir expansão
                sheet.prefersGrabberVisible = true // opcional: mostra a alça de arrastar
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            }
            
            present(hostingController, animated: true)
            
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
}

extension TransactionsViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        viewModel.filterTransactions(textSearch: searchBar.text)
        transactionsCollectionView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filterTransactions(textSearch: searchBar.text)
        transactionsCollectionView.reloadData()
    }
    
}

extension TransactionsViewController: FilterTransactionsDelegate {
    func didFilter(parameters: FilteringParameters?) {
        
        guard let parameters = parameters else { return }
        
        viewModel.filterTransactions(parameters: parameters, textSearch: searchBar.text)
        showNoTransactionsMessage(title: transactionsStrings.noTransactionsFiltered)
        monthLabel.text = viewModel.getMonthName(dateFilter: parameters.dates)
        transactionsCollectionView.reloadData()
    }
    
}
