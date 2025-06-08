//
//  DetailsTransactionsView.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 28/04/25.
//

import SwiftUI

struct DetailsTransactionView: View {
    
    var transaction: any Transactions
    @State var isPresented: Bool
    var onEdit: () -> Void
    var onDelete: () -> Void

    let iconSize: CGFloat = 22
    let rowSize: CGFloat = 40

    var body: some View {
        VStack(spacing: 16) {
            
            if let _ = transaction as? CreditCardExpense {
                Text("Resumo da Despesa do Cartão")
                    .font(.headline)
                    .padding(.top)
            } else {
                if transaction.type == .income {
                    Text("Resumo da Receita")
                        .font(.headline)
                        .padding(.top)
                } else {
                    Text("Resumo da Despesa")
                        .font(.headline)
                        .padding(.top)
                }
            }
            
            
            Divider()
            
            summaryRow(icon: Image(systemName: "text.badge.plus"), label: "Descrição", value: transaction.desc)
            
            HStack {
                summaryRow(icon: Image(systemName: "dollarsign.circle"), label: "Valor", value: abs(transaction.amount).toStringMoney())
                
                summaryRow(icon: Image(systemName: "calendar"), label: "Data", value: transaction.date)
            }
            
            if let cardExpense = transaction as? CreditCardExpense {
                HStack {
                    summaryRow(
                        icon: Image(systemName: "creditcard"),
                        label: "Cartão",
                        value: CreditCardsRepository.shared.list.first(where: { $0.id == cardExpense.sourceId })?.desc ?? "N/A"
                    )
                    
                    summaryRow(
                        icon: Image(systemName: "doc.plaintext"),
                        label: "Fatura",
                        value: monthsText[cardExpense.month.month] ?? "-"
                    )
                }
            } else {
                summaryRow(
                    icon: Image(systemName: "creditcard"),
                    label: "Conta Bancária",
                    value: BankAccountsRepository.shared.list.first(where: { $0.id == transaction.sourceId })?.desc ?? "N/A"
                )
            }
            
            
            
            HStack {
                summaryRow(
                    icon: Image(systemName: "tag"),
                    label: "Categoria",
                    value: CategoriesRepository.shared.expense(transaction.categoryIndex).name
                )
                
                summaryRow(
                    icon: Image(systemName: "arrow.2.squarepath"),
                    label: "Fixa",
                    value: transaction.isMonthly ? "Sim" : "Não"
                )
                
            }
            
            
            
            if let cardExpense = transaction as? CreditCardExpense, cardExpense.installment.enabled && cardExpense.installment.total > 1 {
                HStack {
                    summaryRow(
                        icon: Image(systemName: "repeat"),
                        label: "Parcelamento",
                        value: "\(cardExpense.installment.current) de \(cardExpense.installment.total) parcelas"
                    )
                    summaryRow(
                        icon: Image(systemName: "dollarsign.arrow.circlepath"),
                        label: "Valor por parcela",
                        value: (transaction.amount / Double(cardExpense.installment.total)).toStringMoney()
                    )
                }
            }

            

            if !transaction.obs.isEmpty {
                summaryRow(icon: Image(systemName: "note.text"), label: "Observações", value: transaction.obs)
            }

            Spacer()

            HStack {
                Button(action: onDelete) {
                    Label(globalStrings.delete, systemImage: "trash")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(12)
                }

                Button(action: onEdit) {
                    Label(globalStrings.edit, systemImage: "pencil")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    private func summaryRow(icon: Image, label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            icon
                .frame(width: iconSize)
                .foregroundColor(.gray)
            VStack(alignment: .leading) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.body)
            }
            Spacer()
        }
    }
}



#Preview {
    
    var accountTransaction = AccountTransaction (
        desc: "Hopi Hari",
        amount: 100,
        categoryIndex: 0,
        date: Date().toString(),
        type: .income,
        isMonthly: false,
        sourceId: "",
        obs: globalStrings.emptyString
    )
    
    var cardPayment = CreditCardExpense(
        desc: "Pagamento da fatura cartao Bradesco",
        amount: 100,
        categoryIndex: 0,
        date: Date().toString(),
        type: .income,
        isMonthly: false,
        paymentStatus: .paid,
        month: Date().getMonth(),
        installment: Installment(enabled: true, current: 3, total: 5),
        sourceId: "",
        obs: globalStrings.emptyString
    )
    
    DetailsTransactionView(transaction: accountTransaction, isPresented: true) {
        
        
    } onDelete: {
        
    }
    
}
