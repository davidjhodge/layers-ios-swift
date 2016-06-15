//
//  AgeRange.swift
//  Layers
//
//  Created by David Hodge on 6/15/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import ObjectMapper

class AgeRange: Mappable
{
    var minAge: NSNumber?
    
    var maxAge: NSNumber?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map)
    {
        minAge          <- map["min"]
        maxAge          <- map["max"]
    }
    
    func predictedAge() -> NSNumber?
    {
        var age: NSNumber?
        
        if let min = minAge
        {
            // Just Min
            age = min
        }
        
        if let max = maxAge
        {
            if let min = minAge
            {
                // Min and max
                age = Int(round((max.doubleValue + min.doubleValue) * 0.5))
            }
            else
            {
                // Just max
                age = max
            }
        }
        
        return age
    }
}