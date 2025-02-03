//
//  ButtonTableViewCell.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 01/12/24.
//

import UIKit

protocol ButtonTableViewCellDelegate: AnyObject {
    func didTappedButton()
}

class ButtonTableViewCell: UITableViewCell {
    
    static let identifier:String = String(describing: ButtonTableViewCell.self)
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    weak var delegate: ButtonTableViewCellDelegate?

    @IBOutlet weak var button: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func tappedButton(_ sender: UIButton) {
        delegate?.didTappedButton()
    }
    
    func setupCell(title: String) {
        button.setTitle(title, for: .normal)
    }
    
}
