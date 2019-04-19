//
//  User.swift
//  TerpMarketplace
//
//  Created by Victoria Teng on 4/18/19.
//  Copyright © 2019 CMSC436. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var userId: String
    var fName: String
    var lName: String
    
    init(uid: String, firstName: String, lastName: String) {
        self.userId = uid;
        self.fName = firstName;
        self.lName = lastName;
    }
}
