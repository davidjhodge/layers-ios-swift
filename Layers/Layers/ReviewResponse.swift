//
//  ReviewResponse.swift
//  Layers
//
//  Created by David Hodge on 5/1/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import ObjectMapper

class ReviewResponse: Mappable
{
    var date: NSDate?
    
    var sizeRatings: Array<SizeRating>?
    
    var title: String?
    
    var reviewId: String?
    
    var description: String?
    
    var author: String?
    
    var rating: Rating?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map)
    {
        date                  <- map["date"]
        sizeRatings           <- map["size_ratings"]
        title                 <- map["title"]
        reviewId              <- map["review_id"]
        description           <- map["description"]
        author                <- map["author"]
        rating                <- map["rating.0"]
    }
}