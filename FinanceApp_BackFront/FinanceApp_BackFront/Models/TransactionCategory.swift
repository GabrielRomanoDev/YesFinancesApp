//
//  ListedCategories.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 06/04/23.
//

import Foundation
import UIKit

struct TransactionCategory {
    var name: String
    var imageName: String
    var colorIndex: Int
}

var categoryColors: [Int: UIColor] = [
    0 : UIColor.orange,
    1 : UIColor.magenta,
    2 : UIColor.systemPurple,
    3 : UIColor.red,
    4 : UIColor.systemPink,
    5 : UIColor.yellow,
    6 : UIColor.lightGray,
    7 : UIColor.systemBlue,
    8 : UIColor.cyan,
    9 : UIColor.systemGreen,
    10 : UIColor.systemRed,
    11 : UIColor.brown,
]
