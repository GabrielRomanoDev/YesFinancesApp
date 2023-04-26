//
//  GoalsCollectionViewCell.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 26/04/23.
//

import UIKit

class GoalsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var goalImage: UIImageView!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var savedAmountLabel: UILabel!
    @IBOutlet weak var goalValueLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    static let identifier:String = String(describing: GoalsCollectionViewCell.self)
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupCell(goal:Goal){
        descLabel.text = goal.desc
        goalImage.image = UIImage(imageLiteralResourceName: goal.imageName)
        dateLabel.text = goal.targetDate
        savedAmountLabel.text = "R$ \(goal.savedAmount)"
        goalValueLabel.text = "R$ \(goal.goalValue)"
        progressView.progress = Float(goal.savedAmount/goal.goalValue)
    }
}
