//
//  Size.swift
//  Layers
//
//  Created by David Hodge on 5/1/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import ObjectMapper

class Size: Mappable
{
    var sizeTitle: String?
    
    var specificId: String?
    
    var inStock: Bool?
    
    var prices: Array<Price>?
    
    var altPricing: AlternatePricing?
    
//    var sizeDetails:
    
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map)
    {
        sizeTitle                   <- map["size_title"]
        specificId                  <- map["specific_id"]
        inStock                     <- map["in_stock"]
        prices                      <- map["prices"]
        altPricing                  <- map["alt_pricing.0"]
    }
}