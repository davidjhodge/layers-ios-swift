//
//  Size.swift
//  Layers
//
//  Created by David Hodge on 9/4/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit
import ObjectMapper

class Size: Mappable
{
    var sizeId: NSNumber?
    
    var sizeKeyName: String?
    
    var sizeName: String?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        sizeId              <-  map["canonicalSize.id"]
        sizeKeyName         <-  map["canonicalSize.name"]
        sizeName            <-  map["name"]
    }
}
