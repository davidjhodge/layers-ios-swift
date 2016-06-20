//
//  BrandResponse.swift
//  Layers
//
//  Created by David Hodge on 5/31/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import ObjectMapper

class BrandResponse: Mappable
{
    var brandName: String?
    
    var brandId: NSNumber?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        brandName        <-  map["brand_name"]
        brandId          <- map["id"]
    }
}