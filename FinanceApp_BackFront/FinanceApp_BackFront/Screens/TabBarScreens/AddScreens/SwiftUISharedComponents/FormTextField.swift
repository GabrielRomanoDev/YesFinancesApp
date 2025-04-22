//
//  DescriptionField.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 21/04/25.
//

import SwiftUI

struct FormTextField: View {
    var image: Image
    @Binding var text: String
    var placeholder: String
    var iconSize: CGFloat
    var rowSize: CGFloat

    var body: some View {
        IconRow(icon: image, iconSize: iconSize, isTextFieldElement: true) {
            TextField(placeholder, text: $text)
                .frame(height: rowSize)
        }
    }
}
