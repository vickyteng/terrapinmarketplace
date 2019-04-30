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

class ItemListingViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var numberOfItemsLabel: UILabel!
    @IBOutlet weak var noItemsView: UIView!
    @IBOutlet weak var noItemsLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var root = Database.database().reference();
    var itemsUserSee : [Item] = []
    var items : [Item] = [];                // all items
    var viewingNumberOfItems = 0 {            // Number of products for sale
        didSet {
            if viewingNumberOfItems == 0 {
                numberOfItemsLabel.text = "No products for sale"
            } else if viewingNumberOfItems == 1 {
                numberOfItemsLabel.text = "Viewing 1 product"
            } else {
                numberOfItemsLabel.text = "Viewing \(viewingNumberOfItems) products"
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // Need to keep collection view showing for search bar
        if itemsUserSee.count == 0 {
            UIView.animate(withDuration: 0.25, animations: {
                self.noItemsView.alpha = 1.0
            })
        } else {
            self.noItemsView.alpha = 0.0
        }
        
        return itemsUserSee.count
    }
    
    // TODO: change image for each cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as! ItemCollectionViewCell;
        let item = itemsUserSee[indexPath.row]
        
        cell.productName.text = item.name!
        cell.productPrice.text = "$\(item.price!)"
        
        userLiked(item: item, cell: cell)
        
        return cell;
    }
    
    
    // MARK: - Collection View Delegate
    
    // Setup search bar and filter button views and delegate
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if (kind == UICollectionView.elementKindSectionHeader) {
            let headerView =  collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ItemListingHeader", for: indexPath) as! ItemListingCollectionReusableView
            
            headerView.searchBar.delegate = self;
            
            return headerView
        }
        
        return UICollectionReusableView()
    }
    
    // Send itemId to ItemCell
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if let itemCell = cell as? ItemCollectionViewCell {
            print(indexPath)
            if indexPath.row >= 0 && indexPath.row < items.count {
                itemCell.itemId = itemsUserSee[indexPath.row].itemId
            } else {
                collectionView.reloadData()
            }
        }
    }
    
    
    // MARK: - Search Bar methods
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let indexPath = IndexPath(row: 0, section: 0)
        if let headerView = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: indexPath) as? ItemListingCollectionReusableView {

            headerView.searchBar.resignFirstResponder()

            let searchQuery = headerView.searchBar.text

            if((searchQuery?.isEmpty)!){
                itemsUserSee = items;
            } else {
                
                // empty itemsUserSee
                itemsUserSee = []
                
                // query DB, append to itemSearch
                // update view
                for item in items {
                    let itm = item.name.lowercased()
                    let searchTxt = searchQuery?.lowercased()
                    // go thru items, retrieve name; lowercase both entry and db
                    if itm.hasPrefix(searchTxt!) {
                        itemsUserSee.append(item)
                    }
                }
                
                if itemsUserSee.isEmpty {
                    noItemsLabel.text = "No products available that start with \"\(searchQuery!)\""
                }
            }
            
            //viewingNumberOfItems = itemsUserSee.count;
            self.collectionView?.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self;
        collectionView.delegate = self;
        
        startObserving();
        
        itemsUserSee = items;
        viewingNumberOfItems = itemsUserSee.count;
        if viewingNumberOfItems == 0 {
            noItemsLabel.text = "No products for sale. Be the first!"
        }
        
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
            self.viewingNumberOfItems = self.items.count
            self.itemsUserSee = self.items;
            
            
            self.collectionView.reloadData()
        })
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
    var searchText: String!
    var itemsId: [String] = []
    
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
    
    override func awakeFromNib() {
        super.awakeFromNib();
        
        searchObserver()
    }
    
    private func searchObserver() {
        self.root.child("users").observe(.value, with: {(snap) in
            for userSnaps in snap.children {
                let u = User(snapshot: userSnaps as! DataSnapshot)
                
                // Returns updated item ids that user likes
                self.itemsId = u.itemIds
            }
            
        })
    }
    
    // Checks database if user already likes the product or not
    // Modifies likesItem var
    private func doesUserLike() {
        
        if itemsId.contains(self.itemId) {
            self.likesItem = true;
        } else {
            self.likesItem = false;
        }
    }
}
