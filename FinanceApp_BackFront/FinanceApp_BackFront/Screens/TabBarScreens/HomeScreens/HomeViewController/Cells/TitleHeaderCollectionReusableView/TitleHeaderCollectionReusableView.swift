//
//  TitleHeaderCollectionReusableView.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 14/05/23.
//

import UIKit

class TitleHeaderCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    static let identifier:String = String(describing: TitleHeaderCollectionReusableView.self)
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func setupCell(title: String, color: UIColor = .black, font: UIFont = .systemFont(ofSize: 18)) {
        titleLabel.text = title
        titleLabel.textColor = color
        titleLabel.font = font
    }
    
}
