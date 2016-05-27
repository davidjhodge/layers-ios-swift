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
    static func filterObject(retailer: RetailerResponse?) -> FilterObject?
    {
        if let retailerResponse = retailer
        {
            var filter: FilterObject = FilterObject()
            
            if let name = retailerResponse.retailerName
            {
                filter.name = name
            }
            
            if let key = retailerResponse.retailerId?.integerValue
            {
                filter.key = key
            }
            
            return filter
        }
        
        return nil
    }
    
    static func filterObjectArray(retailers: Array<RetailerResponse>?) -> Array<FilterObject>?
    {
        if let retailers = retailers
        {
            var filters = Array<FilterObject>()
            
            for retailer in retailers
            {
                if let filter = filterObject(retailer)
                {
                    filters.append(filter)
                }
            }
            
            return filters
        }
        
        return nil
    }
}