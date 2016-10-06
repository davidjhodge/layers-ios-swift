//
//  ColorObject.swift
//  Layers
//
//  Created by David Hodge on 9/4/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit
import ObjectMapper

class ColorObject: Mappable
{
    var colorId: NSNumber?
    
    var name: String?
    
    var rank: NSNumber?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        colorId         <-  map["id"]
        name            <-  map["name"]
        rank            <-  map["rank"]
    }
}
