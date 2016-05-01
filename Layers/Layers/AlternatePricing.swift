//
//  AlternatePricing.swift
//  Layers
//
//  Created by David Hodge on 5/1/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import ObjectMapper

class AlternatePricing: Mappable
{
    var couponCode: String?
    
    var priceAfterCoupon: NSNumber?

    var deletedAt: NSDate?
    
    var createdAt: NSDate?
    
    var updatedAt: NSDate?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map)
    {
        couponCode                    <- map["currency"]
        priceAfterCoupon              <- map["price_after_coupon"]
        deletedAt                     <- (map["deleted_at"], DateTransform())
        createdAt                     <- (map["created_at"], DateTransform())
        updatedAt                     <- (map["updated_at"], DateTransform())
    }
}