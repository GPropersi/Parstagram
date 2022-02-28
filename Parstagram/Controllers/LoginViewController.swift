//
//  LoginViewController.swift
//  Parstagram
//
//  Created by Giovanni Propersi on 2/26/22.
//

import UIKit
import Parse


class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    var username: String?
    var password: String?
    
    var loginError: UIAlertController!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create new alert for loading of tweets error
        loginError = UIAlertController(title: "Alert", message : "", preferredStyle: .alert)

        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in return})
        
        //Add OK button to a dialog message
        loginError.addAction(ok)

        // Do any additional setup after loading the view.
    }
    
    // MARK: - IB Actions
    
    @IBAction func onSignIn(_ sender: Any) {
        username = usernameField.text!
        password = passwordField.text!
        
        PFUser.logInWithUsername(inBackground: username!, password: password!) {
            (user: PFUser?, error: Error?) -> Void in
            switch error {
                case .some(let error as NSError):
                    self.loginError.message = "Error: " + error.localizedDescription
                    self.present(self.loginError, animated: true, completion: nil)
                
                case .none:
                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
        }
    }
    
    // Sends user back to Login View after pressing Log Out on profile page
    @IBAction func prepareforUnwind(segue: UIStoryboardSegue) {
        
    }
}
