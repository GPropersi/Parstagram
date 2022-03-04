//
//  UserProfileSettingsViewController.swift
//  Parstagram
//
//  Created by Giovanni Propersi on 3/3/22.
//

import UIKit
import Parse
import AlamofireImage

class UserProfileSettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var currentUser: User!

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var userSettingsError: UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        
        let navBarTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        self.navigationController?.navigationBar.titleTextAttributes = navBarTextAttributes

        // Create new alert for loading of user profile error
        userSettingsError = UIAlertController(title: "Alert", message : "", preferredStyle: .alert)

        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in return})
        
        //Add OK button to a dialog message
        userSettingsError.addAction(ok)
        

        // Do any additional setup after loading the view.
    }
    
    // MARK: - For when dark or light mode cycled, sets correct background colors

        override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
            let navBarTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
            self.navigationController?.navigationBar.titleTextAttributes = navBarTextAttributes
        }
    
    @IBAction func newUsernameButton(_ sender: Any) {
        
        guard let newUsername = usernameTextField.text, usernameTextField.hasText else {
            self.userSettingsError.message = "Error: Please Enter a New Username"
            self.present(self.userSettingsError, animated: true, completion: nil)
            return
        }

        // Set the new username
        PFUser.current()?.username = newUsername
        PFUser.current()?.saveInBackground { (success, error) in
            switch error {
            case .some(let error as NSError):
                self.userSettingsError.message = "Error: " + error.localizedDescription
                self.present(self.userSettingsError, animated: true, completion: nil)
                
            case .none:
                self.userSettingsError.message = "New Username Set!"
                self.present(self.userSettingsError, animated: true, completion: nil)
                self.usernameTextField.text?.removeAll()
            }
        }
    }
    
    @IBAction func newPasswordButton(_ sender: Any) {
        guard let newPassword = passwordTextField.text, passwordTextField.hasText else {
            self.userSettingsError.message = "Error: Please Enter a New Password"
            self.present(self.userSettingsError, animated: true, completion: nil)
            return
        }
        
        // Set the new password
        PFUser.current()?.password = newPassword
        PFUser.current()?.saveInBackground { (success, error) in
            switch error {
            case .some(let error as NSError):
                self.userSettingsError.message = "Error: " + error.localizedDescription
                self.present(self.userSettingsError, animated: true, completion: nil)
                
            case .none:
                self.userSettingsError.message = "New Password Set!"
                self.present(self.userSettingsError, animated: true, completion: nil)
                self.passwordTextField.text?.removeAll()
            }
        }
    }
    
    @IBAction func newProfilePictureButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af.imageScaled(to: size)
        
        let file = PFFileObject(name: "image.png", data: scaledImage.pngData()!)
        
        PFUser.current()?["profilePicture"] = file
        
        PFUser.current()?.saveInBackground { (success, error) in
            switch error {
            case .some(let error as NSError):
                self.userSettingsError.message = "Error: " + error.localizedDescription
                self.present(self.userSettingsError, animated: true, completion: nil)
                
            case .none:
                self.dismiss(animated: true, completion: nil)
                self.userSettingsError.message = "New Profile Picture Set!"
                self.present(self.userSettingsError, animated: true, completion: nil)
                self.passwordTextField.text?.removeAll()
            }
        }
    }
    

}