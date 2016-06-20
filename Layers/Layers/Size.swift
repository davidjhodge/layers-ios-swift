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
    
    var price: Price?
    
    var altPrice: AlternatePricing?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map)
    {
        sizeTitle                   <- map["size_title"]
        specificId                  <- map["specific_id"]
        inStock                     <- map["in_stock"]
        price                       <- map["prices.0"]
        altPrice                    <- map["alt_pricing.0"]
    }
}