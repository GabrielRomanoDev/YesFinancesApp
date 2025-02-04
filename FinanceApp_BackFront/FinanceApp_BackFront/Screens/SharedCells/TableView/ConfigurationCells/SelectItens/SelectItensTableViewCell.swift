//
//  SelectItensTableViewCell.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 01/12/24.
//

import UIKit

protocol SelectItensTableViewCellDelegate: AnyObject {
    func didSelectCell(type: ModalSelectionItemOptions)
    func didRemoveItem(index: Int?, item: Any?)
}

class SelectItensTableViewCell: UITableViewCell {
    
    static let identifier:String = String(describing: SelectItensTableViewCell.self)
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var delegate: SelectItensTableViewCellDelegate?
    var screenWidth: CGFloat?
    var itemType: ModalSelectionItemOptions = .other
    var accounts: [BankAccount] = []
    var cards: [CreditCard] = []
    var categories: [TransactionCategory] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        accounts = []
        cards = []
        categories = []
        itemType = .other
    }
    
    func setupCell(accounts: [BankAccount]?) {
        self.titleLabel.text = FilteringTransactionsStrings.accounts
    
        self.itemType = .accounts
        self.accounts = accounts ?? []
        
        setupCollectionView()
        collectionView.reloadData()
    }
    
    func setupCell(creditCards: [CreditCard]?) {
       
        self.titleLabel.text = FilteringTransactionsStrings.creditCards
        
        self.itemType = .creditCards
        self.cards = creditCards ?? []
        
        setupCollectionView()
        collectionView.reloadData()
    }
    
    func setupCell(categories: [TransactionCategory]?) {
        
        self.titleLabel.text = FilteringTransactionsStrings.categories

        self.itemType = .categories
        self.categories = categories ?? []
        
        setupCollectionView()
        collectionView.reloadData()
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
        
    }
    
    private func removeCollectionViewItem(index: Int?, item: Any?) {
        
        if let position = index {
            switch itemType {
            case .accounts:
                self.accounts.remove(at: position)
            case .creditCards:
                self.cards.remove(at: position)
            case .categories:
                self.categories.remove(at: position)
            case .other:
                break
            }

        }
        
        delegate?.didRemoveItem(index: index, item: item)
        
    }
    
}

extension SelectItensTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch itemType {
        case .accounts:
            return (accounts.count > 0) ? accounts.count : 1
        case .creditCards:
            return (cards.count > 0) ? cards.count : 1
        case .categories:
            return (categories.count > 0) ? categories.count : 1
        case .other:
            return 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilteringTransacitonsCollectionViewCell.identifier, for: indexPath) as! FilteringTransacitonsCollectionViewCell
        
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.delegate = self
        cell.index = indexPath.row
        
        switch itemType {
        case .accounts:
            
                if accounts.count > 0 {
                    cell.setupCell(bankAccount: accounts[indexPath.row])
                } else {
                    cell.setupCell(bankAccount: nil)
                }

        case .creditCards:
            
                if cards.count > 0 {
                    cell.setupCell(creditCard: cards[indexPath.row])
                } else {
                    cell.setupCell(creditCard: nil)
                }
            
        case .categories:
            
                if categories.count > 0 {
                    cell.setupCell(category: categories[indexPath.row])
                } else {
                    cell.setupCell(category: nil)
                }
            
        case .other:
            return cell
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (screenWidth ?? 300) - 30, height: 35)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectCell(type: itemType)
    }
    
}

extension SelectItensTableViewCell: FilteringTransactionsCollectionViewCellProtocol {
    
    func didRemoveItem(index: Int?, item: Any?) {
        removeCollectionViewItem(index: index, item: item)
    }
    
}

