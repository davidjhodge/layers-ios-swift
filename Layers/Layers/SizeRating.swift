//
//  SizeRating.swift
//  Layers
//
//  Created by David Hodge on 5/1/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import ObjectMapper

class SizeRating: Mappable
{
    var element: String?
    
    var rating: Array<Rating>?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map)
    {
        element                  <- map["element"]
        rating                   <- map["rating"]
    }
}