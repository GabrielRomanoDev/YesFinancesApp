//
//  IconRow.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 21/04/25.
//

import SwiftUI

struct IconRow<Content: View>: View {
    let icon: Image
    let iconSize: CGFloat
    let isTextFieldElement: Bool
    var onTap: (() -> Void)?
    @ViewBuilder let content: () -> Content
    

    var body: some View {
        Group {
            if let onTap = onTap {
                Button(action: onTap) {
                    rowContent
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                }
                .buttonStyle(PlainButtonStyle())
                
            } else {
                rowContent
            }
        }
        .alignmentGuide(.listRowSeparatorLeading) { _ in -20 }
        .gesture(
            TapGesture().onEnded {
                hideKeyboard()
            },
            including: isTextFieldElement ? .none : .all
        )
    }

    private var rowContent: some View {
        HStack {
            icon
                .resizable()
                .frame(width: iconSize, height: iconSize)
                .padding(.leading, 6)
            content()
            
            Spacer()
        }
    }
}
