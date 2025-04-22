//
//  SelectSourceModalView.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 12/04/25.
//

import SwiftUI

struct SelectSourceModalView: View {
    var title: String
    @State var itens: [TransactionSource]
    @Binding var showView: Bool
    
    var onDismiss: ((Int) -> Void)
    
    var body: some View {
        
        VStack {
            
            Text(title)
                .padding()
            
            List (itens.indices, id: \.self) { index in
                
                Button {
                    onDismiss(index)
                    showView = false
                } label: {
                    HStack {
                            
                        Image(bankProperties[itens[index].bank]?.imageName ?? "BancoItau")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36, height: 36)
                            .cornerRadius(8)
                        
                        Text(itens[index].desc)
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .truncationMode(.tail)
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

