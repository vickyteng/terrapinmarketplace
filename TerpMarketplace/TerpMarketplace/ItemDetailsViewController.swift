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
    
    var root = Database.database().reference()
    var itemId: String!
    var item: Item!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Need to send itemId from previous view
        getItem(itemId: itemId);

        loadItemDetails();
        // Do any additional setup after loading the view.
    }
    
    private func getItem(itemId: String) {
        root.child("allItems").observe(.value, with: {(snap) in
            
            for itemSnaps in snap.children {
                let item = Item(snapshot: itemSnaps as! DataSnapshot)
                
                let i = itemSnaps as! DataSnapshot // Get id of item
                if itemId == i.key {
                    self.item = item;
                }
            }
        })
    }
    
    private func loadItemDetails() {
        if let uid = Auth.auth().currentUser?.uid {
            let storageRef = Storage.storage().reference().child("product").child(uid)
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
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
