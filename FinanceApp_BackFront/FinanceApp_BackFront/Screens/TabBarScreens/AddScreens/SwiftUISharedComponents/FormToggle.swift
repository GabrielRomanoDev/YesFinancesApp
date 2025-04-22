//
//  MonthlyToggle.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 21/04/25.
//

import SwiftUI

struct FormToggle: View {
    var label: String
    @Binding var isOn: Bool
    var iconSize: CGFloat
    var rowSize: CGFloat
    var switchColor: Color

    var body: some View {
        IconRow(icon: Image(systemName: "lock.badge.clock"), iconSize: iconSize, isTextFieldElement: false) {
            Toggle(label, isOn: $isOn)
                .frame(height: rowSize)
                .tint(switchColor)
                .background(Color.white)
        }
    }
}
