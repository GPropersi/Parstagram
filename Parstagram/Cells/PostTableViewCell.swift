//
//  PostTableViewCell.swift
//  Parstagram
//
//  Created by Giovanni Propersi on 2/26/22.
//

import UIKit
import AlamofireImage

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var postedAt: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profilePictureView: UIImageView!
    
    var post: Post! {
        didSet {
            usernameLabel.text = post.postAuthor.username!
            captionLabel.attributedText = post.getAttributedCaption()
            photoView.af.setImage(withURL: post.postImageURL!)
            postedAt.text = post.getTimeSincePosted()
            
            // Set Image
            profilePictureView.af.setImage(withURL: post.postAuthor.profilePicURL!)
            
            // Set circular border
            profilePictureView.layer.borderWidth = 1
            profilePictureView.layer.masksToBounds = false
            profilePictureView.layer.borderColor = UIColor.white.cgColor
            profilePictureView.layer.cornerRadius = profilePictureView.frame.height/2
            profilePictureView.clipsToBounds = true

        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
