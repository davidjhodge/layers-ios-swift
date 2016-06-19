//
//  SearchProductResponse.swift
//  Layers
//
//  Created by David Hodge on 6/5/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import ObjectMapper

class SearchProductResponse: Mappable
{
    var productId: NSNumber?
    
    var brand: BrandResponse?
    
    var productName: String?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        productId           <-  map["id"]
        brand               <-  map["brand"]
        productName         <-  map["product_name"]
    }
}