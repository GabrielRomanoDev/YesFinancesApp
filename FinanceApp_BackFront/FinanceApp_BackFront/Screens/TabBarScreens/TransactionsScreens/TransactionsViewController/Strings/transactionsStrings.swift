//
//  transactionsStrings.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 27/05/23.
//

import Foundation

enum transactionsStrings {
    static let transactionsTitle = "Registros"
    static let noTransactionsRegistered = "Nenhuma transação cadastrada por enquanto!"
    static let noTransactionsFiltered = "Nenhuma transação atende os requisitos de filtro!"
    static let noExpenseFiltered = "Nenhuma despesa atende os requisitos de filtro!"
    
    static let invoiceTitle = "Fatura"
    static let invoiceTotal = "Total"
    static let status = "Status"
    
    static let closingDate = "Fecha em"
    static let dueDate = "Vence em"
    static let closedDate = "Fechou em"
    static let invoiceWasDueDate = "Venceu em"
    static let errorZeroedInvoice = "A fatura está zerada então não é possível realizar pagamento!"
    
    
    static let payInvoice = "Pagar Fatura"
    static let advanceInvoicePayment = "Adiantar Pagamento"
    
    static let open = "Aberta"
    static let paid = "Paga"
    static let pendent = "Pendente"
    static let future = "Futura"
    static let overdue = "Atrasada"
    static let zeroed = "Zerada"
}
