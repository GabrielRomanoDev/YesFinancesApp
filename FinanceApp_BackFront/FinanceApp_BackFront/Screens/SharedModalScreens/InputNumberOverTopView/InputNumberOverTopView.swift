//
//  InputNumberOverTopView.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 12/04/25.
//

import SwiftUI

struct InputNumberOverTopView: View {

    @State private var inputText: String
    @Binding var showInputNumber: Bool
    var onComplete: (String) -> Void
    
    init(inputText: String, showInputNumber: Binding<Bool>, onComplete: @escaping (String) -> Void) {
        self.inputText = inputText
        self._showInputNumber = showInputNumber
        self.onComplete = onComplete
    }

    let buttonLabels: [[String]] = [
        ["7", "8", "9", "/"],
        ["4", "5", "6", "x"],
        ["1", "2", "3", "-"],
        [".", "0", "=", "+"]
    ]

    var body: some View {
        ZStack {
            // Fundo escurecido
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            // Conteúdo central
            VStack(spacing: 16) {
                // Campo de texto com backspace
                HStack {
                    Text(inputText)
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    Button(action: {
                        if !inputText.isEmpty {
                            inputText.removeLast()
                            
                            if inputText == "" { inputText = "0" }
                        }
                    }) {
                        Image(systemName: "delete.left")
                            .foregroundColor(.black)
                            .frame(width: 30, height: 30)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                
                // Grade de botões
                VStack(spacing: 8) {
                    ForEach(buttonLabels, id: \.self) { row in
                        HStack(spacing: 8) {
                            ForEach(row, id: \.self) { label in
                                Button(action: {
                                    handleInput(label)
                                }) {
                                    Text(label)
                                        .frame(maxWidth: .infinity, minHeight: 44)
                                        .background(Color.white)
                                        .foregroundColor(.black)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                
                // Botões cancelar e finalizar
                HStack {
                    Button("Cancelar") {
                        showInputNumber = false
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(8)
                    
                    Button("Finalizar") {
                        handleInput("=")
                        onComplete(inputText)
                        showInputNumber = false
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(16)
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .background(Color.clear)
    }

    private func handleInput(_ value: String) {
        if value == "=" {
            calculateResult()
        } else if ["+", "-", "x", "/"].contains(value) {
            if let last = inputText.last, "+-x/".contains(last) {
                inputText.removeLast()
            }
            inputText.append(value)
        } else {
            if inputText == "0" { inputText = "" }
            inputText.append(value)
        }
    }

    private func calculateResult() {
        var expression = inputText.replacingOccurrences(of: "x", with: "*")

        // Remove operador final, se houver
        if let last = expression.last, "+-*/".contains(last) {
            expression.removeLast()
        }

        let expr = NSExpression(format: expression)
        if let result = expr.expressionValue(with: nil, context: nil) as? NSNumber {
            inputText = result.stringValue
        }
    }
}
