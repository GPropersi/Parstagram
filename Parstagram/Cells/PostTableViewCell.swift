//
//  PostTableViewCell.swift
//  Parstagram
//
//  Created by Giovanni Propersi on 2/26/22.
//

import UIKit
import AlamofireImage

protocol PostTableViewCellDelegator {
    func cellCallback(userPost: User)
}

class PostTableViewCell: UITableViewCell{
    
    var delegate: PostTableViewCellDelegator?

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

            // Round the corners
            profilePictureViewButton.layer.borderWidth = 1
            profilePictureViewButton.layer.masksToBounds = true
            profilePictureViewButton.layer.borderColor = UIColor.systemBackground.cgColor
            profilePictureViewButton.layer.cornerRadius = (profilePictureViewButton.layer.frame.height) / 2
            profilePictureViewButton.clipsToBounds = true

            profilePictureViewButton.isUserInteractionEnabled = true

        }
    }

    @IBAction func postUserButtonTapped(_ sender: Any) {
        self.delegate?.cellCallback(userPost: self.post.postAuthor)
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
