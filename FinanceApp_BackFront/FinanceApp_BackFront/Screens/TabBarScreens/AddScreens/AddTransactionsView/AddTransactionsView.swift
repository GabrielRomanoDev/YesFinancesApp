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
            
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    VStack(spacing: 15) {
                        Spacer()
                        
                        Button {
                            showAddIncomeView = true
                        } label: {
                            HStack {
                                Text("Receita na Conta")
                                    .foregroundStyle(.black)
                                
                                Spacer()
                                
                                Image(systemName: "arrowshape.up.circle.fill")
                                    .resizable()
                                    .foregroundStyle(Color.greenAddIncomes)
                                    .frame(width: 26, height: 26)
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        
                        Button {
                            
                            showAddExpenseView = true
                            
                        } label: {
                            HStack {
                                Text("Despesa na Conta")
                                    .foregroundStyle(.black)
                                
                                Spacer()
                                
                                Image(systemName: "arrowshape.down.circle.fill")
                                    .resizable()
                                    .foregroundStyle(Color.redAddExpenses)
                                    .frame(width: 26, height: 26)
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        
                        
                        Button {
                            showAddCardExpenseView = true
                        } label: {
                            HStack {
                                Text("Despesa no Cartão")
                                    .foregroundStyle(.black)
                                
                                Spacer()
                                
                                Image(systemName: "arrowshape.down.circle.fill")
                                    .resizable()
                                    .foregroundStyle(Color.redAddExpenses)
                                    .frame(width: 26, height: 26)
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        
                        Button {
                            showAddTransferView = true
                        } label: {
                            HStack {
                                Text("Transferência")
                                    .foregroundStyle(.black)
                                
                                Spacer()
                                
                                Image(systemName: "repeat.circle")
                                    .resizable()
                                    .foregroundStyle(Color.blue)
                                    .frame(width: 26, height: 26)
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        
                    }
                }
                .navigationTitle("SwiftUI View")
                
                Button(action: {
                    dismiss()
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
                DispatchQueue.main.async {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showAddExpenseView) {
            TransactionFormScreen(type: .expense, isPresented: $showAddExpenseView) {
                DispatchQueue.main.async {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showAddCardExpenseView) {
            CreditCardExpenseFormScreen(isPresented: $showAddCardExpenseView) {
                DispatchQueue.main.async {
                    dismiss()
                }
            }
        }
        //        .sheet(isPresented: $showAddTransferView) {
        //            TransactionFormScreen(type: .expense) {
        //                DispatchQueue.main.async {
        //                    dismiss()
        //                }
        //            }
        //            print("ShowTransferView")
        //        }
        .onTapGesture {
            DispatchQueue.main.async {
                dismiss()
            }
        }
    }
}

#Preview {
    AddTransactionView()
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: 186)
            .padding(8)
            .background(Color.white)
            .cornerRadius(16)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
    }
}


