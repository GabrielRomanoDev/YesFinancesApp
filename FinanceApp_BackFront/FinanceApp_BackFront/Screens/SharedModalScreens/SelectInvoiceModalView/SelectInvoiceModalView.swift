//
//  SelectInvoiceModalView.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 12/04/25.
//

import SwiftUI

struct SelectInvoiceModalView: View {
    
    @Binding var selectedItem: MonthDate
    @Binding var showView: Bool
    var date: Date
    var months: [MonthDate]
    
    init(date: Date, selectedItem: Binding<MonthDate>, showView: Binding<Bool>) {
        
        self.months = []
        self.date = date
        self._selectedItem = selectedItem
        self._showView = showView
        
        var month = date.getMonth()
        month.lastMonth()
        
        for _ in 1...10 {
            months.append(month)
            month.nextMonth()
        }
        
    }
    
    var body: some View {
        
        VStack {
            
            Text("Selecionar fatura")
                .padding(.top)
            
            List (months, id: \.self) { month in
                
                Button {
                    selectedItem = month
                    showView = false
                } label: {
                    HStack {
                        
                        Text("Fatura de \(monthsText[month.month] ?? globalStrings.january)\(month.year > date.getMonth().year ? " de \(month.year)" : "")")
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Image("chevron-left")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        
                    }
                }
                .frame(height: 40)
                
            }
            .listStyle(PlainListStyle())
            .frame(maxHeight: .infinity)
        }
        .padding(.top)
    }
    
}

