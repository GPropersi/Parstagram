//
//  UserProfileFromFeedViewController.swift
//  Parstagram
//
//  Created by Giovanni Propersi on 3/2/22.
//

import UIKit
import Parse
import AlamofireImage

class UserProfileFromFeedViewController: UIViewController {
    
    var postUser: User!

    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var userProfilePicture: UIImageView!
    @IBOutlet weak var postNumber: UILabel!
    @IBOutlet weak var userFromFeedPostsCollectionView: UICollectionView!
    
    var userPosts = [Post]()
    var userFromFeedError: UIAlertController!
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userFromFeedPostsCollectionView.delegate = self
        userFromFeedPostsCollectionView.dataSource = self
        
        // Create new alert for loading of user profile error
        userFromFeedError = UIAlertController(title: "Alert", message : "", preferredStyle: .alert)

        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in return})
        
        //Add OK button to a dialog message
        userFromFeedError.addAction(ok)
        
        // Set Username
        username.text = postUser?.username!
        
        // Set Image
        if postUser.profilePicURL == nil {
            userProfilePicture.image = UIImage(named: "coffee")
        } else {
            userProfilePicture.af.setImage(withURL: postUser.profilePicURL!)
        }
        
        
        // Set circular border
        userProfilePicture.layer.borderWidth = 1
        userProfilePicture.layer.masksToBounds = false
        userProfilePicture.layer.borderColor = UIColor.systemBackground.cgColor
        userProfilePicture.layer.cornerRadius = userProfilePicture.frame.height/2
        userProfilePicture.clipsToBounds = true
        
        // Define the layout properties for the Collection View. Want 3 across, with a divider in between each post
        let layout = userFromFeedPostsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 4
        
        // Account for the two vertical dividers
        let width = (view.frame.size.width - (layout.minimumInteritemSpacing * 2)) / 3
        
        // Defines size of each post grid
        layout.itemSize = CGSize(width: width, height: width)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadUser()
    }
    
    // MARK: - For when dark or light mode cycled, sets correct background colors
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        userProfilePicture.layer.borderColor = UIColor.systemBackground.cgColor
    }
    
    // MARK: - Load the user's data and put it in collection view

    func loadUser() {
        
        userPosts.removeAll()
        let query = PFQuery(className: "Posts")
        query.includeKey("author")
        query.order(byDescending: "createdAt")
        query.whereKey("author", equalTo: postUser.userObjectForPF!)

        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if let error = error {
                // Log details of the failure
                self.userFromFeedError.message = "Error: " + error.localizedDescription
                self.present(self.userFromFeedError, animated: true, completion: nil)
            } else if let objects = objects {
                // The find succeeded.
                self.postNumber.text = "\(objects.count)"
                // Do something with the found objects
                for object in objects {
                    self.userPosts.append(Post.init(postObject: object))
                }
                
                self.userFromFeedPostsCollectionView.reloadData()
            }
        }
    }
}

// MARK: - Collection view protocol stubs
    
extension UserProfileFromFeedViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.userPosts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserFromFeedCollectionViewCell", for: indexPath) as! UserFromFeedCollectionViewCell
        
        let userPost = userPosts[indexPath.item]
        cell.userFromFeedPostImageView.af.setImage(withURL: userPost.postImageURL!)
        return cell
    }
}
