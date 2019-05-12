//
//  ProfileOptionViewController.swift
//  TerpMarketplace
//
//  Created by Victoria Teng on 5/2/19.
//  Copyright © 2019 CMSC436. All rights reserved.
//

import UIKit
import Firebase

class ProfileOptionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var navigationTitle: UINavigationItem!
    @IBOutlet var tableView: UITableView!
    
    let root = Database.database().reference()
    var user: User!
    var optionToView: String!
    var soldItems : [Item]!
    var allItems: [Item]!
    var viewingItems : [Item]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self;
        
        navigationTitle.title = optionToView;
        
        // Do any additional setup after loading the view.
        if optionToView! == "Saved Items" {
            retrieveLikedItemsInfo()
        } else if optionToView! == "Selling" {
            retrieveSellingItemsInfo()
        } else if optionToView! == "Sold" {
            retrieveSoldItemsInfo()
        }
    }
    
    private func retrieveLikedItemsInfo() {
        var getLikedItems : [Item] = []
        let likedItemIds = user.itemIds;
        
        for i in 0..<self.allItems!.count {
            let curr = self.allItems![i]
            
            if likedItemIds.contains(curr.itemId) {
                getLikedItems.append(curr)
            }
        }
        
        self.viewingItems = getLikedItems;
    }
    
    private func retrieveSellingItemsInfo() {
        var getSellingItems : [Item] = []
        let sellingItemIds = user.sellingItemIds;
        
        for i in 0..<allItems.count {
            let curr = allItems[i]
            
            if sellingItemIds.contains(curr.itemId) {
                getSellingItems.append(curr)
            }
        }
        
        self.viewingItems = getSellingItems
    }
    
    private func retrieveSoldItemsInfo() {
        var getSoldItems: [Item] = []
        let sellingItemIds = user.sellingItemIds;
        
        for i in 0..<allItems.count {
            let curr = allItems[i]
            
            if sellingItemIds.contains(curr.itemId) && curr.forSale == false {
                getSoldItems.append(curr)
            }
        }
        
        self.viewingItems = getSoldItems
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var rows = 0
        rows = viewingItems.count;
        
        return rows;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "optionViewingCell", for: indexPath) as! OptionTableViewCell
        cell.label.text = viewingItems[indexPath.row].name
        
        return cell
    }
    
    // Configure size of each cell
    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / CGFloat(viewingItems.count)
    }

    // Segue to item details
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            let destVC = segue.destination as! ItemDetailsViewController
            
            if let row = tableView.indexPathForSelectedRow?.row {
                destVC.item = viewingItems[row]
            } else {
                print("something went wrong")
            }
        }
    }
    
}
