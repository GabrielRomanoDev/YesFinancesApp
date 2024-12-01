//
//  SelectItensTableViewCell.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 01/12/24.
//

import UIKit

class SelectItensTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var delegate: FilteringTransacitonsCollectionViewCellProtocol?
    var screenWidth: CGFloat?
    var accounts: [BankAccount]? = nil
    var cards: [CreditCard]? = nil
    var categories: [TransactionCategory]? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupCell(accounts: [BankAccount]) {
        self.titleLabel.text = FilteringTransactionsStrings.accounts
        self.accounts = accounts
        
        setupCollectionView()
    }
    
    func setupCell(creditCards: [CreditCard]) {
        self.titleLabel.text = FilteringTransactionsStrings.creditCards
        self.cards = creditCards
        
        setupCollectionView()
    }
    
    func setupCell(categories: [TransactionCategory]) {
        self.titleLabel.text = FilteringTransactionsStrings.categories
        self.categories = categories
        
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.estimatedItemSize = .zero
            layout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: 0, right: 15)
        }
        collectionView.register(FilteringTransacitonsCollectionViewCell.nib(), forCellWithReuseIdentifier: FilteringTransacitonsCollectionViewCell.identifier)
        
        //updateCollectionViewContent()
        
    }
    
    private func removeCollectionViewItem(index: Int?, item: Any?) {
        
        if let position = index {
            self.accounts?.remove(at: position)
            self.cards?.remove(at: position)
            self.categories?.remove(at: position)
        }
        
        delegate?.didRemoveItem(index: index, item: item)
        collectionView.reloadData()
        
    }
    
}

extension SelectItensTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let accounts = self.accounts {
            return (accounts.count > 0) ? accounts.count : 1
        }
        
        if let cards = self.cards {
            return (cards.count > 0) ? cards.count : 1
        }
        
        if let categories = self.categories {
            return (categories.count > 0) ? categories.count : 1
        }
        
        return 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilteringTransacitonsCollectionViewCell.identifier, for: indexPath) as! FilteringTransacitonsCollectionViewCell
        
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.delegate = self
        cell.index = indexPath.row
        
        if let accounts = self.accounts {
            if accounts.count > 0 {
                cell.setupCell(bankAccount: accounts[indexPath.row])
            } else {
                cell.setupCell(bankAccount: nil)
            }
        }
        
        if let cards = self.cards {
            if cards.count > 0 {
                cell.setupCell(creditCard: cards[indexPath.row])
            } else {
                cell.setupCell(creditCard: nil)
            }
        }
        
        if let categories = self.categories {
            if categories.count > 0 {
                cell.setupCell(category: categories[indexPath.row])
            } else {
                cell.setupCell(category: nil)
            }
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (screenWidth ?? 300) - 30, height: 35)
    }
    
}

extension SelectItensTableViewCell: FilteringTransacitonsCollectionViewCellProtocol {
    
    func didRemoveItem(index: Int?, item: Any?) {
        removeCollectionViewItem(index: index, item: item)
    }
    
}
