//
//  CategoryButton.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 21/04/25.
//

import SwiftUI

struct CategoryButton: View {
    var category: TransactionCategory
    var rowSize: CGFloat
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color(categoryColors[category.colorIndex]!))
                        .frame(width: 34, height: 34)
                    Image(category.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                }
                Text(category.name)
                    .foregroundColor(.black)
            }
            .frame(height: rowSize)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
        }
        .buttonStyle(.plain)
        .alignmentGuide(.listRowSeparatorLeading) { _ in return -20 }
    }
}

