//
//  SaleAlertResponse.swift
//  Layers
//
//  Created by David Hodge on 6/14/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import ObjectMapper

class SaleAlertResponse: Mappable
{
    var saleProducts: Array<ProductResponse>?
    
    var watchingProducts: Array<ProductResponse>?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        saleProducts            <-  map["on_sale"]
        watchingProducts        <-  map["watching"]
    }
}