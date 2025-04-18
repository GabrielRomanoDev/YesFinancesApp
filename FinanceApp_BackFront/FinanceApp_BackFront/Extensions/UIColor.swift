//
//  Color.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 27/05/23.
//

import Foundation
import UIKit
import SwiftUI

extension UIColor {
    static let backgroundColor = UIColor(named: "backgroundColor")
    static let greenAddIncomes = UIColor(named: "greenAddIncomes")
    static let greenGeneralIncomes = UIColor(named: "greenGeneralIncomes")
    static let greyInformations = UIColor(named: "greyInformations")
    static let inputBalances = UIColor(named: "inputBalances")
    static let loginButtonColor = UIColor(named: "loginButtonColor")
    static let negativeBalance = UIColor(named: "negativeBalance")
    static let positiveBalance = UIColor(named: "positiveBalance")
    static let redAddExpenses = UIColor(named: "redAddExpenses")
    static let redGeneralExpenses = UIColor(named: "redGeneralExpenses")
}

extension Color {
    static let backgroundColor = Color(UIColor.backgroundColor ?? .blue)
    static let greenAddIncomes = Color(UIColor.greenAddIncomes!)
    static let greenGeneralIncomes = Color(UIColor.greenGeneralIncomes!)
    static let greyInformations = Color(UIColor.greyInformations!)
    static let inputBalances = Color(UIColor.inputBalances!)
    static let loginButtonColor = Color(UIColor.loginButtonColor!)
    static let negativeBalance = Color(UIColor.negativeBalance!)
    static let positiveBalance = Color(UIColor.positiveBalance!)
    static let redAddExpenses = Color(UIColor.redAddExpenses!)
    static let redGeneralExpenses = Color(UIColor.redGeneralExpenses!)
}
