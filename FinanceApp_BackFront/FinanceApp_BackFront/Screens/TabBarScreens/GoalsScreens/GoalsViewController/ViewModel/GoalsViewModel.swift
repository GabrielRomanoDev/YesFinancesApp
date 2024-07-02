//
//  GoalsViewModel.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 28/05/23.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class GoalsViewModel {
    
    private var service: FirestoreService = FirestoreService(documentName: firebaseDocumentNames.goals)
    private var goalsList: [Goal] = []
    
    public func updateGoals(completion: @escaping () -> Void) {
        service.getObjectsArrayData(forObjectType: Goal.self, documentReadName: firebaseDocumentNames.goals) { result in
            switch result {
            case .success(let objectsArray):
                self.goalsList = objectsArray
            case .failure(let error):
                print(error.localizedDescription)
            }
            completion()
        }
    }
    
    public func getGoalsCount() -> Int {
        return goalsList.count 
    }
    
    public func getItemGoal(_ index:Int) -> Goal {
        return goalsList[index]
    }
    
    public func getCellSize(viewWidth:CGFloat) -> CGSize {
        return CGSize (width: viewWidth - 50, height: 124)
    }
    
    public func createNewGoal(_ newGoal: Goal, completion: @escaping () -> Void) {
        goalsList.append(newGoal)
        service.setArrayObject(goalsList) { result in
            if result != "Success" {
                print(result)
            }
            completion()
        }
    }
    
    public func editGoal(goal: Goal, indexGoal: Int, completion: @escaping () -> Void) {
        
        service.updateObjectInArray(goal, original: goalsList[indexGoal]) { [weak self] result in
            if result != "Success" {
                print(result)
                completion()
                return
            }
            self?.goalsList[indexGoal] = goal
            completion()
        }
        
    }
    
    public func deleteGoal(index: Int, completion: @escaping () -> Void) {
        goalsList.remove(at: index)
        service.setArrayObject(goalsList) { [weak self] result in
            if result != "Success" {
                print(result)
                completion()
                return
            }
            self?.updateGoals(completion: completion)
        }
    }
    
    public func saveMoney(value: Double, goalIndex: Int, completion: @escaping () -> Void) {
        
        var editedGoal = goalsList[goalIndex]
        editedGoal.savedAmount += value
        
        editGoal(goal: editedGoal, indexGoal: goalIndex, completion: completion)
    }
}
