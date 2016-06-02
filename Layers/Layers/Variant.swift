//
//  Variant.swift
//  Layers
//
//  Created by David Hodge on 5/1/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import ObjectMapper

class Variant: Mappable
{
    var styleName: String?
    
    var styleId: String?
    
    var sizes: Array<Size>?

    var images: Array<Image>?
    
    var color: ColorObject?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map)
    {
        styleName                <- map["style_name"]
        styleId                  <- map["style_id"]
        sizes                    <- map["sizes"]
        images                   <- map["images"]
        color                    <- (map["color.0"])
    }
}
