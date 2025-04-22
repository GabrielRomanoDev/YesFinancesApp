//
//  SourceButton.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 21/04/25.
//

import SwiftUI

struct SourceButton: View {
    var imageName: String
    var title: String
    var rowSize: CGFloat
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 34, height: 34)
                    .clipShape(Circle())

                Text(title)
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
