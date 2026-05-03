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
        if viewModel.getTransactionsCount() <= 0 && viewModel.getPendingInvoicesCount() <= 0 {
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
            layout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        }
        transactionsCollectionView.register(TitleHeaderCollectionReusableView.nib(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TitleHeaderCollectionReusableView.identifier)
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.getPendingInvoicesCount() > 0 ? 2 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let adjustedSection = viewModel.getPendingInvoicesCount() > 0 ? section : section + 1
        
        switch adjustedSection {
        case 0:
            return viewModel.getPendingInvoicesCount()
        default:
            return viewModel.getTransactionsCount()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let adjustedSection = viewModel.getPendingInvoicesCount() > 0 ? indexPath.section : indexPath.section + 1
        
        switch adjustedSection {
        case 0:
            let invoice = viewModel.getItemInvoices(indexPath.row)
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PendingInvoicesCollectionViewCell.identifier, for: indexPath) as! PendingInvoicesCollectionViewCell
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true
            
            cell.setup(with: invoice)
            return cell
        case 1:
            if let accountTransaction = viewModel.getItemTransactions(indexPath.row) as? AccountTransaction {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TransactionsCollectionViewCell.identifier, for: indexPath) as! TransactionsCollectionViewCell
                cell.layer.cornerRadius = 10
                cell.layer.masksToBounds = true
                
                cell.setup(with: accountTransaction)
                return cell
                
            }
        default:
            break
        }
        
        return UICollectionViewCell()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let adjustedSection = viewModel.getPendingInvoicesCount() > 0 ? indexPath.section : indexPath.section + 1
        
        switch adjustedSection {
        case 0:
            return CGSize(width: view.frame.width - 30, height: 92)
        default:
            return CGSize(width: view.frame.width - 30, height: 79)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 0 && viewModel.getPendingInvoicesCount() > 0 {
            let invoice = viewModel.getItemInvoices(indexPath.row)
            
            let storyboard = UIStoryboard(name: InvoiceViewController.identifier, bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: InvoiceViewController.identifier) { coder -> InvoiceViewController? in
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
                    if case .failure(let error) = result {
                        print("Error to edit transaction: \(error.localizedDescription)")
                    }
                    
                    DispatchQueue.main.async {
                        self?.updateData()
                        isPresented = false
                        hostingController.dismiss(animated: true)
                    }

                }
            }
            
            hostingController = UIHostingController(rootView: swiftUIView)
            
            if let sheet = hostingController.sheetPresentationController {
                sheet.detents = [.medium()] // ou [.medium(), .large()] se quiser permitir expansão
                sheet.prefersGrabberVisible = true
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            }
            
            present(hostingController, animated: true)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var title:String
        
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TitleHeaderCollectionReusableView.identifier, for: indexPath) as? TitleHeaderCollectionReusableView
            
            if indexPath.section == 0 && viewModel.getPendingInvoicesCount() > 0 {
                title = "Faturas Pendentes"
            } else if indexPath.section == 1 && viewModel.getTransactionsCount() > 0 {
                title = "Transações"
            } else {
                title = globalStrings.emptyString
            }
            
            headerView?.setupCell(title: title, color: .systemGray, font: .systemFont(ofSize: 16))
            return headerView ?? UICollectionReusableView()
        }
        
        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if viewModel.getPendingInvoicesCount() > 0 {
            return CGSize(width: collectionView.frame.width, height: 40)
        } else {
            return CGSize(width: 0, height: 0)
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
