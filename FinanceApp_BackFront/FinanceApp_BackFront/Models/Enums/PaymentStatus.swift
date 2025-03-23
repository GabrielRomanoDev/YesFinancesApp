//
//  PaymentStatus.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 02/03/25.
//

enum PaymentStatus: Codable {
    case paid
    case pendent
    case future
    case overdue
}
