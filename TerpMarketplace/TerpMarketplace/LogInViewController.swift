//
//  LoginViewController.swift
//  TerpMarketplace
//
//  Created by Victoria Teng on 4/16/19.
//  Copyright © 2019 CMSC436. All rights reserved.
//

import UIKit
import Firebase
class LoginViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBAction func loginAction(_ sender: UIButton) {
        
        view.endEditing(true)
        Auth.auth().signIn(withEmail: username.text!, password: password.text!) { (user, Error) in
            if user != nil{
                
                //succesful login
                print("succesful login")
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTextFeilds()
        configureTapGesture()
    }
    private func configureTapGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.handleTap))
        view.addGestureRecognizer(tapGesture)
    }
    @objc func handleTap(){
        view.endEditing(true)
    }
    private func configureTextFeilds(){
        username.delegate = self
        password.delegate = self
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
extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
}
