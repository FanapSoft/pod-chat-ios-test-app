//
//  Faker.swift
//  ChatAutomationTestApp
//
//  Created by Mahyar Zhiani on 12/8/1397 AP.
//  Copyright © 1397 Mahyar Zhiani. All rights reserved.
//

import FanapPodChatSDK

class Faker {
    
    static let sharedInstance = Faker()
    
    private init() {
        
    }
    
    func generateFakeCreateThread() -> (description: String, title: String, type: String) {
        let description:    String?
        let title:          String?
        let type:           String?
        
        description = generateNameAsString(withLength: 13)
        title       = generateNameAsString(withLength: 10)
        type        = ThreadTypes.NORMAL.rawValue
        
        return (description!, title!, type!)
    }
    
    
    func generateFakeGetContactParams() -> (count: Int?, offset: Int?) {
        let count:  Int?
        let offset: Int?
        
        count   = generateNumberAsInt(from: 1, to: 50)
        offset  = generateNumberAsInt(from: 0, to: 50)
        
        return (count!, offset!)
    }
    
    
    func generateFakeAddContactParams(cellphoneLength: Int?, firstNameLength: Int?, lastNameLength: Int?) -> (cellphoneNumber: String?, email: String?, firstName: String?, lastName: String?) {
        let cellphoneNumber: String?
        let email:          String?
        let firstName:      String?
        let lastName:       String?
        
        cellphoneNumber = generateNumberAsString(withLength: cellphoneLength ?? 11)
        firstName       = generateNameAsString(withLength: firstNameLength ?? 4)
        lastName        = generateNameAsString(withLength: lastNameLength ?? 7)
        email           = generateEmailAsString(withName: "\(firstName!).\(lastName!)", withoutNameWithLength: 8)
        
        return (cellphoneNumber!, email!, firstName!, lastName!)
    }
    
    
    
    
}




extension Faker {
    
    func generateNameAsString(withLength length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return String((0...length-1).map{ _ in letters.randomElement()! })
    }
    
    func generateNumberAsString(withLength length: Int) -> String {
        let letters = "0123456789"
        return String((0...length-1).map{ _ in letters.randomElement()! })
    }
    
    func generateEmailAsString(withName: String?, withoutNameWithLength length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let atSighn = String((0...4).map{ _ in letters.randomElement()! })
        let dot     = String((0...2).map{ _ in letters.randomElement()! })
        var emailName = ""
        if let name = withName {
            emailName = name
        } else {
            emailName = String((0...length-1).map{ _ in letters.randomElement()! })
        }
        return emailName + "@" + atSighn + "." + dot
    }
    
    func generateNumberAsInt(from: Int, to: Int) -> Int {
        return Int.random(in: from ... to)
    }
    
}
