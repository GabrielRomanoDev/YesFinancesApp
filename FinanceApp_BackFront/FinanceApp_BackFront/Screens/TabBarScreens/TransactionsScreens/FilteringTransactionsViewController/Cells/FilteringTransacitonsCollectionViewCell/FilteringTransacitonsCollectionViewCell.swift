//
//  FilteringTransacitonsCollectionViewCell.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 09/10/24.
//

import UIKit

protocol FilteringTransactionsCollectionViewCellProtocol: AnyObject {
    func didRemoveItem(index: Int?, item: Any?)
}

class FilteringTransacitonsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var boxView: UIView!
    
    static let identifier:String = String(describing: FilteringTransacitonsCollectionViewCell.self)
    weak var delegate: FilteringTransactionsCollectionViewCellProtocol?
    var index: Int?
    var item: Any?
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupElements()
    }
    
    override func prepareForReuse() {
        setupElements()
        descLabel.text = ""
        item = nil
        imageView.image = nil
    }
    
    @IBAction func tappedDeleteButton(_ sender: UIButton) {
        delegate?.didRemoveItem(index: index, item: self.item)
    }
    
    func setupCell(bankAccount: BankAccount?) {
        
        self.item = bankAccount
        
        if let account = bankAccount {
            descLabel.text = account.desc
            descLabel.textAlignment = .left
        } else {
            allSelected(FilteringTransactionsStrings.allAccounts)
        }
        
    }
    
    func setupCell(creditCard: CreditCard?) {
        
        self.item = creditCard
        
        if let card = creditCard {
            descLabel.text = card.desc
            descLabel.textAlignment = .left
        } else {
            allSelected(FilteringTransactionsStrings.allCards)
        }

    }
    
    func setupCell(category: TransactionCategory?) {
        
        self.item = category
        
        if let category {
            
            descLabel.text = category.name
            descLabel.textAlignment = .left
            
            self.imageView.image = UIImage(imageLiteralResourceName: category.imageName).withRenderingMode(.alwaysTemplate)
            self.imageView.tintColor = categoryColors[category.colorIndex]
            self.layer.borderColor = categoryColors[category.colorIndex]?.cgColor
            
        } else {
            allSelected(FilteringTransactionsStrings.allCategories)
        }
        
    }
    
    private func setupElements() {
        deleteButton.isHidden = false
        imageView.isHidden = false
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.systemGray5.cgColor
    }
    
    private func allSelected(_ text: String) {
        
        descLabel.text = text
        descLabel.textAlignment = .center
        deleteButton.isHidden = true
        self.layer.borderColor = UIColor.white.cgColor
        
    }
    
}
