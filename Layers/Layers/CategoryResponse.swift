//
//  CategoryResponse.swift
//  Layers
//
//  Created by David Hodge on 5/29/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import ObjectMapper

class CategoryResponse: Mappable
{
    var categoryUrl: String?
    
    var categoryName: String?
    
    var categoryId: NSNumber?
    
    var parentId: NSNumber?
    
    var createdAt: NSNumber?

    var updatedAt: NSNumber?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        categoryUrl         <-  map["category_url"]
        categoryName        <-  map["category_name"]
        categoryId          <- map["id"]
        parentId            <- map["parent_id"]
        createdAt           <- map["created_at"]
        updatedAt           <- map["updated_at"]
    }
}