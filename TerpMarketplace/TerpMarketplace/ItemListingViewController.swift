//
//  FirstViewController.swift
//  TerpMarketplace
//
//  Created by Victoria Teng on 4/15/19.
//  Copyright © 2019 CMSC436. All rights reserved.
//

import UIKit
import Firebase


// Only list items that are forSale, go thru each

class ItemListingViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    
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
        if items.count == 0 {
            UIView.animate(withDuration: 0.25, animations: {
                self.noItemsView.alpha = 1.0
            })
        } else {
            self.noItemsView.alpha = 0.0
        }
        
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        <#code#>
    }
    
    // If user put in query
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let indexPath = IndexPath(row: 0, section: 0)
        if let header = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: indexPath) as? ItemListingCollectionReusableView {
            
            header.searchBar.resignFirstResponder()
            
            // empty itemSearch
            // query DB, append to itemSearch
            // update view
        }
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self;
        collectionView.delegate = self;
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout;
        layout.itemSize = CGSize(width: floor(view.frame.width * (190/414)), height: 230)
        
        if let navBar = navigationController?.navigationBar {
            navBar.clipsToBounds = true;
        }
        
        startObserving();
    }
    
    
    // Observer - retrieves new entries in database and updates view
    func startObserving() {
        root.child("allItems").observe(.value, with: {(snap) in
            var newItems = [Item]()
            
            for itemSnaps in snap.children {
                let item = Item(snapshot: itemSnaps as! DataSnapshot)
                newItems.append(item)
            }
            self.items = newItems
            self.collectionView.reloadData()
        })
    }


}


