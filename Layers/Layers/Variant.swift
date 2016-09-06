//
//  Variant.swift
//  Layers
//
//  Created by David Hodge on 9/4/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit
import ObjectMapper

class Variant: Mappable
{
    var color: String?
    
    var sizes: Array<Size>?
    
    var image: Array<Image>?
    
    var dominantColor: UIColor?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        color          <-  map["color"]
        sizes          <-  map["sizes"]
        image         <-  map["image"]
    }
}
