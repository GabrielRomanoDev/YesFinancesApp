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
    
    func updateGoals(completion: @escaping () -> Void) {
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
    
    func getGoalsCount() -> Int {
        return goalsList.count 
    }
    
    func getItemGoal(_ index:Int) -> Goal {
        return goalsList[index]
    }
    
    func getCellSize(viewWidth:CGFloat) -> CGSize {
        return CGSize (width: viewWidth - 50, height: 124)
    }
    
    func createNewGoal(_ newGoal: Goal, completion: @escaping () -> Void) {
        
        service.setObject(newGoal) { [weak self] result in
            if result != "Success" {
                print(result)
                completion()
            }
            self?.goalsList.append(newGoal)
            completion()
        }
        
    }
    
    func editGoal(goal: Goal, indexGoal: Int, completion: @escaping () -> Void) {
        
        service.setObject(goal) { [weak self] result in
            if result != "Success" {
                print(result)
                completion()
                return
            }
            self?.goalsList[indexGoal] = goal
            completion()
        }
        
    }
    
    func deleteGoal(index: Int, completion: @escaping () -> Void) {
        
        service.deleteObject(id: goalsList[index].id) { [weak self] result in
            if result != "Success" {
                print(result)
                completion()
                return
            }
            self?.goalsList.remove(at: index)
            completion()
        }
    }
    
    func saveMoney(value: Double, goalIndex: Int, completion: @escaping () -> Void) {
        
        var editedGoal = goalsList[goalIndex]
        editedGoal.savedAmount += value
        
        editGoal(goal: editedGoal, indexGoal: goalIndex, completion: completion)
    }
}
