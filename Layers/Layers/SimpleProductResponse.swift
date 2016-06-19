//
//  SimpleProductResponse.swift
//  Layers
//
//  Created by David Hodge on 6/18/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import ObjectMapper

class SimpleProductResponse: Mappable
{
    var productName: String?
    
    var brand: BrandResponse?
    
    var categories: Array<String>?
    
    var sku: String?

    var outboundUrl: String?
    
    var variants: Array<Variant>?
    
    var productId: NSNumber?
    
    var isInStock: Bool = true
    
    var retailer: RetailerResponse?
    
    var description: String?
        
    var isWatching: Bool = false
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        productName              <-  map["product_name"]
        brand                    <-  map["brand"]
        outboundUrl              <-  map["outbound_url"]
        variants                 <-  map["variants"]
        sku                      <-  map["sku"]
        productId                <-  map["id"]
        isInStock                <-  map["product_in_stock"]
        retailer                 <-  map["retailer"]
        description              <-  map["description"]
        isWatching               <-  map["is_watching"]
    }
}