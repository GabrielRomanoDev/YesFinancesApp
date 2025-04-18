//
//  CreditCardExpenseFormScreen.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 31/03/25.
//Aqui

import SwiftUI
import UIKit
import Foundation

struct CreditCardExpenseFormScreen: View {
    @State var expense: CreditCardExpense
    @State var date = Date()
    
    @State private var selectedCategory: TransactionCategory? = nil
    @State private var selectedSource: CreditCard? = nil
    @State private var showSheet = false
    @State private var showInputNumber = false
    @State private var showDates = false
    @State private var showSourcesSheet = false
    @State private var value: String = "0"
    @State private var numParcelas: String = "1"
    
    @State var cardIndex: Int = 0
    
    init(expense: CreditCardExpense) {
        self.expense = expense
        
        for (i, card) in CreditCardsRepository.shared.list.enumerated() {
            if card.id == expense.sourceId {
                cardIndex = i
                break
            }
        }
        
    }
    
    var onDismiss: (() -> Void)?
    let categories: [TransactionCategory] = [
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
    
    let sources: [CreditCard] = [
        CreditCard(desc: "Cartao Bradesco", limit: 5000, bank: .bradesco, closingDay: 15, dueDay: 20, standardCard: false, obs: ""),
        CreditCard(desc: "Cartao Itau", limit: 6000, bank: .itau, closingDay: 15, dueDay: 20, standardCard: false, obs: ""),
        CreditCard(desc: "Cartao Nubank", limit: 7000, bank: .nubank, closingDay: 15, dueDay: 20, standardCard: true, obs: ""),
        CreditCard(desc: "Cartao Caixa", limit: 8000, bank: .caixa, closingDay: 15, dueDay: 20, standardCard: false, obs: ""),
    ]
    
    let iconSize: CGFloat = 22
    let rowSize: CGFloat = 40
    
    
    var body: some View {
        
        NavigationStack {
            
            ZStack {
                
                VStack(spacing: 0) {
                    Text("Cadastro de Gasto no Cartao")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 40)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(UIColor.redGeneralExpenses!))
                    
                    List {
                        
                        // Descrição
                        HStack() {
                            Image("image46")
                                .resizable()
                                .frame(width: iconSize, height: iconSize)
                                .padding(.leading, 8)
                            TextField("Descrição", text: $expense.desc)
                                .frame(height: 40)
                        }
                        .alignmentGuide(.listRowSeparatorLeading) { _ in
                          return -20
                        }
                        
                        //valor
                        Button {
                            showInputNumber = true
                        } label: {
                            
                            HStack {
                                Image(systemName: "dollarsign.circle")
                                    .resizable()
                                    .frame(width: iconSize, height: iconSize)
                                    .padding(.leading, 6)
                                Text("\(Double(value)?.toStringMoney() ?? "0,00")")
                                    .frame(height: self.rowSize)
                                    .frame(alignment: .trailing)
                            }
                            .alignmentGuide(.listRowSeparatorLeading) { _ in
                              return -20
                            }
                            
                        }
                        
                        
                        //Date
                        Button {
                            showDates = true
                        } label: {
                            HStack() {
                                
                                Image(systemName: "calendar")
                                    .resizable()
                                    .frame(width: iconSize, height: iconSize)
                                    .padding(.leading, 6)
                                
                                Text("\(date.dateWrittenString())")
                                    .frame(height: self.rowSize)
                                
                            }
                        }
                        .alignmentGuide(.listRowSeparatorLeading) { _ in
                          return -20
                        }
                        
                        // Categoria com visual customizado
                        Button {
                            selectedCategory = categories[0]
                            showSheet = true
                        } label: {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(Color(categoryColors[categories[expense.categoryIndex].colorIndex]!))
                                        .frame(width: 34, height: 34)
                                    Image(categories[expense.categoryIndex].imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25, height: 25)
                                }
                                Text(categories[expense.categoryIndex].name)
                                    .foregroundColor(.black)
                            }
                            .frame(height: self.rowSize)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            
                        }
                        .buttonStyle(PlainButtonStyle())
                        .alignmentGuide(.listRowSeparatorLeading) { _ in
                          return -20
                        }
                        
                        // Account com visual customizado
                        Button {
                            selectedSource = sources[0]
//                            selectedSource = CreditCardsRepository.shared.list[0]
                            showSourcesSheet = true
                        } label: {
                            HStack {
                                //Image(bankProperties[CreditCardsRepository.shared.list[cardIndex].bank]?.imageName ?? "BancoItau")
                                Image(bankProperties[sources[cardIndex].bank]?.imageName ?? "BancoItau")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 34, height: 34)
                                    .clipShape(Circle())
                                
                                //Text(bankProperties[CreditCardsRepository.shared.list[cardIndex].bank]?.textNameBank ?? "BancoItau")
                                Text(bankProperties[sources[cardIndex].bank]?.textNameBank ?? "BancoItau")
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                            }
                            .frame(height: self.rowSize)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                            
                        }
                        .buttonStyle(PlainButtonStyle())
                        .alignmentGuide(.listRowSeparatorLeading) { _ in
                          return -20
                        }
                        
                        //Parcelamento
                        VStack {
                            HStack {
                                Image(systemName: "repeat.circle")
                                    .resizable()
                                    .frame(width: iconSize, height: iconSize)
                                    .padding(.leading, 6)
                                
                                Toggle("Parcelamento", isOn: $expense.installment.enabled)
                                    .frame(height: self.rowSize)
                                    .alignmentGuide(.listRowSeparatorLeading) { _ in
                                      return -20
                                    }
                            }
                            
                            if (expense.installment.enabled) {
                                
                                HStack(spacing: 5) {
                                    Text("Dividido em:")
                                        .frame(width: 80, alignment: .center)
                                    
                                    TextField("1", text: $numParcelas)
                                        .multilineTextAlignment(.trailing)
                                        .keyboardType(.numberPad)
                                        .frame(width: 50)
                                        .padding(6)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(6)
                                        .onChange(of: numParcelas) { newValue in
                                            // Garante que só números sejam digitados
                                            numParcelas = newValue.filter { $0.isNumber }
                                        }
                                    
                                    Spacer()
                                    
                                    Text("Valor por parcela: \(abs(expense.amount / (Double(numParcelas) ?? 1)).toStringMoney())")
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal)
                                
                            }
                        }
                        .alignmentGuide(.listRowSeparatorLeading) { _ in
                          return -20
                        }
                        
                        //Despesa Fixa
                        HStack {
                            Image(systemName: "repeat.circle")
                                .resizable()
                                .frame(width: iconSize, height: iconSize)
                                .padding(.leading, 6)
                            
                            Toggle("Despesa Fixa", isOn: $expense.isMonthly)
                                .frame(height: self.rowSize)
                                
                        }
                        .alignmentGuide(.listRowSeparatorLeading) { _ in
                          return -20
                        }
                        
                        // Observações
                        HStack() {
                            Image(systemName: "note.text")
                                .resizable()
                                .frame(width: iconSize, height: iconSize)
                                .padding(.leading, 6)
                            TextField("Observações", text: $expense.obs)
                                .frame(height: self.rowSize)
                                .multilineTextAlignment(.leading)
                        }
                        .alignmentGuide(.listRowSeparatorLeading) { _ in
                          return -20
                        }
                        
                    }
                    .listStyle(PlainListStyle())
                    .frame(maxHeight: .infinity)
                    
