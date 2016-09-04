//
//  NotificationResponse.swift
//  Layers
//
//  Created by David Hodge on 9/3/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit
import ObjectMapper

class NotificationResponse: Mappable {

    var userImageUrl: NSURL?
    
    var userName: String?
    
    var timestamp: NSDate?
    
    var productImageUrl: NSURL?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        userImageUrl        <-  map["user_image_url"]
        userName            <-  map["user_name"]
        timestamp           <-  map["timestamp"]
        productImageUrl     <-  map["product_image_url"]
    }
}
