//
//  GoogleIntegration.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 22/04/25.
//

import UIKit

struct ApplicationViewControllerResolver {
    static func getKeyWindow() -> UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first(where: { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive })?
            .windows
            .first(where: { $0.isKeyWindow })
    }

    static func getTopViewController() -> UIViewController? {
        guard let rootViewController = getKeyWindow()?.rootViewController else {
            return nil
        }

        return topViewController(from: rootViewController)
    }

    static func getRootNavigationController() -> UINavigationController? {
        if let navigationController = getKeyWindow()?.rootViewController as? UINavigationController {
            return navigationController
        }

        return nil
    }

    private static func topViewController(from viewController: UIViewController) -> UIViewController {
        if let presentedViewController = viewController.presentedViewController {
            return topViewController(from: presentedViewController)
        }

        if let navigationController = viewController as? UINavigationController,
           let visibleViewController = navigationController.visibleViewController {
            return topViewController(from: visibleViewController)
        }

        if let tabBarController = viewController as? UITabBarController,
           let selectedViewController = tabBarController.selectedViewController {
            return topViewController(from: selectedViewController)
        }

        return viewController
    }
}
