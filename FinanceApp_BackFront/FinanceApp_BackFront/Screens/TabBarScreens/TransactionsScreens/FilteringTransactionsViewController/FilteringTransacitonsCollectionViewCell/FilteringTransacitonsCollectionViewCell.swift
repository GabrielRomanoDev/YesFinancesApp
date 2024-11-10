//
//  FilteringTransacitonsCollectionViewCell.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 09/10/24.
//

import UIKit

protocol FilteringTransacitonsCollectionViewCellProtocol: AnyObject {
    func didRemoveItem(index: Int?, item: Any?)
}

class FilteringTransacitonsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var boxView: UIView!
    
    static let identifier:String = String(describing: FilteringTransacitonsCollectionViewCell.self)
    weak var delegate: FilteringTransacitonsCollectionViewCellProtocol?
    var index: Int?
    var item: Any?
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    @IBAction func tappedDeleteButton(_ sender: UIButton) {
        delegate?.didRemoveItem(index: index, item: self.item)
    }
    
    func setupCell(item: Any?) {
        
        self.item = item
        
        if let account = item as? BankAccount {
            descLabel.text = account.desc
            self.layer.borderWidth = 1
            self.layer.borderColor = UIColor.systemGray5.cgColor
            self.deleteButton.isHidden = false
        } else if let creditCard = item as? CreditCard {
            descLabel.text = creditCard.desc
            self.layer.borderWidth = 1
            self.layer.borderColor = UIColor.systemGray5.cgColor
            self.deleteButton.isHidden = false
        } else if let category = item as? TransactionCategory {
            descLabel.text = category.name
            self.layer.borderWidth = 1
            self.layer.borderColor = UIColor.systemGray5.cgColor
            self.deleteButton.isHidden = false
        } //else {
//            descLabel.text = "Todas as Contas"
//            self.layer.borderWidth = 1
//            self.layer.borderColor = UIColor.white.cgColor
//            self.deleteButton.isHidden = true
//        }
        
        imageView.image = UIImage(systemName: "ball")
    }
    
}
