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
    var primaryUrl: NSURL?
    
    var alternateUrls: Array<NSURL>?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map)
    {
        primaryUrl                <- (map["primary_url"], URLTransform())
        alternateUrls             <- (map["alternate_urls"], URLTransform())
    }
    
}