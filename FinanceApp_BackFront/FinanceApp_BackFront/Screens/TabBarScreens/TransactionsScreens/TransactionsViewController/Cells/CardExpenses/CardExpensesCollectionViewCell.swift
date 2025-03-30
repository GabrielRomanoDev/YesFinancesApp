//
//  CardExpensesCollectionViewCell.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 05/04/23.
//

import UIKit

class CardExpensesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBOutlet weak var categoryImage: UIImageView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var categoryPanelView: UIView!
    
    static let identifier:String = String(describing: CardExpensesCollectionViewCell.self)
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    
    func setup(with transaction: CreditCardExpense) {
        
        descLabel.text = "Paga: \(transaction.desc)"
        descLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        descLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        valueLabel.text = abs(transaction.amount).toStringMoney()
        valueLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        valueLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        valueLabel.text = transaction.amount.toStringMoney()
        dateLabel.text = transaction.date
        
        switch transaction.type {
        case .expense:
            categoryLabel.text = CategoriesRepository.shared.expenses[transaction.categoryIndex].name
            categoryImage.image = UIImage(imageLiteralResourceName: CategoriesRepository.shared.expenses[transaction.categoryIndex].imageName).withRenderingMode(.alwaysTemplate)
            categoryPanelView.backgroundColor = categoryColors[CategoriesRepository.shared.expenses[transaction.categoryIndex].colorIndex] ?? UIColor.cyan
            valueLabel.textColor = .RedGeneralExpenses
        case .income:
            categoryLabel.text = CategoriesRepository.shared.incomes[transaction.categoryIndex].name
            categoryImage.image = UIImage(imageLiteralResourceName: CategoriesRepository.shared.incomes[transaction.categoryIndex].imageName).withRenderingMode(.alwaysTemplate)
            categoryPanelView.backgroundColor = categoryColors[CategoriesRepository.shared.incomes[transaction.categoryIndex].colorIndex] ?? UIColor.cyan
            valueLabel.textColor = .GreenGeneralIncomes
        }
        
        categoryImage.tintColor = .black
    }
}
