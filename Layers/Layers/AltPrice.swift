//
//  AltPrice.swift
//  Layers
//
//  Created by David Hodge on 9/4/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit
import ObjectMapper

class AltPrice: Mappable
{
    var currency: String?
    
    var salePrice: NSNumber?
    
    var percentOff: NSNumber?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        currency           <-  map["currency"]
        salePrice          <-  map["sale_price"]
        percentOff         <-  map["percent_change"]
    }
}
