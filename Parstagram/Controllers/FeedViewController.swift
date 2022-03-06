//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Giovanni Propersi on 2/26/22.
//

import UIKit
import Parse
import AlamofireImage

class FeedViewController: UIViewController {

    @IBOutlet weak var postTableView: UITableView!
    
    var posts = [Post]()
    var numberOfPosts: Int!
    var feedError: UIAlertController!
    
    let postRefreshControl = UIRefreshControl()
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postTableView.delegate = self
        postTableView.dataSource = self
        postTableView.separatorColor = UIColor.systemGray
        
        // Create new alert for loading of posts error
        feedError = UIAlertController(title: "Alert", message : "", preferredStyle: .alert)

        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in return})
        
        //Add OK button to a dialog message
        feedError.addAction(ok)
        
        postRefreshControl.addTarget(self, action: #selector(loadPosts), for: .valueChanged)
        postTableView.refreshControl = postRefreshControl
        
        // Absolutely necessary to estimate the row height or else the Constraint erors are numerous and cumbersome
        postTableView.estimatedRowHeight = CGFloat(500)

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.tabBar.isHidden = false
        self.loadPosts()
        
    }
    
    // MARK: - For when dark or light mode cycled, sets correct background colors
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        postTableView.reloadData()
    }
    
    // MARK: - IBActions

    @IBAction func onLogout(_ sender: Any) {
        PFUser.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let delegate = windowScene.delegate as? SceneDelegate else { return }
        
        delegate.window?.rootViewController = loginViewController
    }
    
    // MARK: - Get user post count to avoid load on profile tab press
    
    func getUserPostCount() {
        let currentUser = PFUser.current()!
        let query = PFQuery(className:"Posts")
        query.whereKey("author", equalTo: currentUser)
        query.countObjectsInBackground { (count: Int32, error: Error?) in
            if let _ = error {
                self.feedError.message = "Error: Something went wrong"
                self.present(self.feedError, animated: true, completion: nil)
            } else {
                UserDefaults.standard.set(count, forKey: "userPostCount")
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    // MARK: - Navigation, prepare for segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination
        // Pass the selected object to the new view controller.
        if segue.identifier == "userFromPost" {
            // Grab the User who owns this post
            let postUser = sender as! User
            
            let userProfileFromFeedViewController = segue.destination as! UserProfileFromFeedViewController
            userProfileFromFeedViewController.postUser = postUser
        }
        
    }

}

// MARK: - Loading posts into the feed, on load and refresh

extension FeedViewController {
        
        // As user enters this view controller, and as user pulls to refresh
        @objc func loadPosts() {
            numberOfPosts = 20
            
            let query = PFQuery(className: "Posts")
            query.includeKeys(["author", "comments", "comments.author"])
            query.order(byDescending: "createdAt")
            query.limit = numberOfPosts
            
            query.findObjectsInBackground { (posts, error) in
                if posts != nil {
                    self.posts.removeAll()
                    for singlePost in posts! {
                        self.posts.append(Post.init(postObject: singlePost))
                    }
                    self.postTableView.reloadData()
                    self.postRefreshControl.endRefreshing()
                    self.postTableView.rowHeight = UITableView.automaticDimension
                    
                    self.getUserPostCount()
                    
                } else {
                    switch error {
                    case .some(let error as NSError):
                        self.feedError.message = "Error: " + error.localizedDescription
                        self.present(self.feedError, animated: true, completion: nil)
                        
                    case .none:
                        self.feedError.message = "Error: Something went wrong"
                        self.present(self.feedError, animated: true, completion: nil)
                    }
                }
            }
        }
        
        // As user scrolls to bottom, infinite reload of posts
        func loadMorePosts() {
            numberOfPosts += 20
            
            let query = PFQuery(className: "Posts")
            query.includeKeys(["author", "comments", "comments.author"])
            query.order(byDescending: "createdAt")
            query.limit = numberOfPosts
            
            query.findObjectsInBackground { (posts, error) in
                if posts != nil {
                    self.posts.removeAll()
                    for singlePost in posts! {
                        self.posts.append(Post.init(postObject: singlePost))
                    }
                    self.postTableView.reloadData()
                    
                } else {
                    switch error {
                    case .some(let error as NSError):
                        self.feedError.message = "Error: " + error.localizedDescription
                        self.present(self.feedError, animated: true, completion: nil)
                        
                    case .none:
                        self.feedError.message = "Error: Something went wrong"
                        self.present(self.feedError, animated: true, completion: nil)
                    }
                }
            }
        }
}

// MARK: - Table and cell protocol functions, and protocol functions for user profile from feed

extension FeedViewController:  UITableViewDelegate, UITableViewDataSource, PostTableViewCellDelegator {
    
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 1 for the picture, + number of comments
        let post = posts[section]
        let comments = (post.postOriginal!["comments"] as? [PFObject]) ?? []
        return 1 + comments.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = (post.postOriginal!["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell") as! PostTableViewCell
            
            cell.delegate = self
            cell.post = post
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell") as! CommentTableViewCell
            
            let comment = comments[indexPath.row - 1]
            let commentAuthor = comment["author"] as! PFUser
            
            cell.usernameLabel.text = commentAuthor.username!
            cell.commentLabel.text = comment["text"] as? String
            
            return cell
        }
    }
    
    func cellCallback(userPost: User) {
        // Perform the segue with the attached cell's user
        self.performSegue(withIdentifier: "userFromPost", sender: userPost)
    }
    
    // Refreshes the tableview when user hits the bottom.
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == posts.count {
            loadMorePosts()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        
        let comment = PFObject(className: "Comments")
        comment["text"] = "This is the best comment."
        comment["post"] = post.postOriginal!
        comment["author"] = PFUser.current()
        
        post.postOriginal!.add(comment, forKey: "comments")
        
        post.postOriginal?.saveInBackground { (success, error) in
            if success {
                print("Comment saved")
            } else {
                print("Error saving comment.")
            }
        }
        
    }
    
}
