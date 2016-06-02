//
//  ColorResponse.swift
//  Layers
//
//  Created by David Hodge on 5/29/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import ObjectMapper

class ColorResponse: Mappable
{
    var colorName: String?
    
    var colorHex: String?
    
    var colorId: NSNumber?
    
    var color: UIColor?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        colorName              <-  map["color_name"]
        colorHex            <-  map["color_hex"]
        colorId              <- map["id"]
    }
}