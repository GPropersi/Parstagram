//
//  ProfileViewController.swift
//  Parstagram
//
//  Created by Giovanni Propersi on 2/27/22.
//

import UIKit
import Parse
import AlamofireImage

class ProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profilePicView: UIImageView!
    @IBOutlet weak var postNumberLabel: UILabel!
    @IBOutlet weak var userPostsCollectionView: UICollectionView!
    
    var userPosts = [Post]()
    var profileError: UIAlertController!
    var userID : String?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userPostsCollectionView.delegate = self
        userPostsCollectionView.dataSource = self
        
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
        
        // Define the layout properties for the Collection View. Want 3 across, with a divider in between each movie
        let layout = userPostsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 4
        
        // Account for the two vertical dividers
        let width = (view.frame.size.width - (layout.minimumInteritemSpacing * 2)) / 3
        
        // Defines size of each movie grid
        layout.itemSize = CGSize(width: width, height: width)
        
        // Create new alert for loading of tweets error
        profileError = UIAlertController(title: "Alert", message : "", preferredStyle: .alert)

        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in return})
        
        //Add OK button to a dialog message
        profileError.addAction(ok)
        
        loadPosts()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - IB Actions
    
    @IBAction func logoutUser(_ sender: Any) {
        PFUser.logOut()
        self.performSegue(withIdentifier: "unwindToLogin", sender: self)

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
    
// MARK: - Load the current user's posts only
    
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
                self.userPostsCollectionView.reloadData()

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

    // MARK: - Collection view protocol stubs
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.userPosts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserProfilePostCollectionViewCell", for: indexPath) as! UserProfilePostCollectionViewCell
        
        let userPost = userPosts[indexPath.item]

        cell.currentUserPostImageView.af.setImage(withURL: userPost.postImageURL!)
        
        return cell
    }


}
