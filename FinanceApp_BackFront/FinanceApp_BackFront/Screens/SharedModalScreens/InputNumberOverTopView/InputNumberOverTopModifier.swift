//
//  InputNumberOverTopModifier.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 12/04/25.
//

import SwiftUI

struct InputNumberOverTopModifier: ViewModifier {
    let showOverTop: Bool
    let overTopView: InputNumberOverTopView
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if showOverTop {
                overTopView
                    .zIndex(1)
            }
        }
    }
}
