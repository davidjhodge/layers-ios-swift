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
    
    var alternateImages: Array<Array<Image>>?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        primaryImageUrls        <-  map["primary_urls"]
        alternateImages         <-  map["alternate_images"]
    }
}
