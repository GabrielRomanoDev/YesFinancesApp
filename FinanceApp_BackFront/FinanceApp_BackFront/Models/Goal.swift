//
//  Goal.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 25/04/23.
//

import Foundation

struct Goal: FirestoreObject, Equatable {
    
    private(set) var id: String = UUID().uuidString
    var desc: String
    var imageName: String
    var savedAmount: Double
    var goalValue: Double
    var targetDate: String
    
    public var daysToDate: Int {
        let formatter = DateFormatter()
        formatter.dateFormat = globalStrings.dateFormat
        let targetDate = formatter.date(from: targetDate)

        let today = Date()
        let calendar = Calendar.current

        let components = calendar.dateComponents([.day], from: today, to: targetDate!)
        let days = components.day!
        
        return days
    }
    
    public var remainingAmount: Double {
        return goalValue - savedAmount
    }
    
    init(desc: String, imageName: String, savedAmount: Double, goalValue: Double, targetDate: String) {
        self.desc = desc
        self.imageName = imageName
        self.savedAmount = savedAmount
        self.goalValue = goalValue
        self.targetDate = targetDate
    }
    
}
