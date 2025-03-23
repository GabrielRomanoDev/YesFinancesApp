//
//  ButtonsTableViewCell.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 01/12/24.
//

import UIKit

protocol ButtonsTableViewCellDelegate: AnyObject {
    func didTappedButton1(value: Bool)
    func didTappedButton2(value: Bool)
}

class ButtonsTableViewCell: UITableViewCell {
    
    static let identifier:String = String(describing: ButtonsTableViewCell.self)
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    
    weak var delegate: ButtonsTableViewCellDelegate?
    var button1Value: Bool = false
    var button2Value: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
  
    }
    
    @IBAction func tappedFirstButton(_ sender: UIButton) {
        button1Value.toggle()
        updateButtonCollor(firstButton, value: button1Value)
        delegate?.didTappedButton1(value: button1Value)
    }
    
    @IBAction func tappedSecondButton(_ sender: UIButton) {
        button2Value.toggle()
        updateButtonCollor(secondButton, value: button2Value)
        delegate?.didTappedButton2(value: button2Value)
    }
    
    func setupCell(configuration: ButtonsCellConfiguration) {
        
        self.titleLabel.text = configuration.configurationTitle
        self.firstButton.setTitle(configuration.button1Title, for: .normal)
        self.secondButton.setTitle(configuration.button2Title, for: .normal)
        
        setupButton(firstButton, value: configuration.button1Value)
        setupButton(secondButton, value: configuration.button2Value)
        
        button1Value = configuration.button1Value
        button2Value = configuration.button2Value
    
    }
    
    private func setupButton(_ button: UIButton, value: Bool?) {
        button.layer.cornerRadius = 15
        button.clipsToBounds = true
        button.layer.masksToBounds = true
        
        updateButtonCollor(button, value: value ?? false)
        
        button.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private func updateButtonCollor(_ button: UIButton, value: Bool) {
    
        if value {
            button.backgroundColor = .systemBlue
            button.tintColor = .white
        } else {
            button.backgroundColor = .systemGray6
            button.tintColor = .black
        }
        
    }
    
    
}
