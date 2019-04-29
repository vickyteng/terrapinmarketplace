//
//  Item.swift
//  TerpMarketplace
//
//  Created by Victoria Teng on 4/18/19.
//  Copyright © 2019 CMSC436. All rights reserved.
//

import Foundation
import Firebase

class Item {
    
    var sellerId: String!
    var itemId: String!
    var name: String!
    var price: Int!
    var details: String!
    //var image: UIImage
    var forSale: Bool! = true       // false if sold
    //var location: CLLocation?
    var ref: DatabaseReference
    
    init(snapshot: DataSnapshot) {
        let data = snapshot.value as! Dictionary<String, AnyObject>
        
        name = data["name"] as? String
        price = data["price"]?.integerValue ?? 0
        details = data["details"] as? String
        forSale = data["forSale"] as? Bool
        sellerId = data["sellerId"] as? String
    
        ref = snapshot.ref;
    }
    
    
}

