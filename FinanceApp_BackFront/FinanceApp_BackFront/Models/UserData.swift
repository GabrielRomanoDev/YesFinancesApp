//
//  Profile.swift
//  FinanceApp_BackFront
//
//  Created by Gabriel Luz Romano on 06/07/23.
//

import Foundation

struct UserDataDTO: FirestoreObject {
    let id: String
    var email: String
    var name: String?
    var phoneNumber: PhoneNumberData?
    var photoURL: URL?
    var registered: Bool
    
    init(id: String, email: String, name: String? = nil, phoneNumber: PhoneNumberData? = nil, photoURL: URL? = nil, userRegistered: Bool = true) {
        self.id = id
        self.email = email
        self.name = name
        self.phoneNumber = phoneNumber
        self.registered = userRegistered
    }
}

struct UserData: FirestoreObject {
    let id: String
    var name: String
    var email: String
    var phoneNumber: PhoneNumberData?
    var photoURL: URL?
    var infoValidated: Bool
    
    init(id: String, name: String, email: String, phoneNumber: PhoneNumberData? = nil, photoURL: URL? = nil, infoValidated: Bool = false) {
        self.id = id
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
        self.infoValidated = infoValidated
    }
}



struct PhoneNumberData: Codable {
    let nationalCode: String
    let zoneCode: String
    let number: String
    
    init(nationalCode: String = "+55", zoneCode: String, number: String) {
        self.nationalCode = nationalCode
        self.zoneCode = zoneCode
        self.number = number
    }
    
    init?(formattedString: String, nationalCode: String = "+55") {
        let digits = formattedString.filter { $0.isNumber }
        
        guard digits.count >= 10 else { return nil }
        
        let zoneCode = String(digits.prefix(2))
        
        let number = String(digits.dropFirst(2))
        
        self.nationalCode = nationalCode
        self.zoneCode = zoneCode
        self.number = number
    }
    
    var formatedE164: String {
        return "\(nationalCode)\(zoneCode)\(number)"
    }
    
    var  formatedLocal: String {
        return "(\(zoneCode)) \(number.count == 9 ? number.prefix(5) : number.prefix(4))-\(number.suffix(4))"
    }
}
