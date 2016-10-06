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

    var userImageUrl: URL?
    
    var userName: String?
    
    var timestamp: Date?
    
    var productImageUrl: URL?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        
        userImageUrl        <-  map["user_image_url"]
        userName            <-  map["user_name"]
        timestamp           <-  map["timestamp"]
        productImageUrl     <-  map["product_image_url"]
    }
}
