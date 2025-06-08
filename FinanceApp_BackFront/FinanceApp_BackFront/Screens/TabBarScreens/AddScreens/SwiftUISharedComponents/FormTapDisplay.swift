//
//  AmountDisplay.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 21/04/25.
//

import SwiftUI

struct FormTapDisplay: View {
    var image: Image
    var labelText: String
    var iconSize: CGFloat
    var rowSize: CGFloat
    var isBlocked: Bool = false
    var onTap: () -> Void

    var body: some View {
        IconRow(icon: image, iconSize: iconSize, isTextFieldElement: false, onTap: !isBlocked ? onTap : nil) {
            Text(labelText)
                .frame(height: rowSize)
        }
    }
}
