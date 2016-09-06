//
//  SimpleProduct.swift
//  Layers
//
//  Created by David Hodge on 9/5/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit
import ObjectMapper

class SimpleProduct: Mappable
{
    var productId: NSNumber?
    
    var brand: Brand?
    
    var unbrandedName: String?
    
    var brandedName: String?
    
    var image: Image?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        productId           <-  map["id"]
        brand               <-  map["brand"]
        unbrandedName       <-  map["unbranded_name"]
        brandedName         <-  map["branded_name"]
        image               <-  map["images"]
    }
}
