//
//  RegisterViewController.swift
//  Parstagram
//
//  Created by Giovanni Propersi on 2/27/22.
//

import UIKit
import Parse

class RegisterViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    var registrationError: UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create new alert for loading of tweets error
        registrationError = UIAlertController(title: "Alert", message : "", preferredStyle: .alert)

        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in return})
        
        //Add OK button to a dialog message
        registrationError.addAction(ok)

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onSignUp(_ sender: Any) {
        let password = passwordField.text
        let passwordConfirm = confirmPasswordField.text
        
        guard password == passwordConfirm else {
            self.registrationError.message = "Error: Passwords do not match"
            self.present(self.registrationError, animated: true, completion: nil)
            return
        }
        
        let user = PFUser()

        user.username = usernameField.text
        user.password = password

        user.signUpInBackground { (success, error) in
            switch error {
            case .some(let error as NSError):
                self.registrationError.message = "Error: " + error.localizedDescription
                self.present(self.registrationError, animated: true, completion: nil)

            case .none:
                self.login(user.username!, user.password!)
            }
        }
    }
    
    func login(_ username: String, _ password: String) {
        
        PFUser.logInWithUsername(inBackground: username, password: password) {
            (user: PFUser?, error: Error?) -> Void in
            switch error {
                case .some(let error as NSError):
                    self.registrationError.message = "Error: " + error.localizedDescription
                    self.present(self.registrationError, animated: true, completion: nil)
                    
                case .none:
                    self.performSegue(withIdentifier: "onRegister", sender: nil)
            }
        }
    }
    
    @IBAction func returnToLoginButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
