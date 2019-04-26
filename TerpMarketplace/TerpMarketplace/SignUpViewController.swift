//
//  SignUpViewController.swift
//  TerpMarketplace
//
//  Created by Victoria Teng on 4/16/19.
//  Copyright © 2019 CMSC436. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var firstNameText: UITextField!
    @IBOutlet weak var lastNameText: UITextField!
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstNameText.delegate = self
        lastNameText.delegate = self
        usernameText.delegate = self
        passwordText.delegate = self
        
        configureTapGesture()
        
        // Do any additional setup after loading the view.
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    private func configureTapGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    @objc func handleTap(){
        view.endEditing(true)
    }
    
    @IBAction func signUpAction(_ sender: UIButton) {
        /*
        guard let firstname = firstNameText.text else {return}
        guard let lastname = lastNameText.text else {return}
        guard let username = usernameText.text else {return}
        */
        //guard let password = passwordText.text else {return}
        
        view.endEditing(true)
        
        Auth.auth().createUser(withEmail: usernameText.text!, password: passwordText.text!) { (user, Error) in
            if Error == nil && user != nil
            {
              /*
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.displayName = firstname
                changeRequest?.displayName = lastname
                changeRequest?.displayName = username
 
              */
                //succesful sign up
                print("succesful signup")
            }
            else
            {
                if let myerror = Error?.localizedDescription
                {
                    print(myerror)
                }
                else
                {
                    print("Error")
                }
            }
        }
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
