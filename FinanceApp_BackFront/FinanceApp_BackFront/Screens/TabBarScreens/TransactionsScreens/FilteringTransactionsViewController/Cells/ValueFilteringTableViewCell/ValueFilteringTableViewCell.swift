//
//  SwitchExpandTableViewCell.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 01/12/24.
//

import UIKit

protocol ValueFilteringTableViewCellDelegate: AnyObject {
    func didTapValueSwitch(_ value: Bool)
    func didTapTextField(cell: ValueFilteringTableViewCell, type: FieldType)
}

enum FieldType {
    case minValue
    case maxValue
}

class ValueFilteringTableViewCell: UITableViewCell {
    
    static let identifier:String = String(describing: ValueFilteringTableViewCell.self)
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var selectionSwitch: UISwitch!
    
    @IBOutlet weak var minValueTextField: UITextField!
    @IBOutlet weak var maxValueTextField: UITextField!
    
    weak var delegate: ValueFilteringTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        minValueTextField.delegate = self
        maxValueTextField.delegate = self
    }
    
    @IBAction func tappedSwitch(_ sender: UISwitch) {
        delegate?.didTapValueSwitch(sender.isOn)
    }
    
    func setupCell(filteringValues: TransactionFilteringValue) {
        
        titleLabel.text = FilteringTransactionsStrings.value
        selectionSwitch.setOn(filteringValues.enabled, animated: false)
        
        minValueTextField.isHidden = !filteringValues.enabled
        maxValueTextField.isHidden = !filteringValues.enabled
        
        minValueTextField.text = filteringValues.min.toStringMoney()
        maxValueTextField.text = filteringValues.max.toStringMoney()
        
    }
    
}

extension ValueFilteringTableViewCell: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == minValueTextField {
            delegate?.didTapTextField(cell: self, type: .minValue)
        } else if textField == maxValueTextField {
            delegate?.didTapTextField(cell: self, type: .maxValue)
        }
        return false
        
    }
    
}

