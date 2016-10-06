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
    
    init(name: String?, key: String?)
    {
        if (name != nil) { self.name = name }
        
        if (key != nil) { self.key = key }
    }
    
    var name: String?
    
    var key: String?
}

struct Filter
{
    var categories: (selections: Array<FilterObject>?, all: Array<FilterObject>?, originals: Array<Category>?)
    
    var brands: (selections: Array<FilterObject>?, all: Array<FilterObject>?, originals: Array<Brand>?)
    
    var retailers: (selections: Array<FilterObject>?, all: Array<FilterObject>?)
    
    var priceRange: PriceFilter?
    
    var colors: (selections: Array<ColorObject>?, all: Array<ColorObject>?)
}

typealias FilterOriginalCompletionBlock = ((_ success: Bool, _ response:Array<AnyObject>?) -> Void)
typealias FilterCompletionBlock = ((_ success: Bool, _ response:Array<FilterObject>?) -> Void)
typealias ColorCompletionBlock = ((_ success: Bool, _ response:Array<ColorObject>?) -> Void)

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
    
    fileprivate var filter: Filter!
    
    init()
    {
        setNewFilter(Filter())
    }
    
    func getCurrentFilter() -> Filter
    {
        return filter
    }
    
    func setNewFilter(_ newFilter: Filter)
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
                        categoryParams = categoryParams + "category_id=\(categoryKey),"
                    }
                    // Any additional categories
                    else
                    {
                        categoryParams = categoryParams + "\(categoryKey),"
                    }
                }
            }
            
            if categoryParams.contains(",")
            {
                categoryParams = String(categoryParams.characters.dropLast())
                
                categoryParams = categoryParams + "&"
            }
            
            paramsString = paramsString + categoryParams
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
                        brandParams = brandParams + "brand_id=\(brandKey),"
                    }
                    // Any additional brands
                    else
                    {
                        brandParams = brandParams + "\(brandKey),"
                    }
                }
            }
            
            if brandParams.contains(",")
            {
                brandParams = String(brandParams.characters.dropLast())
                
                brandParams = brandParams + "&"
            }
            
            paramsString = paramsString + brandParams
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
                        retailerParams = retailerParams + "retailer_id=\(retailerKey),"
                    }
                        // Any additional brands
                    else
                    {
                        retailerParams = retailerParams + "\(retailerKey),"
                    }
                }
            }
            
            if retailerParams.contains(",")
            {
                retailerParams = String(retailerParams.characters.dropLast())
                
                retailerParams = retailerParams + "&"
            }
            
            paramsString = paramsString + retailerParams
        }
        
        // Price
        if let priceMin = filter.priceRange?.minPrice
        {
            let priceParam = "price_min=\(priceMin)&"
            
            paramsString = paramsString + priceParam

        }
        
        if let priceMax = filter.priceRange?.maxPrice
        {
            let priceParam = "price_max=\(priceMax)&"
            
            paramsString = paramsString + priceParam
        }
        
        // Color
        if let colors = filter.colors.selections
        {
            var colorParams = ""
            
            for color in colors
            {
                if let colorKey = color.colorId
                {
                    // First brand
                    if colorParams.characters.count == 0
                    {
                        colorParams = colorParams + "color_id=\(colorKey),"
                    }
                        // Any additional brands
                    else
                    {
                        colorParams = colorParams + "\(colorKey),"
                    }
                }
            }
            
            if colorParams.contains(",")
            {
                colorParams = String(colorParams.characters.dropLast())
                
                colorParams = colorParams + "&"
            }
            
            paramsString = paramsString + colorParams
        }
        
        if paramsString.contains("&")
        {
            paramsString = String(paramsString.characters.dropLast())
        }
        
        return paramsString
    }
    
    // MARK: Fetch Categories
    // Helper to access the original categories. This architecture should be modified in the future.
    func fetchOriginalCategories(_ completionHandler: FilterOriginalCompletionBlock?)
    {
        if let originalCategories = filter.categories.originals
        {
            if let completion = completionHandler
            {
                completion(true, originalCategories)
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
                            completion(success, originalCategories)
                        }
                    }
                }
            })
        }
    }
    
    func fetchCategories(_ completionHandler: FilterCompletionBlock?)
    {
        if let categories = filter.categories.all
        {
            if let completion = completionHandler
            {
                completion(true, categories)
            }
        }
        else
        {
            LRSessionManager.sharedManager.loadCategories({ (success, error, response) -> Void in
             
                if success
                {
                    if let completion = completionHandler
                    {
                        if let categoryArray = response as? Array<Category>
                        {
                            // Store an original copy
                            self.filter.categories.originals = categoryArray
                            
                            if let filters = FilterObjectConverter.filterObjectArray(categoryArray)
                            {
                                // Story a FilterObject copy
                                self.filter.categories.all = filters
                                
                                completion(true, filters)
                            }
                        }
                    }
                }
                else
                {
                    if let completion = completionHandler
                    {
                        completion(false, nil)
                    }
                }

                
            })
        }
    }
    
    // MARK: Fetch Brands
    
    func fetchBrands(_ completionHandler: FilterCompletionBlock?)
    {
        if let brands = filter.brands.all
        {
            if let completion = completionHandler
            {
                completion(true, brands)
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
                        if let brandArray = response as? Array<Brand>
                        {
                            // Store an original copy
                            self.filter.brands.originals = brandArray
                            
                            if let filters = FilterObjectConverter.filterObjectArray(brandArray)
                            {
                                // Store a FilterObject copy
                                self.filter.brands.all = filters
                                
                                completion(true, filters)
                            }
                        }
                    }
                }
                else
                {
                    if let completion = completionHandler
                    {
                        completion(false, nil)
                    }
                }
            })
        }
    }
    
    // MARK: Fetch Retailers
    
    func fetchRetailers(_ completionHandler: FilterCompletionBlock?)
    {
        if let retailers = filter.retailers.all
        {
            if let completion = completionHandler
            {
                completion(true, retailers)
            }
        }
        else
        {
            LRSessionManager.sharedManager.loadRetailers( { (success, error, response) -> Void in
                
                if success
                {
                    if let completion = completionHandler
                    {
                        if let retailerArray = response as? Array<Retailer>
                        {
                            if let filters = FilterObjectConverter.filterObjectArray(retailerArray)
                            {
                                self.filter.retailers.all = filters
                                
                                completion(true, filters)
                            }
                        }
                    }
                }
                else
                {
                    if let completion = completionHandler
                    {
                        completion(false, nil)
                    }
                }
            })
        }
    }
    
    // MARK: Fetch Colors
    func fetchColors(_ completionHandler: ColorCompletionBlock?)
    {
        if let colors = filter.colors.all
        {
            if let completion = completionHandler
            {
                completion(true, colors)
            }
        }
        else
        {
            LRSessionManager.sharedManager.loadColors({ (success, error, response) -> Void in
                
                if success
                {
                    if let completion = completionHandler
                    {
                        if let colorArray = response as? Array<ColorObject>
                        {
                            completion(true, colorArray)
                        }
                    }
                }
                else
                {
                    if let completion = completionHandler
                    {
                        completion(false, nil)
                    }
                }
            })
        }
    }
    
}
