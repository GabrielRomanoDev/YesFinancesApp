//
//  Registros.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 29/03/23.
//

import UIKit

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
            transactionsCollectionView.isHidden = true
            transactionsFilterButton.isHidden = true
            noTransactionsLabel.text = title
        } else {
            noTransactionsLabel.isHidden = true
            transactionsCollectionView.isHidden = false
            transactionsFilterButton.isHidden = false
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
        transactionsCollectionView.register(InvoceInfoCollectionViewCell.nib(), forCellWithReuseIdentifier: InvoceInfoCollectionViewCell.identifier)
        transactionsCollectionView.register(CardExpensesCollectionViewCell.nib(), forCellWithReuseIdentifier: CardExpensesCollectionViewCell.identifier)
        
    }
    
    private func updateData() {
        viewModel.filterTransactions(parameters: nil)
        transactionsCollectionView.reloadData()
        showNoTransactionsMessage(title: transactionsStrings.noExpenseFiltered)
    }

}

extension InvoiceViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getTransactionsCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: InvoceInfoCollectionViewCell.identifier, for: indexPath) as! InvoceInfoCollectionViewCell
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true
            cell.searchBar.delegate = self
            cell.searchBar.searchBarStyle = .minimal
            cell.setupCell(invoice: viewModel.invoice)
            return cell
            } else if let creditCardTransaction = viewModel.getItemTransactions(indexPath.row) as? CreditCardExpense {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CardExpensesCollectionViewCell.identifier, for: indexPath) as! CardExpensesCollectionViewCell
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true
            
            cell.setup(with: creditCardTransaction)
            return cell
        }
        
        return UICollectionViewCell()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.row == 0 {
            return viewModel.invoice.paymentStatus != .paid ? CGSize(width: view.frame.width, height: 176) : CGSize(width: view.frame.width, height: 130)
        } else {
            return CGSize(width: view.frame.width - 30, height: 85)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
}

extension InvoiceViewController: InvoceInfoCollectionViewCellDelegate {
    
    func didTapPayInvoiceButton() {
        viewModel.payInvoice()
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
