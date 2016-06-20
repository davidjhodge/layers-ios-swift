//
//  PricingResponse.swift
//  Layers
//
//  Created by David Hodge on 6/19/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import ObjectMapper

class PricingResponse: Mappable
{
    var prices: Array<Price>?
    
    var altPrices: Array<Price>?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        prices            <-  map["on_sale"]
        altPrices        <-  map["watching"]
    }
}