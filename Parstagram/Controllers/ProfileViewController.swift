//
//  ProfileViewController.swift
//  Parstagram
//
//  Created by Giovanni Propersi on 2/27/22.
//

import UIKit
import Parse

class ProfileViewController: UIViewController {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profilePicView: UIImageView!
    @IBOutlet weak var postNumberLabel: UILabel!
    
    var userPosts = [Post]()
    var profileError: UIAlertController!
    var userID : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userPostCount = UserDefaults.standard.integer(forKey: "userPostCount")
        postNumberLabel.text = "\(userPostCount)"
        
        let currentUser = User.init(userObject: PFUser.current()!)
        userID = currentUser.userID
        usernameLabel.text = currentUser.username
        
        // Set Image
        profilePicView.af.setImage(withURL: currentUser.profilePicURL!)
        
        // Set circular border
        profilePicView.layer.borderWidth = 1
        profilePicView.layer.masksToBounds = false
        profilePicView.layer.borderColor = UIColor.white.cgColor
        profilePicView.layer.cornerRadius = profilePicView.frame.height/2
        profilePicView.clipsToBounds = true
        
        // Create new alert for loading of tweets error
        profileError = UIAlertController(title: "Alert", message : "", preferredStyle: .alert)

        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in return})
        
        //Add OK button to a dialog message
        profileError.addAction(ok)
        
        
        

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadPosts()
    }
    
//    func loadUser() {
//        PFUser.current()
//        let userID = UserDefaults.standard.string(forKey: "loggedInUser")
//        let query = PFQuery(className: "User")
//        query.whereKey("objectId", equalTo: userID!)
//
//        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
//            if let error = error {
//                // Log details of the failure
//                print(error.localizedDescription)
//            } else if let objects = objects {
//                // The find succeeded.
//                print("Successfully retrieved \(objects.count) scores.")
//                // Do something with the found objects
//                for object in objects {
//                    print(object.objectId as Any)
//                }
//            }
//        }
//
//    }
//
    func loadPosts() {
        let numberOfPosts = 20

        let query = PFQuery(className: "Posts")
        query.includeKey("author")
        query.order(byDescending: "createdAt")
        query.whereKey("author", equalTo: PFUser.current()!)
        query.limit = numberOfPosts
        

        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
                self.userPosts.removeAll()
                for singlePost in posts! {
                    self.userPosts.append(Post.init(postObject: singlePost))
                }
//                self.postNumberLabel.text = "\(self.userPosts.count)"
                //self.postTableView.reloadData()
                //self.postRefreshControl.endRefreshing()

            } else {
                switch error {
                case .some(let error as NSError):
                    self.profileError.message = "Error: " + error.localizedDescription
                    self.present(self.profileError, animated: true, completion: nil)

                case .none:
                    self.profileError.message = "Error: Something went wrong"
                    self.present(self.profileError, animated: true, completion: nil)
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
