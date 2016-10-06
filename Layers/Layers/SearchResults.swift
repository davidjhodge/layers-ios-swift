//
//  SearchResults.swift
//  Layers
//
//  Created by David Hodge on 9/5/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit
import ObjectMapper

class SearchResults: Mappable
{
    var products: Array<SimpleProduct>?
    
    var categories: Array<Category>?
    
    var brands: Array<Brand>?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        products            <-  map["products"]
        categories          <-  map["categories"]
        brands              <-  map["brands"]
    }
}
