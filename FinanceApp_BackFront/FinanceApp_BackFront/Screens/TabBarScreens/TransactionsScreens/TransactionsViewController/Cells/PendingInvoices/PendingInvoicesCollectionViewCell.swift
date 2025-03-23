//
//  CardExpensesCollectionViewCell.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 05/04/23.
//

import UIKit

class PendingInvoicesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var categoryPanelView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    
    static let identifier:String = String(describing: PendingInvoicesCollectionViewCell.self)
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    
    func setup(with transaction: CreditCardExpense) {
        
        descLabel.text = transaction.desc
        descLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        descLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        valueLabel.text = transaction.amount.toStringMoney()
        valueLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)  // O label 2 se adapta ao texto
        valueLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        
        dateLabel.text = transaction.date
        
        categoryLabel.text = "Vencimento em:"
        categoryImage.image = UIImage(imageLiteralResourceName: CategoriesRepository.shared.expenses[transaction.categoryIndex].imageName).withRenderingMode(.alwaysTemplate)
        categoryPanelView.backgroundColor = categoryColors[CategoriesRepository.shared.expenses[transaction.categoryIndex].colorIndex] ?? UIColor.cyan
        valueLabel.textColor = .RedGeneralExpenses
        
        categoryImage.tintColor = .black
        
        statusLabel.layer.cornerRadius = statusLabel.layer.frame.height/2
        statusLabel.clipsToBounds = true
        
        switch transaction.paymentStatus {
        case .future:
            statusLabel.text = " Pagamento futuro "
        case .paid:
            statusLabel.text = "Fatura paga"
        case .pendent:
            statusLabel.text = "Pagamento pendente"
        case .overdue:
            statusLabel.text = "Fatura atrasada"
        }
        
    }
}
