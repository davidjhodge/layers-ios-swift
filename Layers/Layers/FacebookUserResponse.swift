//
//  FacebookUserResponse.swift
//  Layers
//
//  Created by David Hodge on 4/16/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import ObjectMapper

class FacebookUserResponse: NSObject, Mappable
{
    var userID: String?
    
    var name: String?
    
    var firstName: String?
    
    var lastName: String?
    
    var email: String?
    
    var link: String?
    
    var gender: String?
    
    var locale: String?
    
    var profilePictureURL: String?
    
    var timezone: Int?
    
    var updatedTime: String?
    
    var verified: Bool?
    
    var friendsUsingApp: Array<AnyObject>?
    
    var friendCount: Int?
    
    var ageRange: AgeRange?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        userID              <-  map["id"]
        name                <-  map["name"]
        firstName           <-  map["first_name"]
        lastName            <-  map["last_name"]
        email               <-  map["email"]
        link                <-  map["link"]
        gender              <-  map["gender"]
        locale              <-  map["locale"]
        profilePictureURL   <-  map["picture"]["data"]["url"]
        timezone            <-  map["timezone"]
        updatedTime         <-  map["updated_time"]
        verified            <-  map["verified"]
        friendsUsingApp     <-  map["friends"]["data"]
        friendCount         <-  map["friends"]["summary"]
        ageRange            <-  map["age_range"]
        
    }
}
