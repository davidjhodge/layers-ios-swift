//
//  Category.swift
//  Layers
//
//  Created by David Hodge on 9/4/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit
import ObjectMapper

class Category: Mappable
{
    var categoryId: String?
    
    var name: String?
    
    var shortName: String?
    
    var localizedCategoryId: String?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        categoryId             <-  map["id"]
        name                   <-  map["name"]
        shortName              <-  map["short_name"]
        localizedCategoryId    <-  map["localizedIdd"]
    }
}
