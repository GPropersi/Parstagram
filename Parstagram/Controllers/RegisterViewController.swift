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
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameField.delegate = self
        passwordField.delegate = self
        confirmPasswordField.delegate = self
        
        addDoneToKeyboard(usernameField)
        addDoneToKeyboard(passwordField)
        addDoneToKeyboard(confirmPasswordField)
        
        // Create new alert for loading of register error
        registrationError = UIAlertController(title: "Alert", message : "", preferredStyle: .alert)

        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in return})
        
        //Add OK button to a dialog message
        registrationError.addAction(ok)

        // Set keyboard to be below textfield
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil);

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil);
    }
    
    
    // MARK: - IB Actions
    
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
    
    @IBAction func returnToLoginButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Logging into database and app on register
    
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
    
}

// MARK: - Keyboard below textfield and adding Done button

extension RegisterViewController: UITextFieldDelegate {
    
        func addDoneToKeyboard(_ frame: UITextField) {
            // Add done to the keyboard for each input option
            // https://www.youtube.com/watch?v=M_fP2i0tl0Q
            view.addSubview(frame)
            let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
            
            let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                                target: self,
                                                action: nil)
            
            let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(didTapDone))
            toolBar.items = [flexibleSpace, doneButton]
            toolBar.sizeToFit()
            frame.inputAccessoryView = toolBar
        }
        
        @objc private func didTapDone() {
            usernameField.resignFirstResponder()
            passwordField.resignFirstResponder()
            confirmPasswordField.resignFirstResponder()
        }
        
        @objc func keyboardWillShow(sender: NSNotification) {
            self.view.frame.origin.y = -150 // Move view 150 points upward
            
        }

        @objc func keyboardWillHide(sender: NSNotification) {
             self.view.frame.origin.y = 0 // Move view to original position
        }
}
