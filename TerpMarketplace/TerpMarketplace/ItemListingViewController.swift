//
//  ItemListingViewController.swift
//  TerpMarketplace
//
//  Created by Victoria Teng on 4/15/19.
//  Copyright © 2019 CMSC436. All rights reserved.
//

import UIKit
import Firebase


// Only list items that are forSale, go thru each

class ItemListingViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var numberOfItemsLabel: UILabel!
    @IBOutlet weak var noItemsView: UIView!
    @IBOutlet weak var noItemsLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var root = Database.database().reference();
    var items : [Item] = [];                // all items
    var itemSearch : [Item] = [];           // items from user query
    var totalNumberOfItems = 0 {            // Number of products for sale
        didSet {
            if totalNumberOfItems == 0 {
                numberOfItemsLabel.text = "No products for sale"
            } else if totalNumberOfItems == 1 {
                numberOfItemsLabel.text = "Viewing 1 product"
            } else {
                numberOfItemsLabel.text = "Viewing \(totalNumberOfItems) products"
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // Need to keep collection view showing for search bar
        if items.count == 0 {
            print("no items")
            UIView.animate(withDuration: 0.25, animations: {
                self.noItemsView.alpha = 1.0
            })
        } else {
            self.noItemsView.alpha = 0.0
        }
        
        return items.count
    }
    
    // TODO: change image for each cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as! ItemCollectionViewCell;
        let item = items[indexPath.row]
        
        cell.productName.text = item.name!
        cell.productPrice.text = "$\(item.price!)"
        
        userLiked(item: item, cell: cell)
        
        return cell;
    }
    
    // MARK: Collection View Delegate
    // Setup search bar and filter button views
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if (kind == UICollectionView.elementKindSectionHeader) {
            let headerView:UICollectionReusableView =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ItemListingHeader", for: indexPath)
            
            return headerView
        }
        
        return UICollectionReusableView()
    }
    
    // Send itemId to ItemCell
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let itemCell = cell as? ItemCollectionViewCell {
            if indexPath.row >= 0 && indexPath.row < items.count {
                itemCell.itemId = items[indexPath.row].itemId
            } else {
                collectionView.reloadData()
            }
        }
    }
    
    // MARK: - Search Bar methods
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let indexPath = IndexPath(row: 0, section: 0)
        if let header = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: indexPath) as? ItemListingCollectionReusableView {
            
            header.searchBar.resignFirstResponder()
            
            if(!(searchBar.text?.isEmpty)!){
                //reload your data source if necessary
                self.collectionView?.reloadData()
            }
            
            // empty itemSearch
            // query DB, append to itemSearch
            // update view
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let indexPath = IndexPath(row: 0, section: 0)
        if let header = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: indexPath) as? ItemListingCollectionReusableView {
            
            header.searchBar.resignFirstResponder()
            
            if(searchText.isEmpty){
                //reload your data source if necessary
                self.collectionView?.reloadData()
            }
            
            // empty itemSearch
            // query DB, append to itemSearch
            // update view
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self;
        collectionView.delegate = self;
        
        totalNumberOfItems = 0;
        
        startObserving();
        
        // Layout items depending on number of items available
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout;
        layout.itemSize = CGSize(width: floor(view.frame.width * (190/414)), height: 230)
        
        if let navBar = navigationController?.navigationBar {
            navBar.clipsToBounds = true;
        }
    }
    
    // MARK: - Helper Functions
    
    // Returns true if user likes item
    private func userLiked(item: Item, cell: ItemCollectionViewCell) {
        
        if let userId = Auth.auth().currentUser?.uid {
            let likedItems = self.root.child("users").child(userId).child("likes")
            
            likedItems.observeSingleEvent(of: .value, with: { snap in
                
                for itemSnaps in snap.children {
                    let i = itemSnaps as! DataSnapshot

                    if i.exists() && i.key == item.itemId! {
                        cell.likeButton.setImage(#imageLiteral(resourceName: "like"), for: .normal)
                        
                    }
                }
            })
            
        }
    }
    
    // MARK: - Observers
    // Observer - retrieves new entries in database and updates view
    func startObserving() {
        root.child("allItems").observe(.value, with: {(snap) in
            var newItems = [Item]()
            
            for itemSnaps in snap.children {
                let item = Item(snapshot: itemSnaps as! DataSnapshot)
                
                let i = itemSnaps as! DataSnapshot // Get id of item
                item.itemId = i.key
                
                newItems.append(item)
            }
            self.items = newItems
            self.totalNumberOfItems = self.items.count
            self.collectionView.reloadData()
        })
    }
    
    func searchObservation() {
        
    }


}



// MARK: - ItemCollectionViewCell class
class ItemCollectionViewCell: UICollectionViewCell {
    
    // MARK: ItemCell outlets
    
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    var root = Database.database().reference();
    var itemId: String!
    var likesItem = false;
    
    @IBAction func likeButtonAction(_ sender: UIButton) {
        
        if let userId = Auth.auth().currentUser?.uid {
            doesUserLike()
            
            // User already likes -> Unlike
            if likesItem == true {
                print("setting not pink heart")
                self.likeButton.setImage(#imageLiteral(resourceName: "nolike"), for: .normal)
                
                // Remove from database
                let itemLikedRef = self.root.child("users").child(userId).child("likes");
                
                itemLikedRef.child(self.itemId!).removeValue()
                
                
            // User does not like yet -> Like
            } else {
                print("Setting pink heart")
                self.likeButton.setImage(#imageLiteral(resourceName: "like"), for: .normal)
                
                // Save in database
                root.child("users/\(userId)/likes/\(itemId!)").setValue("me likey")
            }
        }
    }
    
    // Checks database if user already likes the product or not
    // Modifies likesItem var
    private func doesUserLike() {
        
        if let userId = Auth.auth().currentUser?.uid {
            
            let likedItems = self.root.child("users").child(userId).child("likes")

            likedItems.observeSingleEvent(of: .value, with: { snap in
                
                for itemSnaps in snap.children {
                    let i = itemSnaps as! DataSnapshot
                    
                    if i.exists() && i.key == self.itemId {
                        self.likesItem = true;
                    }
                }
            })
            
        }
        
    }
}
