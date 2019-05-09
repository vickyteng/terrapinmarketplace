//
//  webViewController.swift
//  TerpMarketplace
//
//  Created by fitsumend on 5/9/19.
//  Copyright © 2019 CMSC436. All rights reserved.
//

import UIKit

class webViewController: UIViewController {
    
    
    @IBOutlet var webView: UIWebView!
    
    var url = URL(string: "")
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
        let urlreq = URLRequest(url: url!)
        
        webView.loadRequest(urlreq)
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
