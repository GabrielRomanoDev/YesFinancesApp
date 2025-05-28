//
//  AddTransactionView.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 24/04/25.
//

import SwiftUI

struct AddTransactionView: View {
    
    @Environment(\.dismiss) var dismiss
    @State private var showCloseText = false
    @State private var showAddIncomeView = false
    @State private var showAddExpenseView = false
    @State private var showAddCardExpenseView = false
    @State private var showAddTransferView = false
    
    var body: some View {
        ZStack {
            
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    VStack(spacing: 15) {
                        Spacer()
                        
                        CustomButton(title: "Receita na Conta", imageName: "arrowshape.up.circle.fill", simbolColor: Color.greenAddIncomes) {
                            showAddIncomeView = true
                        }
                        
                        CustomButton(title: "Despesa na Conta", imageName: "arrowshape.down.circle.fill", simbolColor: Color.redAddExpenses) {
                            showAddExpenseView = true
                        }
                        
                        CustomButton(title: "Despesa no Cartão", imageName: "arrowshape.down.circle.fill", simbolColor: Color.redAddExpenses) {
                            showAddCardExpenseView = true
                        }
                        
                        CustomButton(title: "Transferência", imageName: "repeat.circle", simbolColor: Color.blue) {
                            showAddTransferView = true
                        }
                        
                    }
                    .padding(.trailing, 5)
                }
                .navigationTitle("SwiftUI View")
                
                Button(action: {
                    dimissView()
                }) {
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 45, height: 45)
                        
                        if showCloseText {
                            Text("Close")
                                .font(.headline)
                                .transition(.opacity.combined(with: .move(edge: .trailing)))
                        }
                    }
                    .padding(.horizontal, showCloseText ? 10 : 0)
                    .padding(.vertical, 5)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .shadow(radius: 5)
                }
                .onAppear {
                    withAnimation(.easeOut(duration: 0.2)) {
                        showCloseText = true
                    }
                }
                
            }
        }
        .sheet(isPresented: $showAddIncomeView) {
            TransactionFormScreen(type: .income, isPresented: $showAddIncomeView) {
                dimissView()
            }
        }
        .sheet(isPresented: $showAddExpenseView) {
            TransactionFormScreen(type: .expense, isPresented: $showAddExpenseView) {
                dimissView()
            }
        }
        .sheet(isPresented: $showAddCardExpenseView) {
            CreditCardExpenseFormScreen(isPresented: $showAddCardExpenseView) {
                dimissView()
            }
        }
        //        .sheet(isPresented: $showAddTransferView) {
        //            TransferBetweenAccountsFormScreen(type: .expense) {
        //                DispatchQueue.main.async {
        //                    dismiss()
        //                }
        //            }
        //            print("ShowTransferView")
        //        }
        .onTapGesture {
            dimissView()
        }
    }
    
    private func dimissView() {
        DispatchQueue.main.async {
            dismiss()
            NotificationCenter.default.post(name: .didCloseAddTransaction, object: nil)
        }
    }
    
}

fileprivate struct CustomButton: View {
    
    var title: String
    var imageName: String
    var simbolColor: Color
    var action: () -> Void
    
    @State private var isPressed: Bool = false

    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Text(title)
                    .foregroundStyle(.black)
                
                Spacer()
                
                Image(systemName: imageName)
                    .resizable()
                    .foregroundStyle(simbolColor)
                    .frame(width: 26, height: 26)
            }
            .frame(maxWidth: 186)
            .padding(8)
            .background(Color.white)
            .cornerRadius(16)
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isPressed)
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

#Preview {
    AddTransactionView()
}
