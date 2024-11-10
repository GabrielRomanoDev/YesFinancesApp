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

var expenseCategories: [TransactionCategory] = [
    TransactionCategory(name: "Alimentação", imageName: "image35", colorIndex: 0),
    TransactionCategory(name: "Assinaturas", imageName: "image13", colorIndex: 1),
    TransactionCategory(name: "Casa", imageName: "image4", colorIndex: 2),
    TransactionCategory(name: "Educação", imageName: "image46", colorIndex: 3),
    TransactionCategory(name: "Esportes", imageName: "image8", colorIndex: 4),
    TransactionCategory(name: "Lazer", imageName: "image3", colorIndex: 5),
    TransactionCategory(name: "Serviços", imageName: "image40", colorIndex: 6),
    TransactionCategory(name: "Transferências", imageName: "image43", colorIndex: 7),
    TransactionCategory(name: "Transporte", imageName: "image0", colorIndex: 8),
    TransactionCategory(name: "Vestuario", imageName: "image1", colorIndex: 9),
    TransactionCategory(name: "Viagem", imageName: "image21", colorIndex: 10),
    TransactionCategory(name: "Outros", imageName: "image37", colorIndex: 11),
]

var incomeCategories: [TransactionCategory] = [
    TransactionCategory(name: "Salario", imageName: "image7", colorIndex: 0),
    TransactionCategory(name: "Seguro Desemprego", imageName: "image15", colorIndex: 1),
    TransactionCategory(name: "Transferência", imageName: "image43", colorIndex: 2),
    TransactionCategory(name: "Apostas", imageName: "image3", colorIndex: 3),
    TransactionCategory(name: "Vendas", imageName: "image11", colorIndex: 4),
    TransactionCategory(name: "Outros", imageName: "image37", colorIndex: 5),
]

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
