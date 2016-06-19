//
//  SearchResponse.swift
//  Layers
//
//  Created by David Hodge on 6/5/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import ObjectMapper

class SearchResponse: Mappable
{
    var products: Dictionary<String, SearchProductResponse>?
    
    var brands: Array<BrandResponse>?
    
    var categories: Array<CategoryResponse>?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        products            <-  map["results.products"]
        brands              <-  map["results.brands"]
        categories          <-  map["results.categories"]
    }
}