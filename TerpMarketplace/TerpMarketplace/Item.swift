//
//  Item.swift
//  TerpMarketplace
//
//  Created by Victoria Teng on 4/18/19.
//  Copyright © 2019 CMSC436. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation

class Item {
    
    var sellerId: String!
    var itemId: String!
    var name: String!
    var price: Int!
    var details: String!
    var forSale: Bool!       // false if sold
    var location: String!
    var ref: DatabaseReference
    var imageUrl: String!
    
    init(snapshot: DataSnapshot) {
        let data = snapshot.value as! Dictionary<String, AnyObject>
        
        name = data["name"] as? String
        price = data["price"]?.integerValue ?? 0
        details = data["details"] as? String
        forSale = data["forSale"] as? Bool
        sellerId = data["sellerId"] as? String
        location = data["location"] as? String
        imageUrl = data["imageUrl"] as? String
        forSale = true;
    
        ref = snapshot.ref;
    }
    
    
}

