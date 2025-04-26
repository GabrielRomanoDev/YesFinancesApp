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
    
    @Binding var isPresented: Bool
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

    init(expense: CreditCardExpense? = nil, isPresented: Binding<Bool>, onDismiss: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: RegisterCardExpViewModel(expense: expense))
        self._isPresented = isPresented
        self.onDismiss = onDismiss
    }

    var body: some View {
        NavigationStack {
            ZStack {
                
                VStack(spacing: 0) {
                    Text(addStrings.creditCardExpenseRegisterTitle)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 40)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(UIColor.redGeneralExpenses!))

                    List {
                        
                        FormTextField(image: Image("image46"), text: $viewModel.expense.desc, placeholder: addStrings.descriptionPlaceholder, iconSize: iconSize, rowSize: rowSize)
                        
                        FormTapDisplay(image: Image(systemName: "dollarsign.circle"), labelText: "\(viewModel.expense.amount.toStringMoney())", iconSize: iconSize, rowSize: rowSize, onTap: {
                            hideKeyboard()
                            showInputNumber = true
                        })
                        
                        FormTapDisplay(image: Image(systemName: "calendar"), labelText: "\(viewModel.selectedDate.dateWrittenString())", iconSize: iconSize, rowSize: rowSize, onTap: {
                            hideKeyboard()
                            showDatePicker = true
                        })

                        CategoryButton(category: CategoriesRepository.shared.expenses[viewModel.expense.categoryIndex], rowSize: rowSize, onTap: {
                            showCategorySheet = true
                            hideKeyboard()
                        })

                        SourceButton(imageName: bankProperties[CreditCardsRepository.shared.list[viewModel.cardIndex].bank]?.imageName ?? "BancoItau", title: CreditCardsRepository.shared.list[viewModel.cardIndex].desc, rowSize: rowSize, onTap: {
                            showSourcesSheet = true
                                        hideKeyboard()
                        })
                        
                        invoiceConfiguration
                        
                        installmentConfiguration
                        
                        FormToggle(label: addStrings.fixedExpenseLabel, isOn: viewModel.monthlyBinding, iconSize: iconSize, rowSize: rowSize, switchColor: Color.redAddExpenses)
                        
                        FormTextField(image: Image(systemName: "note.text"), text: $viewModel.expense.obs, placeholder: addStrings.observationsText, iconSize: iconSize, rowSize: rowSize)
                        
                        Spacer(minLength: 30)
                        
                        HStack {
                            Button(action: {
                                if viewModel.expense.amount == 0 {
                                    showMissingAmountAlert = true
                                } else if viewModel.expense.desc.isEmpty {
                                    showMissingDescAlert = true
                                } else {
                                    viewModel.handleSubmit() {
                                        isPresented = false
                                        onDismiss()
                                    }
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
            SelectSourceModalView(title: addStrings.creditCardsTitle, itens: CreditCardsRepository.shared.list, showView: $showSourcesSheet) { index in
                
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
            viewModel.expense.amount = -(Double(result) ?? 0.0)
        })
    }
    
    private var invoiceConfiguration : some View {
        
        IconRow(icon: Image("image54"), iconSize: iconSize, isTextFieldElement: false, onTap: {
            hideKeyboard()
            showInvoicesSheet = true
        }) {
            Text("\(addStrings.invoiceOf) \(monthsText[viewModel.expense.month.month] ?? globalStrings.january)")
                .frame(height: rowSize)
        }
        
    }
    
    private var installmentConfiguration : some View {
        
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
                                    if viewModel.expense.installment.total < 48 {
                                        viewModel.expense.installment.total += 1
                                    }
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
    
    CreditCardExpenseFormScreen(expense: cardPayment, isPresented: .constant(true)) {
        
    }
    
}
