//
//  CategoriesModalCell.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 14/04/23.
//

import UIKit

class CategoriesModalCell: UITableViewCell {
    
    @IBOutlet weak var categoryBackground: UIView!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    static let identifier: String = "CategoriesModalCell"

    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupCell(listedCategories:ListedCategories){
        categoryBackground.backgroundColor = listedCategories.color
        categoryImage.image = UIImage(imageLiteralResourceName: listedCategories.imageName)
        nameLabel.text = listedCategories.name
    }
    
}
