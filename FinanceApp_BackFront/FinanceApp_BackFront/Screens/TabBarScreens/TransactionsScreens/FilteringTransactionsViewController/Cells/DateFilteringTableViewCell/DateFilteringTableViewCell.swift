//
//  DateFilteringTableViewCell.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 01/12/24.
//

import UIKit

protocol DateFilteringTableViewCellDelegate: AnyObject {
    func didTapDateSwitch(_ value: Bool)
    func didUpdateDates(isInitialDate: Bool, date: String)
}

class DateFilteringTableViewCell: UITableViewCell {
    
    static let identifier:String = String(describing: DateFilteringTableViewCell.self)
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var selectionSwitch: UISwitch!
    

    @IBOutlet weak var initialDateTextField: UITextField!
    @IBOutlet weak var initialDateLabel: UILabel!
    
    @IBOutlet weak var finalDateTextField: UITextField!
    @IBOutlet weak var finalDateLabel: UILabel!
    
    weak var delegate: DateFilteringTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupDataPicker()
        
        initialDateTextField.delegate = self
        finalDateTextField.delegate = self
    }
    
    @IBAction func tappedSwitch(_ sender: UISwitch) {
        delegate?.didTapDateSwitch(sender.isOn)
    }
    
    func setupCell(filteringDates: TransactionFilteringDates) {
        
        titleLabel.text = FilteringTransactionsStrings.timeInterval
        selectionSwitch.setOn(filteringDates.enabled, animated: false)
        
        initialDateTextField.isHidden = !filteringDates.enabled
        finalDateTextField.isHidden = !filteringDates.enabled
        
        initialDateTextField.text = filteringDates.initial.adjustDate()
        finalDateTextField.text = filteringDates.final.adjustDate()
        
    }
    
    var activeTextField: UITextField?

    private func setupDataPicker(){
        let datePickerInitial = UIDatePicker()
        datePickerInitial.datePickerMode = .date
        datePickerInitial.addTarget(self, action: #selector(dateChange(datePicker:)), for: UIControl.Event.valueChanged)
        datePickerInitial.frame.size = CGSize(width: 0, height: 300)
        datePickerInitial.preferredDatePickerStyle = .inline
        initialDateTextField.inputView = datePickerInitial
        
        let datePickerFinal = UIDatePicker()
        datePickerFinal.datePickerMode = .date
        datePickerFinal.addTarget(self, action: #selector(dateChange(datePicker:)), for: UIControl.Event.valueChanged)
        datePickerFinal.frame.size = CGSize(width: 0, height: 300)
        datePickerFinal.preferredDatePickerStyle = .inline
        finalDateTextField.inputView = datePickerFinal
        
//         Adicionar observador para saber qual textField está ativo
        initialDateTextField.addTarget(self, action: #selector(textFieldShouldBeginEditing(_:)), for: .editingDidBegin)
        finalDateTextField.addTarget(self, action: #selector(textFieldShouldBeginEditing(_:)), for: .editingDidBegin)
    }
    
    @objc func dateChange(datePicker: UIDatePicker) {
        
        guard let activeTextField = self.activeTextField else { return }
        
        let selectedDateText = datePicker.date.toString(adjustDate: true)
        let isFromDate = activeTextField == initialDateTextField
        let oppositeTextField = isFromDate ? finalDateTextField : initialDateTextField

        activeTextField.text = selectedDateText
        delegate?.didUpdateDates(isInitialDate: isFromDate, date: selectedDateText)
        
        if let oppositeDate = oppositeTextField?.text?.toDate(),
           (isFromDate && datePicker.date > oppositeDate) || (!isFromDate && datePicker.date < oppositeDate) {
            oppositeTextField?.text = selectedDateText
            delegate?.didUpdateDates(isInitialDate: !isFromDate, date: selectedDateText)
        }
        
        activeTextField.resignFirstResponder()
        
    }
    
}

extension DateFilteringTableViewCell: UITextFieldDelegate {
    
    @objc func textFieldShouldBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
}
