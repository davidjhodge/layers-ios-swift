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
            
//            if let category = filterResponse as? Category
//            {
//                if let categoryName = category.name
//                {
//                    filter.name = categoryName
//                }
//                
//                if let key = category.categoryId
//                {
//                    filter.key = key
//                }
//            }
            if let brand = filterResponse as? Brand
            {
                if let name = brand.name
                {
                    filter.name = name
                }
                
                if let key = brand.brandId
                {
                    filter.key = key
                }
            }
            else if let retailer = filterResponse as? Retailer
            {
                if let name = retailer.name
                {
                    filter.name = name
                }
                
                if let key = retailer.retailerId
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