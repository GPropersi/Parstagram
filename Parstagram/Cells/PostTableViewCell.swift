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
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var profilePictureViewButton: UIButton!
    
    var photoTest: UIImageView!
    
    var post: Post! {
        didSet {
            let usernameAttributes = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 19)]
            let usernameAttributedString = NSMutableAttributedString(string: post.postAuthor.username!, attributes:usernameAttributes)
            
            // Set username to bold
            usernameButton.setAttributedTitle(usernameAttributedString, for: .selected)
            usernameButton.setAttributedTitle(usernameAttributedString, for: .normal)
            usernameButton.isUserInteractionEnabled = true
            captionLabel.attributedText = post.getAttributedCaption()
            photoView.af.setImage(withURL: post.postImageURL!)
            postedAt.text = post.getTimeSincePosted()
            
            // Set Image
            profilePictureViewButton.af.setBackgroundImage(for: .normal, url: post.postAuthor.profilePicURL!)

            // Set circular border
            profilePictureViewButton.layer.borderWidth = 1
            profilePictureViewButton.layer.masksToBounds = false
            profilePictureViewButton.layer.borderColor = UIColor.white.cgColor
            profilePictureViewButton.layer.cornerRadius = (profilePictureViewButton.imageView?.frame.height)!/2
            profilePictureViewButton.clipsToBounds = true

            profilePictureViewButton.isUserInteractionEnabled = true

        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: true)

        // Configure the view for the selected state
    }

}
