//
//  Errors.swift
//  Parstagram
//
//  Created by Giovanni Propersi on 2/26/22.
//

import UIKit

struct UserErrorResponse: Error {
    
    let code: Int
    let message: String
    
    init(errorMessage: NSDictionary) {
        print("Here")
        self.code = errorMessage["code"] as! Int
        self.message = errorMessage["message"] as! String
        
    }
    
}
