//
//  ColorObject.swift
//  Layers
//
//  Created by David Hodge on 6/1/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import ObjectMapper

class ColorObject: Mappable
{
    var red: NSNumber?
    
    var green: NSNumber?
    
    var blue: NSNumber?
    
    var definedColorId: NSNumber?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map)
    {
        red                 <- map["red"]
        green               <- map["green"]
        blue                <- map["blue"]
        definedColorId      <- map["definedcolor_id"]
    }
}