//
//  CategoriesModalView.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 12/04/25.
//

import SwiftUI

struct CategoriesModalView: View {
    @State var categories: [TransactionCategory]
    @Binding var selectedItem: Int
    @Binding var showView: Bool
    
    var body: some View {
        
        VStack {
            
            Text("Categorias")
                .padding(.top)
            
            List (categories.indices, id: \.self) { index in
                
                Button {
                    selectedItem = index
                    showView = false
                } label: {
                    HStack {
                        
                        ZStack {
                            
                            Circle()
                                .fill(Color(categoryColors[categories[index].colorIndex]!))
                                .frame(width: 36, height: 36)
                            Image(categories[index].imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                        }
                        
                        Text(categories[index].name)
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

