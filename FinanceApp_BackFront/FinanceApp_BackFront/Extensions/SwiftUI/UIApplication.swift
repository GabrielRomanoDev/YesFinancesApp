//
//  UIApplication.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 24/09/25.
//

import SwiftUI

extension UIApplication {
    
    static var rootTabBarController: UITabBarController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }
        
        var root = window.rootViewController
        
        // percorre a cadeia de presentedViewController até achar o último
        while let presented = root?.presentedViewController {
            root = presented
            
            // tenta converter direto
            if let tab = root as? UITabBarController {
                return tab
            }
            
            // ou se for navigation, procura nos filhos
            if let nav = root as? UINavigationController {
                return nav.viewControllers.first { $0 is UITabBarController } as? UITabBarController
            }
        }
        
        return nil
    }
    
    static func rootTabBarController2() -> UITabBarController? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?.rootViewController as? UITabBarController
    }
}
