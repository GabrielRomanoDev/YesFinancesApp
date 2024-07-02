//
//  GoalInfoScreen.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 26/04/23.
//

import UIKit

protocol GoalInfoViewControllerProtocol: AnyObject {
    func didDeletedGoal(index: Int)
    func didSavedMoney(_ value: Double, index: Int)
}

class GoalInfoViewController: UIViewController {
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var goalImage: UIImageView!
    @IBOutlet weak var goalProgressBar: UIProgressView!
    @IBOutlet weak var savedAmountLabel: UILabel!
    @IBOutlet weak var targetValueLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var daysToDateLabel: UILabel!
    @IBOutlet weak var recommendationLabel: UILabel!
    @IBOutlet weak var saveAmountButton: UIButton!
    
    static let identifier:String = String(describing: GoalInfoViewController.self)

    weak var delegate: GoalInfoViewControllerProtocol?
    var goal: Goal
    var index: Int
    
    init?(coder: NSCoder, goal: Goal, index: Int){
        self.goal = goal
        self.index = index
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError(globalStrings.initError)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStrings()
        setupScreen(goal: goal)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
    }

    @IBAction func tappedDeleteButton(_ sender: UIButton) {
        delegate?.didDeletedGoal(index: self.index)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tappedSaveMoney(_ sender: UIButton) {
        
            let storyboard = UIStoryboard(name: InsertNumbersModalViewController.identifier, bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: InsertNumbersModalViewController.identifier) {coder ->
                InsertNumbersModalViewController? in
                return InsertNumbersModalViewController(coder: coder)
            }
            vc.delegate = self
            self.present(vc, animated: true)
        
    }
    
    private func setupStrings() {
        goalLabel.text = goalStrings.goalText
        saveAmountButton.setTitle(goalStrings.saveAmountButtonTitle, for: .normal)
    }
    
    private func setupScreen(goal: Goal){
        descLabel.text = goal.desc
        goalImage.image = UIImage(imageLiteralResourceName: goal.imageName)
        setSavedAmountValue(goal.savedAmount)
        targetValueLabel.text = goal.goalValue.toStringMoney()
        dateLabel.text = goalStrings.targetDateToGoalText + goal.targetDate
        daysToDateLabel.text = goalStrings.DaysToTargetDate(goal: goal)
        let deleteImage = UIImage(systemName: "trash")?.withRenderingMode(.alwaysTemplate)
        deleteButton.setImage(deleteImage, for: .normal)
        deleteButton.tintColor = .red
    }
    
    private func setSavedAmountValue(_ value: Double) {
        goalProgressBar.progress = Float(value/goal.goalValue)
        savedAmountLabel.text = value.toStringMoney()
        
        var goalUpdated = goal
        goalUpdated.savedAmount = value
        recommendationLabel.text = goalStrings.recommendingText(goal: goalUpdated)
    }
    
    
}

extension GoalInfoViewController: InsertNumbersModalProtocol {
    
    func didSelectedNumber(_ value: Double, id: Int) {
        goal.savedAmount += value
        setSavedAmountValue(goal.savedAmount)
        delegate?.didSavedMoney(value, index: id)
    }
    
}
