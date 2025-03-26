//
//  InvoceInformationsCollectionViewCell.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 24/03/25.
//

import UIKit

protocol InvoceInfoCollectionViewCellDelegate: AnyObject {
    func didTapPayInvoiceButton()
}

class InvoceInfoCollectionViewCell: UICollectionViewCell {
    
    static let identifier:String = String(describing: InvoceInfoCollectionViewCell.self)
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    weak var delegate: ButtonTableViewCellDelegate?
    
    @IBOutlet weak var invoiceTotalLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var closingDateLabel: UILabel!
    
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var payInvoiceButton: UIButton!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    @IBAction func tappedPayInvoiceButton(_ sender: UIButton) {
        delegate?.didTappedButton()
    }
    
    func setupCell(invoice: Invoice) {
        
        invoiceTotalLabel.text = transactionsStrings.invoiceTotal + ": " + "\(invoice.amount.toStringMoney())"
        
        switch invoice.paymentStatus {
        case .future:
            statusLabel.text = transactionsStrings.status + ": " + transactionsStrings.future
            payInvoiceButton.setTitle(transactionsStrings.advanceInvoicePayment, for: .normal)
        case .paid:
            statusLabel.text = transactionsStrings.status + ": " + transactionsStrings.paid
            payInvoiceButton.isHidden = true
        case .overdue:
            statusLabel.text = transactionsStrings.status + ": " + transactionsStrings.overdue
            payInvoiceButton.setTitle(transactionsStrings.payInvoice, for: .normal)
        case .open:
            statusLabel.text = transactionsStrings.status + ": " + transactionsStrings.open
            payInvoiceButton.setTitle(transactionsStrings.advanceInvoicePayment, for: .normal)
        case .pendent:
            statusLabel.text = transactionsStrings.status + ": " + transactionsStrings.pendent
            payInvoiceButton.setTitle(transactionsStrings.payInvoice, for: .normal)
        }
        
        closingDateLabel.text = transactionsStrings.closingDate + ": " + invoice.closingDate
        dueDateLabel.text = transactionsStrings.dueDate + ": " + invoice.dueDate
        
    }
    
}
