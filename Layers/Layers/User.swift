//
//  User.swift
//  Layers
//
//  Created by David Hodge on 4/9/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import ObjectMapper

class User: AnyObject, Mappable
{
//    var userID: String?
    
    var email: String?
    
    var gender: String?
    
    var age: String?
    
    var firstName: String?
    
    var lastName: String?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map)
    {
        email                   <- map["email"]
        firstName               <- map["first_name"]
        lastName                <- map["last_name"]
        gender                  <- map["gender"]
        age                     <- map["age"]
    }
}