//
//  Retailer.swift
//  Layers
//
//  Created by David Hodge on 9/4/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit
import ObjectMapper

class Retailer: Mappable
{
    var retailerId: String?
    
    var name: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        retailerId           <-  map["id"]
        name                 <-  map["name"]
    }
}
