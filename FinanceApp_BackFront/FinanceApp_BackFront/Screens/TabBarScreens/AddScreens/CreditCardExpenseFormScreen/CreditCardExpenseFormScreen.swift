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
    
    @StateObject private var viewModel: RegisterCardExpViewModel
    @State private var showCategorySheet = false
    @State private var showInputNumber = false
    @State private var showDatePicker = false
    @State private var showSourcesSheet = false
    @State private var showInvoicesSheet = false
    @State private var showMissingAmountAlert = false
    @State private var showMissingDescAlert = false
    
    var onDismiss: (() -> Void)

    let iconSize: CGFloat = 22
    let rowSize: CGFloat = 40
    @State private var editingFlag: Bool = false

    init(expense: CreditCardExpense, onDismiss: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: RegisterCardExpViewModel(expense: expense))
        self.onDismiss = onDismiss
    }

    var body: some View {
        NavigationStack {
            ZStack {
                
                VStack(spacing: 0) {
                    Text(addStrings.screenTitle)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 40)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(UIColor.redGeneralExpenses!))

                    List {
                        
                        // Description
                        IconRow(icon: Image("image46"), iconSize: iconSize, isTextFieldElement: true) {
                            TextField(addStrings.descriptionPlaceholder, text: $viewModel.expense.desc, onEditingChanged: { editing in
                                editingFlag = editing
                            })
                                .frame(height: rowSize)
                        }

                        // Amount
                        IconRow(icon: Image(systemName: "dollarsign.circle"), iconSize: iconSize, isTextFieldElement: false) {
                            Text("\(viewModel.expense.amount.toStringMoney())")
                                .frame(height: rowSize)
                        } onTap: {
                            hideKeyboard()
                            showInputNumber = true
                        }

                        // Date
                        IconRow(icon: Image(systemName: "calendar"), iconSize: iconSize, isTextFieldElement: false) {
                            Text("\(viewModel.selectedDate.dateWrittenString())")
                                .frame(height: rowSize)
                        } onTap: {
                            hideKeyboard()
                            showDatePicker = true
                        }

                        // Category
                        Button {
                            showCategorySheet = true
                            hideKeyboard()
                        } label: {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(Color(categoryColors[CategoriesRepository.shared.expenses[viewModel.expense.categoryIndex].colorIndex]!))
                                        .frame(width: 34, height: 34)
                                    Image(CategoriesRepository.shared.expenses[viewModel.expense.categoryIndex].imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 25, height: 25)
                                }
                                Text(CategoriesRepository.shared.expenses[viewModel.expense.categoryIndex].name)
                                    .foregroundColor(.black)
                            }
                            .frame(height: self.rowSize)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .alignmentGuide(.listRowSeparatorLeading) { _ in return -20 }

                        // Account
                        Button {
                            showSourcesSheet = true
                            hideKeyboard()
                        } label: {
                            HStack {
                                Image(bankProperties[CreditCardsRepository.shared.list[viewModel.cardIndex].bank]?.imageName ?? "BancoItau")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 34, height: 34)
                                    .clipShape(Circle())

                                Text(CreditCardsRepository.shared.list[viewModel.cardIndex].desc)
                                    .foregroundColor(.black)
                            }
                            .frame(height: self.rowSize)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .alignmentGuide(.listRowSeparatorLeading) { _ in return -20 }
                        
                        //Invoice Selector
                        IconRow(icon: Image("image54"), iconSize: iconSize, isTextFieldElement: false) {
                            Text("\(addStrings.invoiceOf) \(monthsText[viewModel.expense.month.month] ?? globalStrings.january)")
                                .frame(height: rowSize)
                        } onTap: {
                            hideKeyboard()
                            showInvoicesSheet = true
                        }
                        
                        // Installment Configuration
                        VStack {
                            IconRow(icon: Image(systemName: "repeat.circle"), iconSize: iconSize, isTextFieldElement: false) {
                                Toggle(addStrings.installmentLabel, isOn: viewModel.installmentBinding)
                                    .frame(height: rowSize)
                                    .tint(Color.redAddExpenses)
                                    .background(Color.white)
                            }
                        
                            
                            if viewModel.expense.installment.enabled {
                                
                                VStack(spacing: 15) {
                                    
                                    HStack(spacing: 70) {
                                        VStack(spacing: 5) {
                                            Text(addStrings.dividedInto)
                                                .frame(alignment: .leading)
                                            
                                            HStack {
                                                Button {
                                                    if viewModel.expense.installment.total > 1 {
                                                        viewModel.expense.installment.total -= 1
                                                    }
                                                    
                                                    if viewModel.expense.installment.current > viewModel.expense.installment.total {
                                                        viewModel.expense.installment.current = viewModel.expense.installment.total
                                                    }
                                                } label: {
                                                    Image(systemName: "minus.circle")
                                                }
                                                .buttonStyle(.plain)
                                                
                                                Text("\(viewModel.expense.installment.total)")
                                                    .multilineTextAlignment(.center)
                                                    .frame(width: 50)
                                                    .background(Color.gray.opacity(0.1))
                                                    .cornerRadius(6)
                                                
                                                Button {
                                                        viewModel.expense.installment.total += 1
                                                } label: {
                                                    Image(systemName: "plus.circle")
                                                }
                                                .buttonStyle(.plain)
                                            }
                                            
                                        }
                                        
                                        VStack(spacing: 5) {
                                            Text(addStrings.currentInstallment)
                                                .frame(alignment: .leading)
                                            
                                            HStack {
                                                Button {
                                                    if viewModel.expense.installment.current > 1 {
                                                        viewModel.expense.installment.current -= 1
                                                    }
                                                } label: {
                                                    Image(systemName: "minus.circle")
                                                }
                                                .buttonStyle(.plain)
                                                
                                                Text("\(viewModel.expense.installment.current)")
                                                    .multilineTextAlignment(.center)
                                                    .frame(width: 50)
                                                    .background(Color.gray.opacity(0.1))
                                                    .cornerRadius(6)
                                                
                                                Button {
                                                    if viewModel.expense.installment.current < viewModel.expense.installment.total {
                                                        viewModel.expense.installment.current += 1
                                                    }
                                                } label: {
                                                    Image(systemName: "plus.circle")
                                                }
                                                .buttonStyle(.plain)
                                            }
                                        }

                                    }
                                    
                                    if viewModel.expense.installment.total > 1 {
                                        Text(viewModel.formattedInstallmentValue)
                                            .foregroundColor(.gray)
                                            .multilineTextAlignment(.center)
                                    }
                                    
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 5)
                                .padding(.leading, 5)
                                
                            }
                            
                        }
                        .listRowBackground(Color.clear)
                        
                        // Monthly Expense
                        IconRow(icon: Image(systemName: "lock.badge.clock"), iconSize: iconSize, isTextFieldElement: false) {
                            Toggle(addStrings.fixedExpenseLabel, isOn: viewModel.monthlyBinding)
                                .frame(height: rowSize)
                                .tint(Color.redAddExpenses)
                                .background(Color.white)
                        }
                        
                        // Observations
                        IconRow(icon: Image(systemName: "note.text"), iconSize: iconSize, isTextFieldElement: true) {
                            TextField(addStrings.observationsText, text: $viewModel.expense.obs)
                                .frame(height: rowSize)
                                .multilineTextAlignment(.leading)
                        }
                        
                        Spacer(minLength: 30)
                        
                        HStack {
                            Button(action: {
                                if viewModel.expense.amount == 0 {
                                    showMissingAmountAlert = true
                                } else if viewModel.expense.desc.isEmpty {
                                    showMissingDescAlert = true
                                } else {
                                    viewModel.handleSubmit(completion: onDismiss)
                                }
                            }) {
                                Text(globalStrings.send)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: 150)
                                    .background(Color(UIColor.redGeneralExpenses!))
                                    .cornerRadius(15)
                            }
                            
                        }
                        .frame(maxWidth: .infinity)
                        .listRowSeparator(.hidden)
                        
                        Spacer(minLength: 30)
                            .listRowSeparator(.hidden)
                    }
                    .listStyle(PlainListStyle())
                    .frame(maxHeight: .infinity)
                    .scrollDismissesKeyboard(.immediately)
                    
                }
            }
        }
        .sheet(isPresented: $showCategorySheet) {
            CategoriesModalView(categories: CategoriesRepository.shared.expenses, selectedItem: $viewModel.expense.categoryIndex, showView: $showCategorySheet)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showSourcesSheet) {
            SelectSourceModalView(title: addStrings.creditCardTitle, itens: CreditCardsRepository.shared.list, showView: $showSourcesSheet) { index in
                
                viewModel.setSourceID(index: index)
                
            }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showDatePicker) {
            VStack {
                DatePicker("", selection: $viewModel.selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .labelsHidden()

                Button(addStrings.selectDateButtonTitle) {
                    showDatePicker = false
                }
                .buttonStyle(.borderedProminent)
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showInvoicesSheet) {
            SelectInvoiceModalView(date: viewModel.selectedDate, selectedItem: $viewModel.expense.month, showView: $showInvoicesSheet)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .alert(globalStrings.attention, isPresented: $showMissingAmountAlert) {
            
        } message: {
            Text(addStrings.missingAmountErrorMessage)
        }
        .alert(globalStrings.attention, isPresented: $showMissingDescAlert) {
            Button(globalStrings.cancel, role: .cancel, action: {})
            Button(globalStrings.confirm) {
                viewModel.handleSubmit(completion: onDismiss)
            }
        } message: {
            Text(addStrings.missingDescriptionErrorMessage)
        }
        .overtop(showOverTop: showInputNumber, overTopView: InputNumberOverTopView(inputText: "0", showInputNumber: $showInputNumber) { result in
            viewModel.expense.amount = Double(result) ?? 0.0
        })
    }
    
    
}

#Preview {
    
    var cardPayment = CreditCardExpense(
        desc: "Pagamento da fatura cartao Bradesco",
        amount: 100,
        categoryIndex: 0,
        date: Date().toString(),
        type: .income,
        isMonthly: false,
        paymentStatus: .paid,
        month: Date().getMonth(),
        installment: Installment(enabled: true),
        sourceId: "",
        obs: globalStrings.emptyString
    )
    
    CreditCardExpenseFormScreen(expense: cardPayment) {
        
    }
    
}

struct IconRow<Content: View>: View {
    let icon: Image
    let iconSize: CGFloat
    let isTextFieldElement: Bool
    let content: () -> Content
    var onTap: (() -> Void)?

    var body: some View {
        Group {
            if let onTap = onTap {
                Button(action: onTap) {
                    rowContent
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                }
                .buttonStyle(PlainButtonStyle())
                
            } else {
                rowContent
            }
        }
        .alignmentGuide(.listRowSeparatorLeading) { _ in -20 }
        .gesture(
            TapGesture().onEnded {
                hideKeyboard()
            },
            including: isTextFieldElement ? .none : .all
        )
    }

    private var rowContent: some View {
        HStack {
            icon
                .resizable()
                .frame(width: iconSize, height: iconSize)
                .padding(.leading, 6)
            content()
            
            Spacer()
        }
    }
}
