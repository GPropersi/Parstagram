//
//  CommentTableViewCell.swift
//  Parstagram
//
//  Created by Giovanni Propersi on 3/5/22.
//

import UIKit
import Parse
import AlamofireImage

// Protocol defined to send the user to the profile page for the author of the comment
protocol CommentCellDelegator {
    func callSegueFromCell(commentUser dataobject: User)
}

class CommentTableViewCell: UITableViewCell {

    var commentUser: PFUser?
    var commentUserForSegue: User!
    var delegate: CommentCellDelegator!
    
    @IBOutlet weak var commentProfilePicture: UIImageView!
    @IBOutlet weak var commentField: UITextView!
    
        var commentData: PFObject! {
        didSet {
            commentField.delegate = self
            
            commentUser = commentData["author"] as? PFUser
            commentUserForSegue = User.init(userObject: commentUser!)
            
            let commentUsername = commentUser?.username!
            let commentText = commentData["text"] as? String ?? ""

            // Create the non-tappable comment portion
            let regularText = NSMutableAttributedString(string: " " + commentText, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: UIColor.label])

            // Create the tappable Username portion
            let tappableText = NSMutableAttributedString(string: commentUsername!)
            tappableText.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 17), range: NSMakeRange(0, tappableText.length))
            tappableText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSMakeRange(0, tappableText.length))

            // Connect teh tappable link to the delegate method
            tappableText.addAttribute(NSAttributedString.Key.link, value: "makeMeTappable", range: NSMakeRange(0, tappableText.length))

//            // Append the tappable and untappable text
            tappableText.append(regularText)

//            // Set to the textview
            commentField.attributedText = tappableText
            
            // Set Image
            if commentUserForSegue.profilePicURL == nil {
                commentProfilePicture.image = UIImage(named: "coffee")
            } else {
                commentProfilePicture.af.setImage(withURL: (commentUserForSegue?.profilePicURL!)!)
            }
            
            // Round the corners
            commentProfilePicture.layer.borderWidth = 1
            commentProfilePicture.layer.masksToBounds = true
            commentProfilePicture.layer.borderColor = UIColor.systemBackground.cgColor
            commentProfilePicture.layer.cornerRadius = (commentProfilePicture.layer.frame.height) / 2
            commentProfilePicture.clipsToBounds = true
            
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            commentProfilePicture.isUserInteractionEnabled = true
            commentProfilePicture.addGestureRecognizer(tapGestureRecognizer)

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
    
    // Lets user segue to commenter's profile page by tapping on their profile picture
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if self.delegate != nil {
            self.delegate.callSegueFromCell(commentUser: commentUserForSegue!)
        }
    }

}

extension CommentTableViewCell: UITextViewDelegate {
    
    // Lets user segue to commenter's profile page by tapping on their username in the textview
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        
         // Set action on the tapped attributed string that has the given URL
         if URL.absoluteString == "makeMeTappable" {
             if self.delegate != nil {
                 self.delegate.callSegueFromCell(commentUser: commentUserForSegue!)
             }
             return false
         }
         return true
     }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        textView.selectedTextRange = nil
    }

}
