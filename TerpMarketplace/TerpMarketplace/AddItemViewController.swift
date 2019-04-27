//
//  AddItemViewController.swift
//  TerpMarketplace
//
//  Created by Victoria Teng on 4/18/19.
//  Copyright © 2019 CMSC436. All rights reserved.
//

import UIKit
import FirebaseDatabase

class PostItemViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UITextField!
    @IBOutlet weak var productDescription: UITextField!
    @IBOutlet weak var productPrice: UITextField!
    @IBOutlet weak var productLocation: UITextField!
    
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var postButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        // Do any additional setup after loading the view.
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
