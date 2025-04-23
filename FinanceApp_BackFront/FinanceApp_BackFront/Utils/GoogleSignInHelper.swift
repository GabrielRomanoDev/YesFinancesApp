//
//  GoogleIntegration.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 22/04/25.
//

import UIKit

struct GoogleSignInHelper {
    static func getRootViewController() -> UIViewController {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = scene.windows.first?.rootViewController else {
            return UIViewController()
        }
        return root
    }
}

