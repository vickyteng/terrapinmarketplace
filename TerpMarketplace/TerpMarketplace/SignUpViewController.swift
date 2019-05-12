//
//  SignUpViewController.swift
//  TerpMarketplace
//
//  Created by Victoria Teng on 4/16/19.
//  Copyright © 2019 CMSC436. All rights reserved.
//

import UIKit
import Firebase
import Photos

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var firstNameText: UITextField!
    @IBOutlet weak var lastNameText: UITextField!
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var tapToChangeProfileButton: UIButton!
    
    @IBAction func profileChange(_ sender: UIButton) {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus();
        switch photoAuthorizationStatus {
            case .authorized: print("Access is granted by user")
                self.imagePicker.sourceType = .photoLibrary
                self.imagePicker.allowsEditing = true
                self.present(self.imagePicker, animated: true, completion: nil)
            case .notDetermined: PHPhotoLibrary.requestAuthorization({ (newStatus) in
                
                if newStatus == PHAuthorizationStatus.authorized {
                    self.imagePicker.sourceType = .photoLibrary
                    self.imagePicker.allowsEditing = true
                    self.present(self.imagePicker, animated: true, completion: nil)
                }
            })
            case .restricted: print("User do not have access to photo album.")
            case .denied: print("User has denied the permission.")
        }
    }
    
    let imageTap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
    
    
    var imagePicker = UIImagePickerController()
    
    
    @IBAction func login(_ sender: UIButton) {
        performSegue(withIdentifier: "login", sender: self)
    }
    
    var error = "" {
        didSet {
            errorLabel.text = error
        }
    }
    
    var ref : DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        firstNameText.delegate = self
        lastNameText.delegate = self
        usernameText.delegate = self
        passwordText.delegate = self
        error = ""
        
        configureTapGesture()
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    @objc func openImagePicker(_ sender: Any){
        
        // open image picker
        
        self.present(imagePicker,  animated: true, completion: nil)
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    private func configureTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap() {
        view.endEditing(true)
    }
    
    @IBAction func signUpAction(_ sender: UIButton) {
        
        guard let username = usernameText.text else {return}
        guard let firstname = firstNameText.text else {return}
        guard let lastname = lastNameText.text else {return}
        guard let image = profileImageView.image else {return}
        
        view.endEditing(true)
        Auth.auth().createUser(withEmail: usernameText.text!, password: passwordText.text!) { (user, Error) in
            if Error == nil && user != nil
            {
                self.uploadProfileImage(image) { url in
                    if url != nil {
                        
                        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            
                        changeRequest?.displayName = username
                        changeRequest?.photoURL = url
                        changeRequest?.commitChanges { error in
                            
                            if error == nil{
                                print("user display name change")
                                self.saveProfile(username: username,firstname: firstname,lastname:lastname, profileImageURL: url!){ success in
                                    
                                    if success {
                                        
                                        //self.dismiss(animated: true, completion: nil)
                                        
                                    }
                                    
                                }
                                //self.dismiss(animated:false, completion: nil)
                                
                            } else {
                                
                                
                                print("Error: \(String(describing: error?.localizedDescription))")
                                
                            }
                            
                        }
                    } else {
                        
                        //error
                        
                    }
                    
                }
                //succesful sign up
                self.error = "Successful Signup"
                
                self.performSegue(withIdentifier: "login", sender: self)
                
            } else {
                if let myerror = Error?.localizedDescription {
                    self.error = myerror
                } else {
                    self.error = "Error"
                }
            }
        }
    }
    
    func saveProfile(username:String,firstname:String,lastname:String,profileImageURL: URL , completion: @escaping ((_ success: Bool)->())){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let databaseRef = Database.database().reference().child("users/profile/\(uid)")
        
        let userObject = [
            "username": username,
            "fisrtname":firstname,
            "lastname": lastname,
            "photoURL": profileImageURL.absoluteString
            ] as [String:Any]
        databaseRef.setValue(userObject) { error, ref in
            completion(error == nil)
            
        }
    }
    
    func uploadProfileImage(_ image:UIImage, completion: @escaping ((_ url:URL?)->())){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let storageRef = Storage.storage().reference().child("user/\(uid)")
        
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
        
        
        //Storage.storage().reference().child("user/\()")
        
        
        
        //storageRef.storage().reference().child("user/\()")
        //= Storage.storage().reference().child("user/\()")
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

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            self.profileImageView.image = pickedImage
        }
        
        
        picker.dismiss(animated: true, completion: nil)
    }
}
