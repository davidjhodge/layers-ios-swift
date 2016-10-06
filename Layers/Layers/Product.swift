//
//  Product.swift
//  Layers
//
//  Created by David Hodge on 9/4/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit
import ObjectMapper

class Product: Mappable
{
    var productId: NSNumber?
    
    var outboundUrl: URL?
    
    var brandedName: String?
    
    var unbrandedName: String?
    
    var brand: Brand?
    
    var categories: Array<Category>?
    
    var price: Price?
    
    var altPrice: AltPrice?
    
    var variants: Array<Variant>?
    
    var images: Images?
    
    var retailer: Retailer?
    
    var productDescription: String?
    
    var inStock: Bool?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        productId                <-  map["id"]
        outboundUrl              <-  (map["outbound_url"], URLTransform())
        brandedName              <-  map["branded_name"]
        unbrandedName            <-  map["unbranded_name"]
        brand                    <-  map["brand"]
        price                    <-  map["price"]
        altPrice                 <-  map["alt_pricing"]
        variants                 <-  map["variants"]
        images                   <-  map["images"]
        retailer                 <-  map["retailer"]
        productDescription       <-  map["description"]
        inStock                  <-  map["in_stock"]
    }
    
    func primaryImageUrl(_ size: ImageSizeKey) -> URL?
    {
        if let primaryImageResolutions = images?.primaryImageUrls
        {
            if let imageIndex = primaryImageResolutions.index(where: { $0.sizeName == size.rawValue })
            {
                if let primaryImage: Image = primaryImageResolutions[safe: imageIndex]
                {
                    if let imageUrl = primaryImage.url
                    {
                        return imageUrl as URL
                    }
                }
            }
        }
        
        return nil
    }
}
