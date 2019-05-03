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

    // MARK: - Outlets
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UITextField!
    @IBOutlet weak var productDescription: UITextField!
    @IBOutlet weak var productPrice: UITextField!
    @IBOutlet weak var productLocation: UITextField!
    
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var postButton: UIButton!
    
    // MARK: - Variables
    let root = Database.database().reference()
    //let storageRef = Storage.storage.reference()    // need for image
    var imagePicker: UIImagePickerController!
    var sellerId: String = ""
    var imageUrl: String = ""
    
    // MARK: - Actions
    @IBAction func nextButtonAction(_ sender: UIButton) {
        performSegue(withIdentifier: "segueToAddDetails", sender: self)
    }
    
    // Need to send image to segue
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let destVC = segue.destination as! PostItemViewController
//        destVC.productImage = productImage;
//    }
    
    @IBAction func postAction(_ sender: UIButton) {
        
        // retrieve seller ID from firebase
        sellerId = Auth.auth().currentUser!.uid
        
        let newItem: [String: Any] = [
            "sellerId": sellerId,
            "name": productName.text!,
            "price": productPrice.text!,
            "details": productDescription.text!,
            "location": productLocation.text!,
            "forSale": true,
            "createdTimestamp": ServerValue.timestamp(),
            "imageUrl": imageUrl
        ]
        
        saveNewItem(newItem) { (itemRef) in
            self.saveNewItemToUser(itemId: itemRef.key!, sellerId: self.sellerId, item: newItem)
        }
        
        // Segue back
        let alert = UIAlertController.init(title: "Item Posted", message: "", preferredStyle: .alert)
        let ok = UIAlertAction(title: "awesome!!", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: segueBackToHome)
    }
    
    // MARK: - Functions
    
    func segueBackToHome() {
        self.performSegue(withIdentifier: "segueToMain", sender: self)
    }
    
    // Saves item in /allItems, then returns item reference on completion
    func saveNewItem(_ newItem: [String: Any], completion: @escaping (DatabaseReference) -> Void) {
        // Save in all items
        self.root.child("allItems").childByAutoId().setValue(newItem) { (error, itemRef) in
            if error != nil {
                print("Error saving new item")
            }
            completion(itemRef)
        }
    }
    
    func saveNewItemToUser(itemId: String, sellerId: String, item: [String: Any]) {
        // Save under user
        self.root.child("users/\(sellerId)/selling/\(itemId)").setValue(item)
    }
    
    @objc func tapToAddImage(_ sender: UITapGestureRecognizer) {
        print("pressed image")
        let alert = UIAlertController.init(title: "Upload Image", message: "", preferredStyle: .alert)
        let addImage = UIAlertAction(title: "Photo Library", style: .default) {
            action -> Void in
            
            // TODO: fix error here
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
        
        // Only perform if on addImage page
        if (self.restorationIdentifier == "AddImageViewController") {
            addTapGesture();
        }
        
    }
    
    // MARK: - Add Gestures
    func addTapGesture() {
        let tapImage: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PostItemViewController.tapToAddImage))
        productImage.isUserInteractionEnabled = true;
        tapImage.numberOfTapsRequired = 1;
        productImage.addGestureRecognizer(tapImage);
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
