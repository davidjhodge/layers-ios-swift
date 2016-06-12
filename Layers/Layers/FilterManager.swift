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
    var categories: (selections: Array<FilterObject>?, all: Array<FilterObject>?, originals: Array<CategoryResponse>?)
    
    var brands: (selections: Array<FilterObject>?, all: Array<FilterObject>?, originals: Array<BrandResponse>?)
    
    var retailers: (selections: Array<FilterObject>?, all: Array<FilterObject>?)
    
    var priceRange: PriceFilter?
    
    var colors: (selections: Array<ColorResponse>?, all: Array<ColorResponse>?)
}

typealias FilterOriginalCompletionBlock = ((success: Bool, response:Array<AnyObject>?) -> Void)
typealias FilterCompletionBlock = ((success: Bool, response:Array<FilterObject>?) -> Void)
typealias ColorCompletionBlock = ((success: Bool, response:Array<ColorResponse>?) -> Void)

// Compare by keys
func ==(lhs:FilterObject, rhs:FilterObject) -> Bool { // Implement Equatable
    return lhs.key == rhs.key
}

// Used as a public extension so all Filter objects can access this property.
// This is accessed on a newFilter object in the FilterViewController
extension Filter
{
    func hasActiveFilters() -> Bool
    {
        if categories.selections != nil || brands.selections != nil || retailers.selections != nil || priceRange != nil || colors.selections != nil
        {
            return true
        }
        
        return false
    }
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
    
    // To be used in networking
    func filterParamsAsString() -> String
    {
        var paramsString = ""
        
        // Categories
        if let categories = filter.categories.selections
        {
            var categoryParams = ""
            
            for category in categories
            {
                if let categoryKey = category.key
                {
                    // First category
                    if categoryParams.characters.count == 0
                    {
                        categoryParams = categoryParams.stringByAppendingString("category=\(categoryKey),")
                    }
                    // Any additional categories
                    else
                    {
                        categoryParams = categoryParams.stringByAppendingString("\(categoryKey),")
                    }
                }
            }
            
            if categoryParams.containsString(",")
            {
                categoryParams = String(categoryParams.characters.dropLast())
                
                categoryParams = categoryParams.stringByAppendingString("&")
            }
            
            paramsString = paramsString.stringByAppendingString(categoryParams)
        }
        
        // Brands
        if let brands = filter.brands.selections
        {
            var brandParams = ""
            
            for brand in brands
            {
                if let brandKey = brand.key
                {
                    // First brand
                    if brandParams.characters.count == 0
                    {
                        brandParams = brandParams.stringByAppendingString("brand=\(brandKey),")
                    }
                    // Any additional brands
                    else
                    {
                        brandParams = brandParams.stringByAppendingString("\(brandKey),")
                    }
                }
            }
            
            if brandParams.containsString(",")
            {
                brandParams = String(brandParams.characters.dropLast())
                
                brandParams = brandParams.stringByAppendingString("&")
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
                    // First brand
                    if retailerParams.characters.count == 0
                    {
                        retailerParams = retailerParams.stringByAppendingString("retailer=\(retailerKey),")
                    }
                        // Any additional brands
                    else
                    {
                        retailerParams = retailerParams.stringByAppendingString("\(retailerKey),")
                    }
                }
            }
            
            if retailerParams.containsString(",")
            {
                retailerParams = String(retailerParams.characters.dropLast())
                
                retailerParams = retailerParams.stringByAppendingString("&")
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
            let priceParam = "price_max=\(priceMax)&"
            
            paramsString = paramsString.stringByAppendingString(priceParam)
        }
        
        // Color
        if let colors = filter.colors.selections
        {
            var colorParams = ""
            
            for color in colors
            {
                if let colorName = color.colorName
                {
                    // First brand
                    if colorParams.characters.count == 0
                    {
                        colorParams = colorParams.stringByAppendingString("color=\(colorName),")
                    }
                        // Any additional brands
                    else
                    {
                        colorParams = colorParams.stringByAppendingString("\(colorName),")
                    }
                }
            }
            
            if colorParams.containsString(",")
            {
                colorParams = String(colorParams.characters.dropLast())
                
                colorParams = colorParams.stringByAppendingString("&")
            }
            
            paramsString = paramsString.stringByAppendingString(colorParams)
        }
        
        if paramsString.containsString("&")
        {
            paramsString = String(paramsString.characters.dropLast())
        }
        
        return paramsString
    }
    
    // MARK: Fetch Categories
    // Helper to access the original categories. This architecture should be modified in the future.
    func fetchOriginalCategories(completionHandler: FilterOriginalCompletionBlock?)
    {
        if let originalCategories = filter.categories.originals
        {
            if let completion = completionHandler
            {
                completion(success: true, response: originalCategories)
            }
        }
        else
        {
            fetchCategories({ (success, response) -> Void in
             
                if success
                {
                    if let originalCategories = self.filter.categories.originals
                    {
                        if let completion = completionHandler
                        {
                            completion(success: success, response: originalCategories)
                        }
                    }
                }
            })
        }
    }
    
    func fetchCategories(completionHandler: FilterCompletionBlock?)
    {
        if let categories = filter.categories.all
        {
            if let completion = completionHandler
            {
                completion(success: true, response: categories)
            }
        }
        else
        {
            LRSessionManager.sharedManager.loadCategories({ (success, error, response) -> Void in
             
                if success
                {
                    if let completion = completionHandler
                    {
                        if let categoryArray = response as? Array<CategoryResponse>
                        {
                            // Store an original copy
                            self.filter.categories.originals = categoryArray
                            
                            if let filters = FilterObjectConverter.filterObjectArray(categoryArray)
                            {
                                // Story a FilterObject copy
                                self.filter.categories.all = filters
                                
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
    
    // MARK: Fetch Brands
    
    func fetchBrands(completionHandler: FilterCompletionBlock?)
    {
        if let brands = filter.brands.all
        {
            if let completion = completionHandler
            {
                completion(success: true, response: brands)
            }
        }
        else
        {
            // Fetch categories from network
            LRSessionManager.sharedManager.loadBrands({ (success, error, response) -> Void in
                
                if success
                {
                    if let completion = completionHandler
                    {
                        if let brandArray = response as? Array<BrandResponse>
                        {
                            // Store an original copy
                            self.filter.brands.originals = brandArray
                            
                            if let filters = FilterObjectConverter.filterObjectArray(brandArray)
                            {
                                // Store a FilterObject copy
                                self.filter.brands.all = filters
                                
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
    
    // MARK: Fetch Retailers
    
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
            LRSessionManager.sharedManager.loadRetailers( { (success, error, response) -> Void in
                
                if success
                {
                    if let completion = completionHandler
                    {
                        if let retailerArray = response as? Array<RetailerResponse>
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
    
    // MARK: Fetch Colors
    func fetchColors(completionHandler: ColorCompletionBlock?)
    {
        if let colors = filter.colors.all
        {
            if let completion = completionHandler
            {
                completion(success: true, response: colors)
            }
        }
        else
        {
            LRSessionManager.sharedManager.loadColors({ (success, error, response) -> Void in
                
                if success
                {
                    if let completion = completionHandler
                    {
                        if let colorArray = response as? Array<ColorResponse>
                        {
                            completion(success: true, response: colorArray)
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