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

            // 4th create the first piece of the string you don't want to be tappable
            let regularText = NSMutableAttributedString(string: commentText, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17), NSAttributedString.Key.foregroundColor: UIColor.black])

            // 5th create the second part of the string that you do want to be tappable. I used a blue color just so it can stand out.
            let tappableText = NSMutableAttributedString(string: commentUsername!)
            tappableText.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 17), range: NSMakeRange(0, tappableText.length))
            tappableText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSMakeRange(0, tappableText.length))

            // 7th this is the important part that connects the tappable link to the delegate method in step 11
            // use NSAttributedString.Key.link and the value "makeMeTappable" to link the NSAttributedString.Key.link to the method. FYI "makeMeTappable" is a name I choose for clarity, you can use anything like "anythingYouCanThinkOf"
            tappableText.addAttribute(NSAttributedString.Key.link, value: "makeMeTappable", range: NSMakeRange(0, tappableText.length))

//            // 8th *** important append the tappableText to the regularText ***
            tappableText.append(regularText)

//            // 9th set the regularText to the textView's attributedText property
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
