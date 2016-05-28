//
//  FilterManager.swift
//  Layers
//
//  Created by David Hodge on 5/19/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation

public struct FilterObject
{
    init()
    {
        self.name = nil
        
        self.key = nil
    }
    
    init(name: String?, key: Int?)
    {
        if (name != nil) { self.name = name }
        
        if (key != nil) { self.key = key }
    }
    
    var name: String?
    
    var key: Int?
}

struct Filter
{
    var categories: Array<FilterObject>?
    
    var brands: Array<FilterObject>?
    
    var retailers: (selections: Array<FilterObject>?, all: Array<FilterObject>?)
    
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
    
    private var filter: Filter!
    
    init()
    {
        setNewFilter(Filter())
    }
    
    func getCurrentFilter() -> Filter
    {
        return filter
    }
    
    func setNewFilter(newFilter: Filter)
    {
        filter = newFilter
    }
    
    func resetFilter()
    {
        filter = Filter()
        
        filter.retailers = (selections: nil, all: nil)
    }
    
    func hasActiveFilters() -> Bool
    {
        if filter.categories != nil || filter.brands != nil || filter.retailers.selections != nil || filter.priceRange != nil || filter.color != nil
        {
            return true
        }
        
        return false
    }
    
    // To be used in networking
    func filterParamsAsString() -> String
    {
        var paramsString = ""
        
        // Categories
        if let categories = filter.categories
        {
            var categoryParams = ""
            
            for category in categories
            {
                if let categoryKey = category.key
                {
                    categoryParams = categoryParams.stringByAppendingString("category=\(categoryKey)&")
                }
            }
            
            paramsString = paramsString.stringByAppendingString(categoryParams)
        }
        
        // Brands
        if let brands = filter.brands
        {
            var brandParams = ""
            
            for brand in brands
            {
                if let brandKey = brand.key
                {
                    brandParams = brandParams.stringByAppendingString("brand=\(brandKey)&")
                }
            }
            
            paramsString = paramsString.stringByAppendingString(brandParams)
        }
        
        // Retailers
        if let retailers = filter.retailers.selections
        {
            var retailerParams = ""
            
            for retailer in retailers
            {
                if let retailerKey = retailer.key
                {
                    retailerParams = retailerParams.stringByAppendingString("retailer=\(retailerKey)&")
                }
            }
            
            paramsString = paramsString.stringByAppendingString(retailerParams)
        }
        
        // Price
        if let priceMin = filter.priceRange?.minPrice
        {
            let priceParam = "price_min=\(priceMin)&"
            
            paramsString = paramsString.stringByAppendingString(priceParam)

        }
        
        if let priceMax = filter.priceRange?.maxPrice
        {
            let priceParam = "price_min=\(priceMax)&"
            
            paramsString = paramsString.stringByAppendingString(priceParam)
        }
        
        // Color
        // Not currently being handled
        
        
        if paramsString.containsString("&")
        {
            paramsString = String(paramsString.characters.dropLast())
        }
        
        return paramsString
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
    
    func fetchRetailers(completionHandler: FilterCompletionBlock?)
    {
        if let retailers = filter.retailers.all
        {
            if let completion = completionHandler
            {
                completion(success: true, response: retailers)
            }
        }
        else
        {
            LRSessionManager.sharedManager.loadRetailers( { (success, error, retailers) -> Void in
                
                if success
                {
                    if let completion = completionHandler
                    {
                        if let retailerArray = retailers as? Array<RetailerResponse>
                        {
                            if let filters = FilterObjectConverter.filterObjectArray(retailerArray)
                            {
                                self.filter.retailers.all = filters
                                
                                completion(success: true, response: filters)
                            }
                        }
                    }
                }
                else
                {
                    if let completion = completionHandler
                    {
                        completion(success: false, response: nil)
                    }
                }
            })
        }
    }
    
}