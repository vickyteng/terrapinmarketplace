//
//  PostItemViewController.swift
//  TerpMarketplace
//
//  Created by Victoria Teng on 4/26/19.
//  Copyright © 2019 CMSC436. All rights reserved.
//

import UIKit
import Firebase

class PostItemViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: Outlets
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UITextField!
    @IBOutlet weak var productDescription: UITextField!
    @IBOutlet weak var productPrice: UITextField!
    @IBOutlet weak var productLocation: UITextField!
    
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var postButton: UIButton!
    
    // MARK: Variables
    let root = Database.database().reference()
    var imagePicker: UIImagePickerController!
    var sellerId: String = ""
    var imageUrl: String = ""
    // Store item in overall and in personal
    
    // MARK: Actions
    @IBAction func postAction(_ sender: UIButton) {
        // need to retrieve seller ID
        // retrieve image URL
        
        let newItem: [String: Any] = [
            "sellerId": sellerId,
            "name": productName,
            "price": productPrice,
            "details": productDescription,
            "location": productLocation,
            "forSale": true,
            "createdTimestamp": ServerValue.timestamp(),
            "imageUrl": imageUrl
        ]
        
        self.root.child("allItems").childByAutoId().setValue(newItem);
    }
    
    @IBAction func addImage(_ sender: UITapGestureRecognizer) {
        let alert = UIAlertController.init(title: "Upload Image", message: "", preferredStyle: .alert)
        let addImage = UIAlertAction(title: "Photo Library", style: .default) {
            action -> Void in
            
            
            self.imagePicker.sourceType = .photoLibrary
            
            
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        alert.addAction(addImage)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // informs delegate that picture was chosen, changes picture
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            productImage.image = image
        }
        
        //self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(addImage))
        productImage.addGestureRecognizer(tap)
        
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
