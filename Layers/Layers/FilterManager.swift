//
//  FilterManager.swift
//  Layers
//
//  Created by David Hodge on 5/19/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation

struct FilterObject
{
    var name: String?
    
    var key: Int?
}

struct Filter
{
    var categories: Array<FilterObject>?
    
    var brands: Array<FilterObject>?
    
    var retailers: Array<FilterObject>?
    
    var priceRange: (minPrice: Int, maxPrice: Int)?
    
    var color: UIColor?
}

typealias FilterCompletionBlock = ((success: Bool, response:Array<FilterObject>?) -> Void)

// Compare by keys
func ==(lhs:FilterObject, rhs:FilterObject) -> Bool { // Implement Equatable
    return lhs.key == rhs.key
}

class FilterManager
{
    // Static variable to handle all filtering manipulations
    static let defaultManager = FilterManager()
    
    private var filter = Filter()
    
    func getCurrentFilter() -> Filter
    {
        return filter
    }
    
    func setNewFilter(newFilter: Filter)
    {
        filter = newFilter
    }
    
    func fetchCategories(completionHandler: FilterCompletionBlock?)
    {
        if let categories = filter.categories
        {
            if let completion = completionHandler
            {
                completion(success: true, response: categories)
            }
        }
        else
        {
            // Fetch categories from network
            
            // TEMP
            var object1 = FilterObject()
            object1.name = "J. Crew"
            object1.key = 0
            
            var object2 = FilterObject()
            object2.name = "Ralph Lauren"
            object2.key = 1
            
            var object3 = FilterObject()
            object3.name = "Gucci"
            object3.key = 2
            
            var object4 = FilterObject()
            object4.name = "Mane"
            object4.key = 3
            
            if let completion = completionHandler
            {
                completion(success: true, response: [object1,object2,object3,object4])
            }
        }
    }
    
    func fetchBrands()
    {
        
    }
    
    func fetchRetailers()
    {
        
    }
    
}