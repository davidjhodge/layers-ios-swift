//
//  Price.swift
//  Layers
//
//  Created by David Hodge on 5/1/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import ObjectMapper

class Price: Mappable
{
    var currency: String?
    
    var retailPrice: NSNumber?
    
    var deletedAt: NSDate?
    
    var createdAt: NSDate?
    
    var updatedAt: NSDate?
    
    var price: NSNumber?
    
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map)
    {
        currency                      <- map["currency"]
        price                         <- map["price"]
        retailPrice                   <- map["retail_price"]
        deletedAt                     <- (map["deleted_at"], DateTransform())
        createdAt                     <- (map["created_at"], DateTransform())
        updatedAt                     <- (map["updated_at"], DateTransform())
    }

}