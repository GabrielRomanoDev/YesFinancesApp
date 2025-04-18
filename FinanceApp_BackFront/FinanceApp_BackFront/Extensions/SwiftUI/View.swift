//
//  View.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 12/04/25.
//

import SwiftUI

extension View {
    func overtop(showOverTop: Bool, overTopView: InputNumberOverTopView) -> some View {
        modifier(InputNumberOverTopModifier(showOverTop: showOverTop, overTopView: overTopView))
    }
}
