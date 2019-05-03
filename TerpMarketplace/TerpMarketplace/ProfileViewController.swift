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
    }
    
    /*
    func getUserInfo() {
        
    }
 */
    
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

class OptionCell: UITableViewCell {
    
    @IBOutlet weak var label: UILabel!
}
