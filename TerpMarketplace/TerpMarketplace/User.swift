//
//  User.swift
//  TerpMarketplace
//
//  Created by Victoria Teng on 4/18/19.
//  Copyright © 2019 CMSC436. All rights reserved.
//

import UIKit
import Firebase

class User {
    
    var userId: String!
    var fName: String!
    var lName: String!
    var itemIds: [String]
    var ref: DatabaseReference!
    
    init(snapshot: DataSnapshot) {
        let data = snapshot.value as! Dictionary<String, AnyObject>
        var items: Dictionary<String, AnyObject>
        itemIds = []
        
        items = data["likes"] as? Dictionary<String, AnyObject> ?? [:]
        for k in items.keys {
            itemIds.append(k)
        }
        
        ref = snapshot.ref;
    }
}
