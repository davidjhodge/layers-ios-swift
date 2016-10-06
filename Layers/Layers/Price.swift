//
//  Price.swift
//  Layers
//
//  Created by David Hodge on 9/4/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit
import ObjectMapper

class Price: Mappable
{
    var currency: String?
    
    var price: NSNumber?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        currency           <-  map["currency"]
        price              <-  map["price"]
    }
}
