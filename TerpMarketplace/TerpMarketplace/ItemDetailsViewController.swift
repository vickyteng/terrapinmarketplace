//
//  ItemDetailsViewController.swift
//  TerpMarketplace
//
//  Created by Victoria Teng on 5/6/19.
//  Copyright © 2019 CMSC436. All rights reserved.
//

import UIKit
import Firebase

class ItemDetailsViewController: UIViewController {

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var itemPhoto: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemDescription: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
    @IBOutlet weak var sellerName: UILabel!
    @IBOutlet weak var sellerEmail: UILabel!
    @IBOutlet weak var itemSoldButton: UIButton!
    @IBAction func markItemSold(_ sender: UIButton) {
        markSoldLabel.text = "Item marked as sold"
        
        if let itemId = item?.itemId {
            self.root.child("allItems/\(itemId)/forSale").setValue("false");
        }
    }
    
    @IBOutlet weak var markSoldLabel: UILabel!
    
    var root = Database.database().reference()
    var item: Item!             // will be sent thru segue
    
    override func viewDidLoad() {
        super.viewDidLoad()

        markSoldLabel.text = "";
        loadItemDetails();
        // Do any additional setup after loading the view.
    }
    
    private func loadItemDetails() {
        if (item.imageUrl != nil) {
            let storageRef = Storage.storage().reference().child("product").child(item.itemId)
            storageRef.downloadURL(completion: { (url, error) in
                do {
                    let data = try Data(contentsOf: url!)
                    let image = UIImage(data: data as Data)
                    
                    self.itemPhoto.image = image;
                } catch {
                    print ("Error downloading image from storage")
                }
            })
        }
        
        itemName.text = item.name;
        itemDescription.text = item.details;
        itemPrice.text = "$\(item.price ?? 0)";
        
        // Get seller information
        self.root.child("users/profile").child(item.sellerId).observe(.value, with: {(snap) in
            
            let user = User(snapshot: snap)
            
            self.sellerName.text = user.fName + " " + user.lName;
            self.sellerEmail.text = user.email;
        })
        
    }

}
