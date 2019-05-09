//
//  ItemListingViewController.swift
//  TerpMarketplace
//
//  Created by Victoria Teng on 4/15/19.
//  Copyright © 2019 CMSC436. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation


// Only list items that are forSale, go thru each

class ItemListingViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, CLLocationManagerDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var numberOfItemsLabel: UILabel!
    @IBOutlet weak var noItemsView: UIView!
    @IBOutlet weak var noItemsLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // location action
    @IBAction func locationAction(_ sender: Any) {
        if (itemsFiltered.count == 0) {
            byLocation = true
            
            if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                startTracking()
            }
            else {
                locationManager.requestWhenInUseAuthorization()
            }
        }
        else { // toggle filter by location off
            byLocation = false
            itemsFiltered = [] // reset filtered items array
            stopTracking()
        }
        
        viewDidLoad()
    }
    
    // location variables
    var locationManager = CLLocationManager()
    var userLatitude : Double = 0.0
    var userLongitude : Double = 0.0
    var byLocation : Bool = false
    
    var root = Database.database().reference();
    var itemsUserSee : [Item] = []
    var items : [Item] = [];                // all items
    var itemsFiltered : [Item] = []         // filtered items
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as! ItemCollectionViewCell;
        let item = itemsUserSee[indexPath.row]
        
        cell.productName.text = item.name!
        cell.productPrice.text = "$\(item.price!)"
        
        if let uid = Auth.auth().currentUser?.uid {
            let storageRef = Storage.storage().reference().child("product").child(uid)
            storageRef.downloadURL(completion: { (url, error) in
                do {
                    let data = try Data(contentsOf: url!)
                    let image = UIImage(data: data as Data)
                    cell.productImage.image = image;
                } catch {
                    print ("Error downloading image from storage")
                }
            })
        }
        
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
            if indexPath.row >= 0 && indexPath.row < items.count {
                itemCell.itemId = itemsUserSee[indexPath.row].itemId
            } else {
                collectionView.reloadData()
            }
        }
    }
    
    
    // MARK: - Search Bar methods
    
    // Displays Cancel button after user types
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.showsCancelButton = true;
        
        if let cancelButton = searchBar.subviews.first?.subviews.last as? UIButton {
            cancelButton.setTitleColor(UIColor.yellow, for: .normal)
        }
    }
    
    // When cancel button is clicked, hide button and close keyboard
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        
        searchBar.text = ""
        itemsUserSee = items;
        
        viewingNumberOfItems = itemsUserSee.count;
        self.collectionView?.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let indexPath = IndexPath(row: 0, section: 0)
        if let headerView = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: indexPath) as? ItemListingCollectionReusableView {

            headerView.searchBar.resignFirstResponder()

            let searchQuery = headerView.searchBar.text

            if((searchQuery?.isEmpty)!){
                itemsUserSee = items;
            } else {
                
                itemsUserSee = []
                
                // go thru items, retrieve name; lowercase both entry and db
                for item in items {
                    let itm = item.name.lowercased()
                    let searchTxt = searchQuery?.lowercased()
                    if itm.hasPrefix(searchTxt!) {
                        itemsUserSee.append(item)
                    }
                }
                
                if itemsUserSee.isEmpty {
                    noItemsLabel.text = "No products available that start with \"\(searchQuery!)\""
                }
            }
            
            viewingNumberOfItems = itemsUserSee.count;
            self.collectionView?.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self;
        collectionView.delegate = self;
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if byLocation { // show filtered items
            itemsUserSee = itemsFiltered
        }
        else { // show all items
            itemsUserSee = items;
        }
        
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
        
        startObserving();
    }
    
    // MARK: - Helper Functions
    
    // Returns true if user likes item
    private func userLiked(item: Item, cell: ItemCollectionViewCell) {
        
        if let userId = Auth.auth().currentUser?.uid {
            let likedItems = self.root.child("users/profile").child(userId).child("likes")
            
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
    
    // MARK: - Location Functions
    
    // returns array of items in range of current location based on given radius
    private func filterByLocation(radius: Int) {
        var arr : [Item] = []
        
        for item in items {
            let coordinate = item.location.split(separator: ",")
            if coordinate.count == 2 {
                let latitude = Double(coordinate[0])
                let longitude = Double(coordinate[1])
                //print("User's latitude:\(userLatitude),longitude:\(userLongitude)")

                
                // distance formula
                //(pow((userLatitude - latitude), 2) + pow((userLongitude - longitude), 2)).squareRoot()
                
                if latitude != nil && longitude != nil && (pow((userLatitude - latitude!), 2) + pow((userLongitude - longitude!), 2)).squareRoot() < Double(radius) { // if valid add to array
                    arr.append(item)
                }
                else {
                    print("did not add to arr")
                }
            }
        }
        itemsFiltered = arr
    }
    
    func startTracking() {
        locationManager.startUpdatingLocation()
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
    }
    
    // get user's current location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue : CLLocationCoordinate2D = manager.location!.coordinate
        userLatitude = round(locValue.latitude)
        userLongitude = round(locValue.longitude)
        filterByLocation(radius: 10)
        viewDidLoad()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            startTracking()
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
            
            if self.byLocation { // show filtered items
                self.itemsUserSee = self.itemsFiltered
            }
            else { // show all items
                self.itemsUserSee = self.items
            }
            
            self.viewingNumberOfItems = self.itemsUserSee.count
            
            self.collectionView.reloadData()
        })
    }
    
    deinit {
        root.removeAllObservers();
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // if segueing to item details, send itemId
        if segue.identifier == "showDetails" {
            let destVC = segue.destination as! ItemDetailsViewController
            //destVC.itemId = ItemCollectionViewCell.itemId
            // OR in IBAction when clicking on productImage in ItemCollectionViewCell class
            // self.performSegue(withIdentifier: "showDetails", sender: self)
            // and send information
        }
    }

}



// MARK: - ItemCollectionViewCell class
class ItemCollectionViewCell: UICollectionViewCell {
    
    // MARK: ItemCell outlets
    
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var productImage: UIImageView!
    
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
                self.likeButton.setImage(#imageLiteral(resourceName: "nolike"), for: .normal)
                
                // Remove from database
                let itemLikedRef = self.root.child("users/profile").child(userId).child("likes");
                
                itemLikedRef.child(self.itemId!).removeValue()
                
                
            // User does not like yet -> Like
            } else {
                self.likeButton.setImage(#imageLiteral(resourceName: "like"), for: .normal)
                
                // Save in database
                root.child("users/profile/\(userId)/likes/\(itemId!)").setValue("me likey")
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib();
        
        searchObserver()
    }
    
    // MARK: - Observer
    
    private func searchObserver() {
        self.root.child("users").observe(.value, with: {(snap) in
            for userSnaps in snap.children {
                let u = User(snapshot: userSnaps as! DataSnapshot)
                
                // Returns updated item ids that user likes
                self.itemsId = u.itemIds
            }
            
        })
    }
    
    // MARK: Helper
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
