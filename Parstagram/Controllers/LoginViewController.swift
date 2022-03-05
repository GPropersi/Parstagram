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
        
        usernameField.delegate = self
        passwordField.delegate = self
        
        addDoneToKeyboard(usernameField)
        addDoneToKeyboard(passwordField)
        
        // Create new alert for loading of login error
        loginError = UIAlertController(title: "Alert", message : "", preferredStyle: .alert)

        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in return})
        
        //Add OK button to a dialog message
        loginError.addAction(ok)
        
        // Set keyboard to be below textfield
        /// https://stackoverflow.com/questions/25693130/move-textfield-when-keyboard-appears-swift
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil);

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil);
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
        // https://stackoverflow.com/questions/30052587/how-can-i-go-back-to-the-initial-view-controller-in-swift
    }
}

// MARK: - Keyboard functions to be below textfield, and adding Done button

extension LoginViewController: UITextFieldDelegate {
    
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
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
         self.view.frame.origin.y = -150 // Move view 150 points upward
    }

    @objc func keyboardWillHide(sender: NSNotification) {
         self.view.frame.origin.y = 0 // Move view to original position
    }
}
