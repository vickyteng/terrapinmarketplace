//
//  SignUpInViewController.swift
//  TerpMarketplace
//
//  Created by Victoria Teng on 4/16/19.
//  Copyright © 2019 CMSC436. All rights reserved.
//

import UIKit

class SignUpLoginViewController: UIViewController {

    
    @IBAction func signUp(_ sender: UIButton) {
        performSegue(withIdentifier: "signup", sender: self)
    }
    
    @IBAction func login(_ sender: UIButton) {
        performSegue(withIdentifier: "login", sender: self)
    }
    
    
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
