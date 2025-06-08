//
//  AddTransactionButton.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 22/04/25.
//

import SwiftUI

struct AddTransactionButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus.circle.fill")
                .resizable()
                .frame(width: 45, height: 45)
                .foregroundColor(.blue)
        }
    }
}
