//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Giovanni Propersi on 2/26/22.
//

import UIKit
import Parse
import AlamofireImage

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var postTableView: UITableView!
    
    var posts = [Post]()
    var numberOfPosts: Int!
    var feedError: UIAlertController!
    
    let postRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postTableView.delegate = self
        postTableView.dataSource = self
        
        // Create new alert for loading of tweets error
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
        self.loadPosts()
        
    }
    
// MARK: - Loads posts on load and refresh
    
    @objc func loadPosts() {
        numberOfPosts = 20
        
        let query = PFQuery(className: "Posts")
        query.includeKey("author")
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
    
// MARK: - Load more posts as user scrolls to bottom
    
    func loadMorePosts() {
        numberOfPosts += 20
        
        let query = PFQuery(className: "Posts")
        query.includeKey("author")
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
    
    // Refreshes the tableview when user hits the bottom.
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == posts.count {
            loadMorePosts()
        }
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
    
// MARK: - Table protocol functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostTableViewCell") as! PostTableViewCell
        
        cell.post = posts[indexPath.row]
                       
        return cell
    }
    

    // MARK: - Navigation, prepare for segue
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination
//        // Pass the selected object to the new view controller.
//
//        let cell = sender as! UITableViewCell
//        let indexPath = postTableView.indexPath(for: cell)!
//        print(cell)
//        let movie = movies[indexPath.row]
//
//        // Pass movie dictionary to MovieDetailsViewController
//        let detailsViewController = segue.destination as! MovieDetailsViewController
//        detailsViewController.movie = movie
//
//        // Remove the highlighted selection
//        tableView.deselectRow(at: indexPath, animated: true)
//    }

}
