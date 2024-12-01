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
    func didTappedButton3(value: Bool)
}

class ButtonsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    @IBOutlet weak var thirdButton: UIButton!
    
    weak var delegate: ButtonsTableViewCellDelegate?
    var button1Value: Bool = false
    var button2Value: Bool = false
    var button3Value: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
  
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
    
    @IBAction func tappedThirdButton(_ sender: UIButton) {
        button3Value.toggle()
        updateButtonCollor(thirdButton, value: button3Value)
        delegate?.didTappedButton3(value: button3Value)
    }
    
    func setupCell(_ configuration: ButtonsCellConfiguration) {
        
        self.titleLabel.text = configuration.configurationTitle
        self.firstButton.titleLabel?.text = configuration.button1Title
        self.secondButton.titleLabel?.text = configuration.button2Title
        self.thirdButton.titleLabel?.text = configuration.button3Title
        
        setupButton(firstButton, value: configuration.button1Value)
        setupButton(secondButton, value: configuration.button2Value)
        setupButton(thirdButton, value: configuration.button3Value)
        
        button1Value = configuration.button1Value
        button2Value = configuration.button2Value
        button3Value = configuration.button3Value
    
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
