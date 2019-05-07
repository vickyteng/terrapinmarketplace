//
//  PostItemViewController.swift
//  TerpMarketplace
//
//  Created by Victoria Teng on 4/26/19.
//  Copyright © 2019 CMSC436. All rights reserved.
//

import UIKit
import Photos
import Firebase
import CoreLocation

class PostItemViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, CLLocationManagerDelegate {

    // MARK: - Outlets
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UITextField!
    @IBOutlet weak var productDescription: UITextField!
    @IBOutlet weak var productPrice: UITextField!
    @IBOutlet weak var productLocation: UITextField!
    
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var postButton: UIButton!
    
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var userLocationLabel: UILabel!
    
    // MARK: - Variables
    let root = Database.database().reference()
    //let storageRef = Storage.storage.reference()    // need for image
    var imagePicker: UIImagePickerController!
    var sellerId: String = ""
    var imageUrl: String = ""
    var chosenImage: UIImage!
    var locationManager = CLLocationManager()
    
    // MARK: - Actions
    @IBAction func nextButtonAction(_ sender: UIButton) {
        performSegue(withIdentifier: "segueToAddDetails", sender: self)
    }
    
    @IBAction func postAction(_ sender: UIButton) {
        
        //guard let image = productImage.image else {return}
        
    
        
        // retrieve seller ID from firebase
        //sellerId = Auth.auth().currentUser!.uid
        
        
        
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
    
    
    
    @IBAction func locationAction(_ sender: UIButton) {
        if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            startTracking()
        }
        else {
            locationManager.requestWhenInUseAuthorization()
        }
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
        self.root.child("users/profile/\(sellerId)/selling/\(itemId)").setValue(item)
    }
    
    @objc func tapToAddImage(_ sender: UITapGestureRecognizer) {
        let alert = UIAlertController.init(title: "Upload Image", message: "", preferredStyle: .alert)
        let addImage = UIAlertAction(title: "Photo Library", style: .default) {
            action -> Void in
            
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        alert.addAction(addImage)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        
        
        self.present(alert, animated: true, completion: nil)
        
        
        
        
        
        
    }
    
    // informs delegate that picture was chosen, changes picture
    // Once picture is chosen, picker closes
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            productImage.image = image
        }
        
        guard let image = productImage.image else {return}
        
        
        
        self.uploadProductImage(image){url in
            if url != nil {
                
                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                
                //changeRequest?.displayName = username
                changeRequest?.photoURL = url
                changeRequest?.commitChanges { error in
                    
                    if error == nil{
                        
                        
                    } else {
                        
                        
                        print("Error: \(String(describing: error?.localizedDescription))")
                        
                    }
                    
                }
            } else {
                
                //error
                
            }
            
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure image picker
        imagePicker = UIImagePickerController();
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        
        // Only perform if on addImage page
        if let id = self.restorationIdentifier {
            if id == "AddImageViewController" {
                addTapGesture();
                
                // Resets image
                productImage.image = UIImage(named: "addphoto.png")
            }
            if id == "AddDetailsViewController" {
                productName.delegate = self
                productDescription.delegate = self
                productPrice.delegate = self
                productLocation.delegate = self
            }
        }
        
        // location manager setup
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if textField == productName { // Switch focus to other text field
            productDescription.becomeFirstResponder()
            
        } else if textField == productDescription {
            productPrice.becomeFirstResponder()
            
        } else if textField == productPrice {
            productLocation.becomeFirstResponder()
            
        }
        
        return true
    }
    
    // MARK: - Add Gestures
    func addTapGesture() {
        let tapImage: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PostItemViewController.tapToAddImage))
        productImage.isUserInteractionEnabled = true;
        tapImage.numberOfTapsRequired = 1;
        productImage.addGestureRecognizer(tapImage);
    }

    
    // MARK: - Navigation

    // Send chosen image thru segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // if not segueing to Home
        if (segue.destination.restorationIdentifier != "Home") {
            let destVC = segue.destination as! PostItemViewController
            destVC.chosenImage = productImage.image;
        }
    }
    
    // MARK: - user location
    func startTracking() {
        locationManager.startUpdatingLocation()
    }
    
    // get user's current location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue : CLLocationCoordinate2D = manager.location!.coordinate
        let latitude = locValue.latitude
        let longitude = locValue.longitude
        
        userLocationLabel.text = "\(latitude),\(longitude)"
        productLocation.text = "\(round(latitude)),\(round(longitude))"
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            startTracking()
        }
    }
    
    func uploadProductImage(_ image:UIImage,completion: @escaping ((_ url:URL?)->()))
        
    {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        
        let storageRef = Storage.storage().reference().child("product/\(uid)")
        
        guard let imageData = image.jpegData(compressionQuality:0.75) else { return }
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        storageRef.putData(imageData, metadata: metaData) { metaData, error in
            if error == nil, metaData != nil {
                
                storageRef.downloadURL { url, error in
                    completion(url)
                    // success!
                }
            } else {
                // failed
                completion(nil)
            }
        
        }
}
    

}
/*
let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus();
            switch photoAuthorizationStatus {
            case .authorized: print("Access is granted by user")
            case .notDetermined: PHPhotoLibrary.requestAuthorization({
                (newStatus) in print("status is \(newStatus)"); if newStatus == PHAuthorizationStatus.authorized {  print("success") }
                })
                case .restricted: print("User do not have access to photo album.")
                case .denied: print("User has denied the permission.")
                }
*/
