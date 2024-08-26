//
//  SelectionTableViewCell.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 18/08/24.
//

import UIKit

class SelectionTableViewCell: UITableViewCell {

    static let identifier:String = String(describing: SelectionTableViewCell.self)
    private var itemSelected: Bool = false
    
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var checkImage: UIImageView!
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func setupCell(title: String, itemSelected: Bool?) {
        itemLabel.text = title
        self.itemSelected = itemSelected ?? false
        updateCheckImage()
    }
    
    private func updateCheckImage() {
        
        if itemSelected {
            checkImage.isHidden = false
        } else {
            checkImage.isHidden = true
        }
    }
    
}
