//
//  CommentTableViewCell.swift
//  Parstagram
//
//  Created by Giovanni Propersi on 3/5/22.
//

import UIKit
import Parse

// Protocol defined to send the user to the profile page for the author of the comment
protocol CommentCellDelegator {
    func callSegueFromCell(commentUser dataobject: User)
}

class CommentTableViewCell: UITableViewCell {

    var commentUser: PFUser?
    var delegate: CommentCellDelegator!
    
    @IBOutlet weak var commentField: UITextView!
    
        var commentData: PFObject! {
        didSet {
            
            commentField.delegate = self
            
            commentUser = commentData["author"] as? PFUser
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

extension CommentTableViewCell: UITextViewDelegate {
    
    // 10th add the textView's delegate method that activates urls. Make sure to return false for the tappable part

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        
         // 11th use the value from the 7th step to trigger the url inside this method
         if URL.absoluteString == "makeMeTappable" {
             
             if self.delegate != nil {
                 let commentUserForSegue = User.init(userObject: commentUser!)
                 self.delegate.callSegueFromCell(commentUser: commentUserForSegue)
             }
             
             return false
         }

         return true
     }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        textView.selectedTextRange = nil
    }

}
