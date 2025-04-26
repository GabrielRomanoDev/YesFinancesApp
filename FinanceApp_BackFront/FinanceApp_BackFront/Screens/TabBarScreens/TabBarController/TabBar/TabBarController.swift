//
//  ViewController.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 11/04/23.
//

import UIKit
import SwiftUI

class TabBarController: UITabBarController {
    
    static let identifier:String = String(describing: TabBarController.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupItems()
        setupAddButton()
    }
    
    private func setupItems() {
        guard let items = tabBar.items else { return }
        items[0].title = tabBarStrings.homeScreenTitle
        items[1].title = tabBarStrings.transactionsScreenTitle
        items[3].title = tabBarStrings.goalsScreenTitle
        items[4].title = tabBarStrings.moreScreenTitle
        
    }
    
    private func setupAddButton() {
        let addButton = AddTransactionButton {
            let vc = UIHostingController(rootView: AddTransactionView())
            vc.modalPresentationStyle = .overFullScreen
            vc.view.backgroundColor = .clear
            self.present(vc, animated: false)
        }
        
        let hostingController = UIHostingController(rootView: addButton)
        hostingController.view.backgroundColor = .clear
        hostingController.view.frame = CGRect(x: self.view.frame.width / 2 - 35,
                                              y: self.view.frame.height - 100,
                                              width: 70, height: 70)
        self.view.addSubview(hostingController.view)
        self.addChild(hostingController)
    }
    
}
