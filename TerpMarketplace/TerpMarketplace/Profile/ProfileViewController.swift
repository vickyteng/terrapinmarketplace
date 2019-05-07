//
//  ProfileViewController.swift
//  TerpMarketplace
//
//  Created by Victoria Teng on 4/18/19.
//  Copyright © 2019 CMSC436. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var userDetailView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileOptionTableView: UITableView!
    
    let root = Database.database().reference();
    var currUser: User!
    var allItems: [Item]!
    
    let sections: [String] = [
        "Saved Items",
        "Selling",
        "Sold",
        "Settings"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup delegate methods for TableView
        profileOptionTableView.delegate = self
        profileOptionTableView.dataSource = self
        
        retrieveUserInfo();
        getAllItems();
        
    }
    
    private func retrieveUserInfo() {
        if let userId = Auth.auth().currentUser?.uid {
            self.root.child("users/profile").child(userId).observe(.value, with: {(snap) in
            
                let user = User(snapshot: snap)
                
                self.currUser = user
                self.currUser.userId = snap.key
                self.setProfileView();
            })
        }
    }
    
    private func getAllItems(){
        root.child("allItems").observe(.value, with: {(snap) in
            
            var newItems = [Item]()
            
            for itemSnaps in snap.children {
                let item = Item(snapshot: itemSnaps as! DataSnapshot)
                
                let i = itemSnaps as! DataSnapshot // Get id of item
                item.itemId = i.key
                
                newItems.append(item)
            }
            
            self.allItems = newItems
        })
    }
    
    private func setProfileView() {
        
        let storageRef = Storage.storage().reference().child("user").child(currUser.userId)
        
        storageRef.downloadURL(completion: { (url, error) in
            do {
            let data = try Data(contentsOf: url!)
            let image = UIImage(data: data as Data)
            self.profilePicture.image = image
            } catch {
                print ("Error downloading image from storage")
            }
        })
        
        nameLabel.text = currUser.fName + " " + currUser.lName;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "optionCell", for: indexPath) as! OptionCell;
        cell.label.text = sections[indexPath.row]
        return cell;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Configure size of each cell
    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / CGFloat(sections.count)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Send user information & chosen cell to segue
        if segue.identifier == "segueToProfileOption" {
            let profileOptionViewController = segue.destination as! ProfileOptionViewController
            
            if let row = profileOptionTableView.indexPathForSelectedRow?.row {
            
                profileOptionViewController.optionToView = sections[row]
                profileOptionViewController.user = self.currUser
                profileOptionViewController.allItems = self.allItems
            } else {
                print("something went wrong")
            }
        }
    }

}

class OptionCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
}
