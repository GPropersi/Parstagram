//
//  CameraViewController.swift
//  Parstagram
//
//  Created by Giovanni Propersi on 2/26/22.
//

import UIKit
import AlamofireImage
import Parse

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var newImageView: UIImageView!
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    var cameraViewError: UIAlertController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentField.delegate = self
        addDoneToKeyboard(commentField)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil);

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil);
        
        // Button disabled until user selects a photo
        submitButton.isEnabled = false
        
        // Create new alert for loading of camera view error
        cameraViewError = UIAlertController(title: "Alert", message : "", preferredStyle: .alert)

        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in return})
        
        //Add OK button to a dialog message
        cameraViewError.addAction(ok)

        // Do any additional setup after loading the view.
    }
    
// MARK: - IB Actions

    /**
     Converts the displayed image to a binary file. Captures the current user and the user's supplied caption, and sends all to Parse backend.
     
     - Parameter sender: Tap of the image view
     
     - Throws error, if image could not be saved
     */
    @IBAction func onSubmitImageButton(_ sender: Any) {
        let post = PFObject(className: "Posts")
        
        post["caption"] = commentField.text
        post["author"] = PFUser.current()!
        
        let imageData = newImageView.image!.pngData()
        let file = PFFileObject(name: "image.png", data: imageData!)
        
        post["image"] = file
        
        post.saveInBackground { (success, error) in
            switch error {
            case .some(let error as NSError):
                self.cameraViewError.message = "Error: " + error.localizedDescription
                self.present(self.cameraViewError, animated: true, completion: nil)
                
            case .none:
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        
    }
    
// MARK: - Keyboard functions added for textfield, including DONE button
    
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
        commentField.resignFirstResponder()
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -150 // Move view 150 points upward
        self.navigationController?.isNavigationBarHidden = true
    }

    @objc func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0 // Move view to original position
        self.navigationController?.isNavigationBarHidden = false
    }

// MARK: - Camera image functions
    
    @IBAction func onCameraButton(_ sender: Any) {
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
        
        newImageView.image = scaledImage
        submitButton.isEnabled = true
        
        dismiss(animated: true, completion: nil)
    }
    
}
