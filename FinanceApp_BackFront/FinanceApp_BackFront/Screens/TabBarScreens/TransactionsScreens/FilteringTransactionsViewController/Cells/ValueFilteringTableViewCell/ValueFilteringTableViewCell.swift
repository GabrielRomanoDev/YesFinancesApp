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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
    
    var activeTextField: UITextField?

//    private func setupDataPicker(){
//        let datePickerFrom = UIDatePicker()
//        datePickerFrom.datePickerMode = .date
//        datePickerFrom.addTarget(self, action: #selector(dateChange(datePicker:)), for: UIControl.Event.valueChanged)
//        datePickerFrom.frame.size = CGSize(width: 0, height: 300)
//        datePickerFrom.preferredDatePickerStyle = .inline
////        fromDateTextField.inputView = datePickerFrom
//        
//        let datePickerTo = UIDatePicker()
//        datePickerTo.datePickerMode = .date
//        datePickerTo.addTarget(self, action: #selector(dateChange(datePicker:)), for: UIControl.Event.valueChanged)
//        datePickerTo.frame.size = CGSize(width: 0, height: 300)
//        datePickerTo.preferredDatePickerStyle = .inline
////        toDateTextField.inputView = datePickerTo
        
        // Adicionar observador para saber qual textField está ativo
//        fromDateTextField.addTarget(self, action: #selector(textFieldShouldBeginEditing(_:)), for: .editingDidBegin)
//        toDateTextField.addTarget(self, action: #selector(textFieldShouldBeginEditing(_:)), for: .editingDidBegin)
//    }
    
//    @objc func dateChange(datePicker: UIDatePicker) {
//        
//        guard let activeTextField = activeTextField else { return }
//        
//        let selectedDateText = datePickerChange(date: datePicker.date)
////        let isFromDate = activeTextField == fromDateTextField
////        let oppositeTextField = isFromDate ? toDateTextField : fromDateTextField
////        
//        activeTextField.text = selectedDateText
//        updateParametersDate(for: isFromDate, with: selectedDateText)
//        
//        if let oppositeDate = oppositeTextField?.text?.toDate(),
//           (isFromDate && datePicker.date > oppositeDate) || (!isFromDate && datePicker.date < oppositeDate) {
//            oppositeTextField?.text = selectedDateText
//            updateParametersDate(for: !isFromDate, with: selectedDateText)
//        }
//        
//        activeTextField.resignFirstResponder()
//        
//    }

    private func updateParametersDate(for isFromDate: Bool, with date: String) {
        
//        if parameters.dates == nil {
//            parameters.dates = TransactionFilteringDates(from: date, to: date)
//        } else if isFromDate {
//            parameters.dates?.from = date
//        } else {
//            parameters.dates?.to = date
//        }
        
    }
    
    private func datePickerChange(date: Date) -> String {
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        switch date.toString(format: globalStrings.dateFormat) {
        case today.toString(format: globalStrings.dateFormat):
            return globalStrings.todayText
        case yesterday.toString(format: globalStrings.dateFormat):
            return globalStrings.yesterdayText
        case tomorrow.toString(format: globalStrings.dateFormat):
            return globalStrings.tomorrowText
        default:
            return date.toString(format: globalStrings.dateFormat)
        }
    }
    
}

//extension SwitchExpandTableViewCell: InsertNumbersModalProtocol {
//
//    func didSelectNumber(_ value: Double, id: Int) {
//        DispatchQueue.main.async { [weak self] in
//            guard let self = self, let limits = self.parameters.limits else { return }
//
//            var updatedLimits = limits
//
//            switch id {
//            case 0:
//                self.minValueTextField.text = value.toStringMoney()
//                updatedLimits.min = value
//
//                if updatedLimits.max < value {
//                    self.maxValueTextField.text = value.toStringMoney()
//                    updatedLimits.max = value
//                }
//
//            case 1:
//                self.maxValueTextField.text = value.toStringMoney()
//                updatedLimits.max = value
//
//                if updatedLimits.min > value {
//                    self.minValueTextField.text = value.toStringMoney()
//                    updatedLimits.min = value
//                }
//
//            default:
//                break
//            }
//
//            self.parameters.limits = updatedLimits
//        }
//    }
//}

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

