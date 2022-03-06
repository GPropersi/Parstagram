//
//  User.swift
//  Parstagram
//
//  Created by Giovanni Propersi on 2/27/22.
//

import Foundation
import Parse
import UIKit

struct User {
    var profilePicURL: URL?
    var username: String?
    var userID: String?
    var userObjectForPF: PFUser?
    var defaultImage: UIImage?
    
    init(userObject: PFUser) {
        username = userObject.username!
        userID = userObject.objectId!
        userObjectForPF = userObject
        defaultImage = UIImage(named: "coffee")
        
        if let imageFile = userObject["profilePicture"] as? PFFileObject {
            profilePicURL = URL(string: imageFile.url!)
        } else {
            profilePicURL = nil
        }
        
//        let imageFile = userObject["profilePicture"] as? PFFileObject ?? nil
//        profilePicURL = URL(string: imageFile.url!)
    }
}
