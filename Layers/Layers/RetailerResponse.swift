//
//  RetailerResponse.swift
//  Layers
//
//  Created by David Hodge on 5/10/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import ObjectMapper

class RetailerResponse: Mappable
{
    var retailerUrl: String?
    
    var retailerName: String?
    
    var retailerId: NSNumber?
    
    var retailerDomain: NSString?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        retailerUrl              <-  map["retailer_url"]
        retailerName            <-  map["retailer_name"]
        retailerId              <- map["id"]
        retailerDomain          <- map["retailer_domain"]
    }
}

//"retailer_url": "factory-jcrew-com",
//"retailer_name": "J.Crew Factory",
//"id": 5,
//"retailer_domain": "factory.jcrew.com"