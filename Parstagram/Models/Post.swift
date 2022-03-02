//
//  Post.swift
//  Parstagram
//
//  Created by Giovanni Propersi on 2/27/22.
//

import Foundation
import Parse

struct Post {
    var postImageURL: URL?
    var postAuthor: User
    var postAuthorUsername: String?
    var postCaption: String?
    var postedAt: Date?
    
    init(postObject: PFObject) {
        postAuthor = User.init(userObject: postObject["author"] as! PFUser)
        postAuthorUsername = postAuthor.username!
        postedAt = postObject.createdAt
        postCaption = postObject["caption"] as? String ?? ""
        
        let imageFile = postObject["image"] as! PFFileObject
        postImageURL = URL(string: imageFile.url!)
    }
    
    
    /**
     Converts the username and caption of a given post into an attributed string where the username is bolded, given two trailing spaces, followed
     by the caption of the photo. Uses postAuthorUsername (String) and postCaption (String) to generate the AttributedString.
     
     - Returns postCaptionAttributedString: The combined attributed string
     */
    func getAttributedCaption() -> NSMutableAttributedString {
        let username = self.postAuthorUsername!
        let caption = "  " + self.postCaption!
        
        let usernameAttributes = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 19)]
        let usernameAndCaptionAttributedString = NSMutableAttributedString(string: username, attributes:usernameAttributes)
        
        let captionAttributed = NSMutableAttributedString(string: caption)
        
        usernameAndCaptionAttributedString.append(captionAttributed)
        
        return usernameAndCaptionAttributedString
    }
    
    /**
     Converts the time since created (Date) to a time interval between the current time. Return value can change depending on if the post was posted within the last minute, hour, or day, i.e. 2 seconds ago, 2 hours ago, 2 days ago.
     
     - Returns timeSincePost - String in correct formatting depending on time since post
     */
    func getTimeSincePosted() -> String {
        let timeSincePostTimeFormatter = DateFormatter()
        timeSincePostTimeFormatter.locale = Locale(identifier: "en_US_POSIX")
        timeSincePostTimeFormatter.dateFormat = "E MMM dd HH:mm:ss Z yyyy"
        
        let timeDifferenceInSec = Double(self.postedAt!.timeIntervalSinceNow) * -1
        
        // convert from seconds to hours, rounding down to the nearest hour
        let minutes = floor(timeDifferenceInSec / 60)
        let hours = floor(minutes / 60)
        let days = floor(hours / 24)
        
        let timeTuple = (Int(days), Int(hours), Int(minutes), Int(timeDifferenceInSec))
        
        switch timeTuple {
        case (1..., _, _, _):
            switch Int(days) {
            case 1:
                return "\(Int(days)) day ago"
            default:
                return "\(Int(days)) days ago"
            }
            
        case (_, 1...24, _, _):
            switch Int(hours) {
            case 1:
                return "\(Int(hours)) hour ago"
            default:
                return "\(Int(hours)) hours ago"
            }
            
        case (_, _, 1...60, _):
            switch Int(minutes) {
            case 1:
                return "\(Int(minutes)) minute ago"
            default:
                return "\(Int(minutes)) minutes ago"
            }
            
        case (_, _, _, 1...60):
            switch Int(timeDifferenceInSec) {
            case 1:
                return "\(Int(timeDifferenceInSec)) second ago"
            default:
                return "\(Int(timeDifferenceInSec)) seconds ago"
            }
            
        default:
            return "0 seconds ago"
        }
        
    }
    
}
