//
//  Image.swift
//  Layers
//
//  Created by David Hodge on 5/1/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import ObjectMapper

class Image: Mappable
{
    var thumbnailUrl: NSURL?
    
    var mediumUrl: NSURL?
    
    var largeUrl: NSURL?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map)
    {
        thumbnailUrl                <- (map["thumbnail_url"], URLTransform())
        mediumUrl                   <- (map["medium_url"], URLTransform())
        largeUrl                    <- (map["large_url"], URLTransform())
    }
    
}