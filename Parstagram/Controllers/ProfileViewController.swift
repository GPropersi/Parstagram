//
//  ProfileViewController.swift
//  Parstagram
//
//  Created by Giovanni Propersi on 2/27/22.
//

import UIKit
import Parse
import AlamofireImage
import MBProgressHUD

class ProfileViewController: UIViewController {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profilePicView: UIImageView!
    @IBOutlet weak var postNumberLabel: UILabel!
    @IBOutlet weak var userPostsCollectionView: UICollectionView!
    
    var userPosts = [Post]()
    var profileError: UIAlertController!
    var userID : String?
    var currentUser: User!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userPostsCollectionView.delegate = self
        userPostsCollectionView.dataSource = self
        
        // Define the layout properties for the Collection View. Want 3 across, with a divider in between each post
        let layout = userPostsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 4
        
        // Account for the two vertical dividers
        let width = (view.frame.size.width - (layout.minimumInteritemSpacing * 2)) / 3
        
        // Defines size of each post grid
        layout.itemSize = CGSize(width: width, height: width)
        
        // Create new alert for loading of profile page error
        profileError = UIAlertController(title: "Alert", message : "", preferredStyle: .alert)

        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in return})
        
        //Add OK button to a dialog message
        profileError.addAction(ok)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        
        let navBarTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.label]
        self.navigationController?.navigationBar.titleTextAttributes = navBarTextAttributes
        
        currentUser = User.init(userObject: PFUser.current()!)
        userID = currentUser.userID
        usernameLabel.text = currentUser.username
        
        // Set Image
        if currentUser.profilePicURL == nil {
            profilePicView.image = UIImage(named: "coffee")
        } else {
            profilePicView.af.setImage(withURL: currentUser.profilePicURL!)
        }
        
        // Set circular border
        profilePicView.layer.borderWidth = 1
        profilePicView.layer.masksToBounds = false
        profilePicView.layer.borderColor = UIColor.systemBackground.cgColor
        profilePicView.layer.cornerRadius = profilePicView.frame.height/2
        profilePicView.clipsToBounds = true
        
        let userPostCount = UserDefaults.standard.integer(forKey: "userPostCount")
        postNumberLabel.text = "\(userPostCount)"
        loadPosts()
    }
    
    // MARK: - For when dark or light mode cycled, sets correct background colors
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        profilePicView.layer.borderColor = UIColor.systemBackground.cgColor
    }
    
    // MARK: - IB Actions
    
    @IBAction func logoutUser(_ sender: Any) {
        PFUser.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let delegate = windowScene.delegate as? SceneDelegate else { return }
        
        delegate.window?.rootViewController = loginViewController

    }
    
    // MARK: - Load only the current user's posts and show in collection view
    
    func loadPosts() {
        let numberOfPosts = 20

        let query = PFQuery(className: "Posts")
        query.includeKey("author")
        query.order(byDescending: "createdAt")
        query.whereKey("author", equalTo: PFUser.current()!)
        query.limit = numberOfPosts
        
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
                self.userPosts.removeAll()
                for singlePost in posts! {
                    self.userPosts.append(Post.init(postObject: singlePost))
                }
                self.userPostsCollectionView.reloadData()
                MBProgressHUD.hide(for: self.view, animated: true)

            } else {
                switch error {
                case .some(let error as NSError):
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.profileError.message = "Error: " + error.localizedDescription
                    self.present(self.profileError, animated: true, completion: nil)

                case .none:
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.profileError.message = "Error: Something went wrong"
                    self.present(self.profileError, animated: true, completion: nil)
                }
            }
        }
    }


    // MARK: - Segue to User Profile Settings
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUserProfileSettings" {
            let userSettingsView = segue.destination as! UserProfileSettingsViewController
            userSettingsView.currentUser = self.currentUser
        }
    }
}

// MARK: - Collection view protocol stubs

extension ProfileViewController:  UICollectionViewDataSource, UICollectionViewDelegate {
    
    
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
