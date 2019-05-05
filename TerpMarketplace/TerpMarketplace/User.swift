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
    var email: String!
    var itemIds: [String]       // itemIds of items that user likes
    var sellingItemIds: [String]
    var profileImageUrl: String!
    var ref: DatabaseReference!
    
    init(snapshot: DataSnapshot) {
        let data = snapshot.value as! Dictionary<String, AnyObject>
        var items: Dictionary<String, AnyObject>
        itemIds = []
        sellingItemIds = []
        
        items = data["likes"] as? Dictionary<String, AnyObject> ?? [:]
        for k in items.keys {
            itemIds.append(k)
        }
        
        items = data["selling"] as? Dictionary<String, AnyObject> ?? [:]
        for k in items.keys {
            sellingItemIds.append(k)
        }
        
        fName = data["fisrtname"] as? String
        lName = data["lastname"] as? String
        
        profileImageUrl = data["photoUrl"] as? String
        
        email = data["username"] as? String
        
        ref = snapshot.ref;
    }
}
