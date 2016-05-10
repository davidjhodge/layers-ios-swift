//
//  ProductResponse.swift
//  Layers
//
//  Created by David Hodge on 5/1/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import ObjectMapper

typealias Feature = String

class ProductResponse: Mappable
{
    var productName: String?
    
    var brandName: String?
    
    var outboundUrl: String?
    
    var reviews: Array<Review>?
    
    var sizeRatings: Array<SizeRating>?
    
    var variants: Array<Variant>?
    
    var sku: String?
    
    var categoryName: String?
    
    var productId: NSNumber?
    
    var rating: Rating?
    
    var isInStock: Bool?
    
    var retailerId: NSNumber?
    
    var description: String?
    
    var features: Array<Feature>?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        productName              <-  map["product_name"]
        brandName                <-  map["brand_name"]
        outboundUrl              <-  map["outbound_url"]
        reviews                  <-  map["reviews"]
        sizeRatings              <-  map["size_ratings"]
        variants                 <-  map["variants"]
        sku                      <-  map["sku"]
        categoryName             <-  map["category_name"]
        productId                <-  map["id"]
        rating                   <-  map["rating.0"]
        isInStock                <-  map["product_in_stock"]
        retailerId               <-  map["retailer_id"]
        description              <-  map["description"]
        features                 <-  map["features"]

    }
}