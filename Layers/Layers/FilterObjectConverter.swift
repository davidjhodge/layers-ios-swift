//
//  FilterObjectConverter.swift
//  Layers
//
//  Created by David Hodge on 5/26/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation

class FilterObjectConverter
{
    // Convert either a category, retailer, or brand to filter object
    static func filterObject<T>(filterResponse: T?) -> FilterObject?
    {
            var filter: FilterObject = FilterObject()
            
            if let categoryResponse = filterResponse as? CategoryResponse
            {
                if let name = categoryResponse.categoryName
                {
                    filter.name = name
                }
                
                if let key = categoryResponse.categoryId?.integerValue
                {
                    filter.key = key
                }
            }
            else if let brandResponse = filterResponse as? BrandResponse
            {
                if let name = brandResponse.brandName
                {
                    filter.name = name
                }
                
                if let key = brandResponse.brandId?.integerValue
                {
                    filter.key = key
                }
            }
            else if let retailerResponse = filterResponse as? RetailerResponse
            {
                if let name = retailerResponse.retailerName
                {
                    filter.name = name
                }
                
                if let key = retailerResponse.retailerId?.integerValue
                {
                    filter.key = key
                }
            }
            
            return filter
    }
    
    static func filterObjectArray<T>(responses: Array<T>?) -> Array<FilterObject>?
    {
        if let responses = responses
        {
            var filters = Array<FilterObject>()
            
            for response in responses
            {
                if let filter = filterObject(response)
                {
                    filters.append(filter)
                }
            }
            
            return filters
        }
        
        return nil
    }
}