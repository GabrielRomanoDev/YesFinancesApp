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
    
    private var service: FirestoreService = FirestoreService(subCollectionName: firebaseSubCollectionNames.goals)
    private var goalsList: [Goal] = []
    
    public func updateGoals(completion: @escaping () -> Void) {
        service.getObjectsList(forObjectType: Goal.self, documentReadName: firebaseSubCollectionNames.goals) { result in
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
        
        service.addObject(newGoal, id: newGoal.getId) { [weak self] result in
            if result != "Success" {
                print(result)
                completion()
            }
            self?.goalsList.append(newGoal)
            completion()
        }
        
    }
    
    public func editGoal(goal: Goal, indexGoal: Int, completion: @escaping () -> Void) {
        
        service.updateObject(goal, id: goalsList[indexGoal].getId) { [weak self] result in
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
        
        service.deleteObject(id: goalsList[index].getId) { [weak self] result in
            if result != "Success" {
                print(result)
                completion()
                return
            }
            self?.goalsList.remove(at: index)
            completion()
        }
    }
    
    public func saveMoney(value: Double, goalIndex: Int, completion: @escaping () -> Void) {
        
        var editedGoal = goalsList[goalIndex]
        editedGoal.savedAmount += value
        
        editGoal(goal: editedGoal, indexGoal: goalIndex, completion: completion)
    }
}
