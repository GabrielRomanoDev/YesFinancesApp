//
//  InvoceInformationsCollectionViewCell.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 24/03/25.
//

import UIKit

protocol InvoiceInfoCollectionViewCellDelegate: AnyObject {
    func didTapPayInvoiceButton()
}

class InvoiceInfoCollectionViewCell: UICollectionViewCell {
    
    static let identifier:String = String(describing: InvoiceInfoCollectionViewCell.self)
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    weak var delegate: InvoiceInfoCollectionViewCellDelegate?
    
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
        delegate?.didTapPayInvoiceButton()
    }
    
    func setupCell(invoice: Invoice) {
        
        invoiceTotalLabel.text = transactionsStrings.invoiceTotal + ": " + "\(invoice.amount.toStringMoney())"
        payInvoiceButton.isHidden = false
        
        switch invoice.paymentStatus {
        case .future:
            statusLabel.text = transactionsStrings.status + ": " + transactionsStrings.future
            payInvoiceButton.isHidden = true
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
        case .zeroed:
            statusLabel.text = transactionsStrings.status + ": " + transactionsStrings.pendent
            payInvoiceButton.isHidden = true
        }
        
        if let closingDate = invoice.closingDate.toDate(), closingDate < Date() {
            closingDateLabel.text = transactionsStrings.closedDate + ": " + invoice.closingDate
        } else {
            closingDateLabel.text = transactionsStrings.closingDate + ": " + invoice.closingDate
        }
        
        if let dueDate = invoice.dueDate.toDate(), dueDate >= Date() {
            dueDateLabel.text = transactionsStrings.invoiceWasDueDate + ": " + invoice.dueDate
        } else {
            dueDateLabel.text = transactionsStrings.dueDate + ": " + invoice.dueDate
        }
        
    }
    
}
