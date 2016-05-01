//
//  Rating.swift
//  Layers
//
//  Created by David Hodge on 5/1/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import ObjectMapper

class Rating: Mappable
{
    var score: NSNumber?
    
    var total: NSNumber?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map)
    {
        score                   <- map["score"]
        total                   <- map["total"]
    }
}