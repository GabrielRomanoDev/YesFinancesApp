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
    
    
    func setup(with transaction: Invoice) {
        
        descLabel.text = transaction.desc
        descLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        descLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        valueLabel.text = transaction.amount.toStringMoney()
        valueLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        valueLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        dateLabel.text = transaction.date
        
        if let date = transaction.date.toDate(), date <= Date() {
            categoryLabel.text = transactionsStrings.invoiceWasDueDate
        } else {
            categoryLabel.text = transactionsStrings.dueDate
        }
        
        categoryImage.image = UIImage(imageLiteralResourceName: CategoriesRepository.shared.expense(transaction.categoryIndex).imageName).withRenderingMode(.alwaysTemplate)
        categoryPanelView.backgroundColor = categoryColors[CategoriesRepository.shared.expense(transaction.categoryIndex).colorIndex] ?? UIColor.cyan
        valueLabel.textColor = .redGeneralExpenses
        
        categoryImage.tintColor = .black
        
        statusLabel.layer.cornerRadius = statusLabel.layer.frame.height/2
        statusLabel.clipsToBounds = true
        
        switch transaction.paymentStatus {
        case .open:
            statusLabel.text = " \(transactionsStrings.invoiceTitle) \(transactionsStrings.open) "
        case .future:
            statusLabel.text = " \(transactionsStrings.invoiceTitle) \(transactionsStrings.future) "
        case .paid:
            statusLabel.text = " \(transactionsStrings.invoiceTitle) \(transactionsStrings.paid) "
        case .pendent:
            statusLabel.text = " \(transactionsStrings.invoiceTitle) \(transactionsStrings.pendent) "
        case .overdue:
            statusLabel.text = " \(transactionsStrings.invoiceTitle) \(transactionsStrings.overdue) "
        case .zeroed:
            statusLabel.text = " \(transactionsStrings.invoiceTitle) \(transactionsStrings.zeroed) "
        }
        
    }
}
