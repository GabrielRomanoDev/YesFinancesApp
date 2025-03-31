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
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cardNameLabel: UILabel!
    @IBOutlet weak var invoiceTotalLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var closingDateLabel: UILabel!
    
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var payInvoiceButton: UIButton!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.searchBar.searchBarStyle = .minimal
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.invoiceTotalLabel.text = globalStrings.emptyString
    }

    @IBAction func tappedPayInvoiceButton(_ sender: UIButton) {
        delegate?.didTapPayInvoiceButton()
    }
    
    func setupCell(invoice: Invoice) {
        
        cardNameLabel.text = invoice.desc.replacingOccurrences(of: transactionsStrings.invoiceTitle + " ", with: globalStrings.emptyString)
        cardNameLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        
        invoiceTotalLabel.text = transactionsStrings.invoiceTotal + ": " + "\(abs(invoice.amount).toStringMoney())"
        payInvoiceButton.isEnabled = true
        
        switch invoice.paymentStatus {
        case .future:
            statusLabel.text = transactionsStrings.status + ": " + transactionsStrings.future
            payInvoiceButton.isEnabled = false
        case .paid:
            statusLabel.text = transactionsStrings.status + ": " + transactionsStrings.paid
            payInvoiceButton.isEnabled = false
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
            payInvoiceButton.isEnabled = false
        }
        
        if invoice.amount == 0 {
            payInvoiceButton.isEnabled = false
        }
        
        if let closingDate = invoice.closingDate.toDate(), closingDate < Date() {
            closingDateLabel.text = transactionsStrings.closedDate + ": " + String(invoice.closingDate.dropLast(5))
        } else {
            closingDateLabel.text = transactionsStrings.closingDate + ": " + String(invoice.closingDate.dropLast(5))
        }
        
        if let dueDate = invoice.dueDate.toDate(), dueDate <= Date() {
            dueDateLabel.text = transactionsStrings.invoiceWasDueDate + ": " + String(invoice.dueDate.dropLast(5))
        } else {
            dueDateLabel.text = transactionsStrings.dueDate + ": " + String(invoice.dueDate.dropLast(5))
        }
        
        self.containerView.roundCorners([.bottomLeft, .bottomRight], radius: 20)
        
    }
    
}
