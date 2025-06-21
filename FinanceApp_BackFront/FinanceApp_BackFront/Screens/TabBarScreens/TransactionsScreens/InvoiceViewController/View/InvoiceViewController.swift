//
//  Registros.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 29/03/23.
//

import UIKit
import SwiftUI

class InvoiceViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var transactionsFilterButton: UIButton!
    @IBOutlet weak var transactionsCollectionView: UICollectionView!
    @IBOutlet weak var noTransactionsLabel: UILabel!
    
    static let identifier:String = String(describing: InvoiceViewController.self)
    private var viewModel: InvoiceViewModel
    private var searchBarText: String = ""
    
    init?(coder: NSCoder, invoice: Invoice) {
        self.viewModel = InvoiceViewModel(invoice: invoice)
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError(globalStrings.initError)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStrings()
        setupCollectionView()
        setupKeyboardHinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
        viewModel.fetchExpenses()
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
            return FilteringTransactionsViewController(coder: coder, parameters: self.viewModel.getParameters(), type: .invoice)
        }
        vc.delegate = self
        present(vc, animated: true)
        
    }
    
    private func setupStrings() {
        navigationItem.backButtonTitle = globalStrings.backButtonTitle
        titleLabel.text = viewModel.invoice.desc
        noTransactionsLabel.text = transactionsStrings.noTransactionsRegistered
        monthLabel.text = viewModel.getMonthName()
    }
    
    private func showNoTransactionsMessage(title: String) {
        if viewModel.getTransactionsCount() <= 0 {
            noTransactionsLabel.isHidden = false
            noTransactionsLabel.text = title
        } else {
            noTransactionsLabel.isHidden = true
        }
    }
    
    private func setupCollectionView() {
        
        transactionsCollectionView.delegate = self
        transactionsCollectionView.dataSource = self

        if let layout = transactionsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.estimatedItemSize = .zero
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
        }
        transactionsCollectionView.register(InvoiceInfoCollectionViewCell.nib(), forCellWithReuseIdentifier: InvoiceInfoCollectionViewCell.identifier)
        transactionsCollectionView.register(CardExpensesCollectionViewCell.nib(), forCellWithReuseIdentifier: CardExpensesCollectionViewCell.identifier)
        
    }
    
    private func updateData() {
        
        DispatchQueue.main.async { [weak self] in
            
            guard let self else { return }
            
            self.viewModel.filterTransactions(parameters: nil)
            self.transactionsCollectionView.reloadData()
            self.transactionsCollectionView.reloadItems(at: [IndexPath(row: 0, section: 0)])
            let context = transactionsCollectionView.collectionViewLayout.invalidationContext(forBoundsChange: transactionsCollectionView.bounds)
            context.contentOffsetAdjustment = CGPoint.zero
            transactionsCollectionView.collectionViewLayout.invalidateLayout(with: context)
            transactionsCollectionView.layoutSubviews()
            self.transactionsCollectionView.collectionViewLayout.invalidateLayout()
            self.transactionsCollectionView.layoutSubviews()
            self.showNoTransactionsMessage(title: transactionsStrings.noExpenseFiltered)
            
        }
        
    }

}

extension InvoiceViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getTransactionsCount() + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InvoiceInfoCollectionViewCell.identifier, for: indexPath) as! InvoiceInfoCollectionViewCell
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true
            cell.searchBar.delegate = self
            cell.delegate = self
            cell.setupCell(invoice: viewModel.invoice)
            return cell
            } else if let creditCardTransaction = viewModel.getExpense(indexPath.row - 1) as? CreditCardExpense {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardExpensesCollectionViewCell.identifier, for: indexPath) as! CardExpensesCollectionViewCell
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true
            
            cell.setup(with: creditCardTransaction)
            return cell
        }
        
        return UICollectionViewCell()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return viewModel.getSizeForCell(index: indexPath.row, viewWidth: view.frame.width)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
}

extension InvoiceViewController: InvoiceInfoCollectionViewCellDelegate {
    
    func didTapPayInvoiceButton() {
        
        let cardPayment = AccountTransaction(
            desc: "Pagamento de \(viewModel.invoice.desc)",
            amount: viewModel.invoice.amount,
            categoryIndex: 30,
            date: Date().toString(),
            type: .expense,
            isMonthly: false,
            sourceId: viewModel.invoice.sourceId,
            obs: globalStrings.emptyString
        )
        
        if abs(viewModel.invoice.amount) > 0 {
            var hostingController: UIHostingController<TransactionFormScreen>!
            
            var isPresented: Bool = true
            let isPresentedBinding = Binding<Bool>(
                get: { isPresented },
                set: { newValue in
                    isPresented = newValue
                }
            )

            let swiftUIView = TransactionFormScreen(transaction: cardPayment, type: .expense, isInvoicePayment: true, isPresented: isPresentedBinding) {
                
                DispatchQueue.main.async {
                    self.viewModel.payInvoice()
                    self.updateData()
                    hostingController.dismiss(animated: true)
                }
                
            }

            hostingController = UIHostingController(rootView: swiftUIView)
            present(hostingController, animated: true)
        } else {
            showSimpleAlert(title: globalStrings.attention, message: transactionsStrings.errorZeroedInvoice)
        }
        
        
    }
    
}

extension InvoiceViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBarText = searchBar.text ?? ""
        viewModel.filterTransactions(textSearch: searchBar.text)
        transactionsCollectionView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchBarText = searchText
        viewModel.filterTransactions(textSearch: searchBar.text)
        transactionsCollectionView.reloadData()
    }
    
}

extension InvoiceViewController: FilterTransactionsDelegate {
    func didFilter(parameters: FilteringParameters?) {
        
        guard let parameters = parameters else { return }
        
        viewModel.filterTransactions(parameters: parameters, textSearch: self.searchBarText)
        showNoTransactionsMessage(title: transactionsStrings.noTransactionsFiltered)
        monthLabel.text = viewModel.getMonthName(dateFilter: parameters.dates)
        transactionsCollectionView.reloadData()
    }
    
}
