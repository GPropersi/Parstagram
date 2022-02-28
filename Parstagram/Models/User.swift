//
//  User.swift
//  Parstagram
//
//  Created by Giovanni Propersi on 2/27/22.
//

import Foundation
import Parse

struct User {
    var profilePicURL: URL?
    var username: String?
    var userID: String?
    
    init(userObject: PFUser) {
        username = userObject.username!
        userID = userObject.objectId!
        
        let imageFile = userObject["profilePicture"] as! PFFileObject
        profilePicURL = URL(string: imageFile.url!)
    }
}
