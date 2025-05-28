//
//  TransactionFormScreen.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 21/04/25.
//

import SwiftUI
import UIKit
import Foundation

struct TransactionFormScreen: View {
    
    @Binding var isPresented: Bool
    @StateObject private var viewModel: TransactionFormViewModel
    @State private var showCategorySheet = false
    @State private var showInputNumber = false
    @State private var showDatePicker = false
    @State private var showSourcesSheet = false
    @State private var showMissingAmountAlert = false
    @State private var showMissingDescAlert = false
    
    var onDismiss: (() -> Void)

    let iconSize: CGFloat = 22
    let rowSize: CGFloat = 40

    init(transaction: AccountTransaction? = nil, type: TransactionType, isInvoicePayment: Bool = false, isPresented: Binding<Bool>, onDismiss: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: TransactionFormViewModel(transaction: transaction, isInvoicePayment: isInvoicePayment, type: type))
        self._isPresented = isPresented
        self.onDismiss = onDismiss
    }

    var body: some View {
        NavigationStack {
            ZStack {
                
                VStack(spacing: 0) {
                    Text(viewModel.screenTitle())
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 40)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.screenTitleBackgroundColor())

                    List {
                        
                        FormTextField(image: Image("image46"), text: $viewModel.transaction.desc, placeholder: addStrings.descriptionPlaceholder, iconSize: iconSize, rowSize: rowSize)
                        
                        FormTapDisplay(image: Image(systemName: "dollarsign.circle"), labelText: "\(abs(viewModel.transaction.amount).toStringMoney())", iconSize: iconSize, rowSize: rowSize, blocked: viewModel.isInvoicePayment, onTap: {
                            hideKeyboard()
                            showInputNumber = true
                        })
                        
                        FormTapDisplay(image: Image(systemName: "calendar"), labelText: "\(viewModel.selectedDate.dateWrittenString())", iconSize: iconSize, rowSize: rowSize, onTap: {
                            hideKeyboard()
                            showDatePicker = true
                        })

                        CategoryButton(category: viewModel.selectedCategory(), rowSize: rowSize, onTap: {
                            showCategorySheet = true
                            hideKeyboard()
                        })

                        SourceButton(imageName: bankProperties[BankAccountsRepository.shared.list[viewModel.sourceIndex].bank]?.imageName ?? "BancoItau", title: BankAccountsRepository.shared.list[viewModel.sourceIndex].desc, rowSize: rowSize, onTap: {
                            showSourcesSheet = true
                                        hideKeyboard()
                        })
                        
                        if !viewModel.isInvoicePayment {
                            FormToggle(label: addStrings.fixedExpenseLabel, isOn: $viewModel.transaction.isMonthly, iconSize: iconSize, rowSize: rowSize, switchColor: viewModel.screenTitleBackgroundColor())
                        }
                        
                        FormTextField(image: Image(systemName: "note.text"), text: $viewModel.transaction.obs, placeholder: addStrings.observationsText, iconSize: iconSize, rowSize: rowSize)
                        
                        Spacer(minLength: 30)
                        
                        HStack {
                            Button(action: {
                                
                                if viewModel.transaction.amount == 0 {
                                    showMissingAmountAlert = true
                                } else if viewModel.transaction.desc.isEmpty {
                                    showMissingDescAlert = true
                                } else {
                                    viewModel.saveExpense() {
                                        isPresented = false
                                        onDismiss()
                                    }
                                }
                                
                            }) {
                                Text(viewModel.isEditing ? globalStrings.save : globalStrings.send)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: 150)
                                    .background(viewModel.screenTitleBackgroundColor())
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
            CategoriesModalView(categories: viewModel.categories(), selectedItem: $viewModel.transaction.categoryIndex, showView: $showCategorySheet)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showSourcesSheet) {
            SelectSourceModalView(title: addStrings.bankAccountsTitle, itens: BankAccountsRepository.shared.list, showView: $showSourcesSheet) { index in
                
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
        .alert(globalStrings.attention, isPresented: $showMissingAmountAlert) {
            
        } message: {
            Text(addStrings.missingAmountErrorMessage)
        }
        .alert(globalStrings.attention, isPresented: $showMissingDescAlert) {
            Button(globalStrings.cancel, role: .cancel, action: {})
            Button(globalStrings.confirm) {
                viewModel.saveExpense() {
                    isPresented = false
                    onDismiss()
                }
            }
        } message: {
            Text(addStrings.missingDescriptionErrorMessage)
        }
        .overtop(showOverTop: showInputNumber, overTopView: InputNumberOverTopView(inputText: "0", showInputNumber: $showInputNumber) { result in
            viewModel.transaction.amount = viewModel.transaction.type == .income ?  Double(result) ?? 0.0 : -(Double(result) ?? 0.0)
        })
    }
    
}

#Preview {
    
    var expense = AccountTransaction(
        desc: "Gasto",
        amount: 100,
        categoryIndex: 0,
        date: Date().toString(),
        type: .income,
        isMonthly: false,
        sourceId: "",
        obs: globalStrings.emptyString
    )
    
    TransactionFormScreen(transaction: expense, type: .expense, isPresented: .constant(true)) {
        
    }
    
}
