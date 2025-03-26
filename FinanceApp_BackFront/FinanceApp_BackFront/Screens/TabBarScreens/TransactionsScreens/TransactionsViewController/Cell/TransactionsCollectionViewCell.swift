//
//  TransactionsCollectionViewCell.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 05/04/23.
//

import UIKit

class TransactionsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBOutlet weak var categoryImage: UIImageView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var categoryPanelView: UIView!
    
    static let identifier:String = String(describing: TransactionsCollectionViewCell.self)
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    
    func setup(with transactions: any Transactions) {
        
        descLabel.text = transactions.desc
        descLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        descLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        valueLabel.text = transactions.amount.toStringMoney()
        valueLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        valueLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        dateLabel.text = transactions.date
        
        switch transactions.type {
        case .expense:
            categoryLabel.text = CategoriesRepository.shared.expenses[transactions.categoryIndex].name
            categoryImage.image = UIImage(imageLiteralResourceName: CategoriesRepository.shared.expenses[transactions.categoryIndex].imageName).withRenderingMode(.alwaysTemplate)
            categoryPanelView.backgroundColor = categoryColors[CategoriesRepository.shared.expenses[transactions.categoryIndex].colorIndex] ?? UIColor.cyan
            valueLabel.textColor = .RedGeneralExpenses
        case .income:
            categoryLabel.text = CategoriesRepository.shared.incomes[transactions.categoryIndex].name
            categoryImage.image = UIImage(imageLiteralResourceName: CategoriesRepository.shared.incomes[transactions.categoryIndex].imageName).withRenderingMode(.alwaysTemplate)
            categoryPanelView.backgroundColor = categoryColors[CategoriesRepository.shared.incomes[transactions.categoryIndex].colorIndex] ?? UIColor.cyan
            valueLabel.textColor = .GreenGeneralIncomes
        }
        
        categoryImage.tintColor = .black
    }
}
