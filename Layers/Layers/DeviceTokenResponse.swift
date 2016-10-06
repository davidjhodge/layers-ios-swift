//
//  DeviceTokenResponse.swift
//  Layers
//
//  Created by David Hodge on 6/30/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import ObjectMapper

class DeviceTokenResponse: Mappable
{
    var accessToken: String?
    
    var refreshToken: String?
    
    var expirationDate: Date?
    
    var isAnonymous: Bool?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        accessToken     <- map["access_token"]
        refreshToken    <- map["refresh_token"]
        expirationDate  <- (map["expires_at"], DateTransform())
        isAnonymous     <- map["is_anonymous"]
    }
}
