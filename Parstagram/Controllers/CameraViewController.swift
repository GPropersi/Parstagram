//
//  CameraViewController.swift
//  Parstagram
//
//  Created by Giovanni Propersi on 2/26/22.
//

import UIKit
import AlamofireImage
import Parse

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var newImageView: UIImageView!
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    var cameraViewError: UIAlertController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Button disabled until user selects a photo
        submitButton.isEnabled = false
        
        // Create new alert for loading of tweets error
        cameraViewError = UIAlertController(title: "Alert", message : "", preferredStyle: .alert)

        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in return})
        
        //Add OK button to a dialog message
        cameraViewError.addAction(ok)

        // Do any additional setup after loading the view.
    }

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
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
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