                    Button(action: {
                        print("Gasto enviado")
                    }) {
                        Text("Enviar")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: 150)
                            .background(Color(UIColor.redGeneralExpenses!))
                            .cornerRadius(15)
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 30)
                    
                }
            }
            
        }
        .sheet(isPresented: $showSheet) {
            CategoriesModalView(categories: categories, selectedItem: $expense.categoryIndex, showView: $showSheet)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showSourcesSheet) {
            SelectSourceModalView(title: "Cartões de Credito", itens: sources, selectedItem: $cardIndex, showView: $showSourcesSheet)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showDates) {
            VStack {
                DatePicker("", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                
                Button("Selecionar") { showDates = false }
                    .buttonStyle(.borderedProminent)
                    .presentationDetents([.medium])
            }
        }
        .overtop(showOverTop: showInputNumber, overTopView: InputNumberOverTopView(inputText: "0", showInputNumber: $showInputNumber) { result in
            expense.amount = Double(result) ?? 0.0
            value = result
        })
        
    }
    
}

#Preview {
    
    let cardPayment = CreditCardExpense(
        desc: "Pagamento da fatura cartao Bradesco",
        amount: 100,
        categoryIndex: 0,
        date: Date().toString(),
        type: .income,
        isMonthly: false,
        paymentStatus: .paid,
        month: Date().getMonth(),
        installment: Installment(),
        sourceId: "",
        obs: globalStrings.emptyString
    )
    
    CreditCardExpenseFormScreen(expense: cardPayment)
    
}

//struct CustomRow: View {
//    var category: TransactionCategory
//
//    var body: some View {
//
//        ZStack {
//
//            Color(UIColor.blue ?? .yellow).edgesIgnoringSafeArea(.all)
//
//            HStack {
//                ZStack {
//
//                    Circle()
//                        .fill(Color(categoryColors[category.colorIndex]!))
//                        .frame(width: 30, height: 30)
//                    Image(category.imageName)
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 16, height: 16)
//                }
//                Text(category.name)
//                    .foregroundColor(.black)
//                Text("2")
//                    .foregroundColor(.black)
//            }
//            .contentShape(Rectangle())
//            .onTapGesture {
//                // Opcional: abrir modal de seleção
//            }
//            .padding([.top])
//        }
//    }
//}
