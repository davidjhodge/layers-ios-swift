//
//  Brand.swift
//  Layers
//
//  Created by David Hodge on 9/4/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit
import ObjectMapper

class Brand: Mappable
{
    var brandId: NSNumber?
    
    var name: String?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        brandId              <-  map["id"]
        name                 <-  map["name"]
    }
}
