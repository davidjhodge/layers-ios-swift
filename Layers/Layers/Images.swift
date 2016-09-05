//
//  Images.swift
//  Layers
//
//  Created by David Hodge on 9/4/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit
import ObjectMapper

class Images: Mappable
{
    var primaryImageUrls: Array<Image>?
    
    var alternateImageUrls: Array<Image>?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        primaryImageUrls           <-  map["primary_urls"]
        alternateImageUrls         <-  map["alternate_urls"]
    }
}
