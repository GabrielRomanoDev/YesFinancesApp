//
//  NewGoalScreen.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 26/04/23.
//

import UIKit

protocol CreatedNewGoalDelegate{
    func didCreatedGoal()
}

class NewGoalScreen: UIViewController {
    
    var delegate:CreatedNewGoalDelegate?
    var viewModel:NewGoalViewModel=NewGoalViewModel()

    @IBOutlet weak var descLabel: UITextField!
    
    @IBOutlet weak var initialAmountLabel: UITextField!
    
    @IBOutlet weak var targetValueLabel: UITextField!
    
    @IBOutlet weak var tagetDateLabel: UITextField!
    
    @IBOutlet weak var goalImage: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    @IBAction func tappedChangeImageButton(_ sender: UIButton) {
        //função de escolha de imagens será criada assim que o conjunto de imagens for definido
    }
    
    @IBAction func tappedCreateGoalButton(_ sender: UIButton) {
        if isMissingInformation() == false {
            viewModel.createNewGoal(desc: descLabel.text!, imageName: "Casa", savedAmount: Double(initialAmountLabel.text!)!, goalValue: Double(targetValueLabel.text!)!, targetDate: tagetDateLabel.text!)
            delegate?.didCreatedGoal()
            dismiss(animated: true)
        }
    }
    
    func isMissingInformation() -> Bool {
        var missing = false
        
        if viewModel.newGoal.stringIsEmpty(text: descLabel.text ?? "") {
            descLabel.layer.borderColor = UIColor.red.cgColor
            missing = true
        }
        
        if viewModel.newGoal.stringIsEmpty(text: initialAmountLabel.text ?? "") {
            initialAmountLabel.layer.borderColor = UIColor.red.cgColor
            missing = true
        }
        
        if viewModel.newGoal.stringIsEmpty(text: targetValueLabel.text ?? "") {
            targetValueLabel.layer.borderColor = UIColor.red.cgColor
            missing = true
        }
        
        if viewModel.newGoal.stringIsEmpty(text: tagetDateLabel.text ?? "") {
            tagetDateLabel.layer.borderColor = UIColor.red.cgColor
            missing = true
        }
        
        if missing == true {
            return true
        } else {
            return false
        }
    }
    

}
