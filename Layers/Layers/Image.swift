//
//  Image.swift
//  Layers
//
//  Created by David Hodge on 9/4/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit
import ObjectMapper

enum ImageSizeKey: String
{
    case Small = "IPhoneSmall", Normal = "IPhone"
}

class Image: Mappable {

    var actualWidth: NSNumber?
    
    var actualHeight: NSNumber?
    
    var width: NSNumber?
    
    var url: NSURL?
    
    var sizeName: String?
    
    var height: NSNumber?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        actualWidth             <-  map["actual_width"]
        actualHeight            <-  map["actual_height"]
        width                   <-  map["width"]
        url                     <-  (map["url"], URLTransform())
        sizeName                <-  map["size_name"]
        height                  <-  map["height"]
    }
}
