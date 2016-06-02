//
//  VariantColorMatcher.swift
//  Layers
//
//  Created by David Hodge on 6/1/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation

extension Variant
{
    static func variantMatchingFilterColorsInVariants(variants: Array<Variant>?) -> Variant?
    {
        if let variants = variants
        {
            for currVariant in variants
            {
                if let selectedColors = FilterManager.defaultManager.getCurrentFilter().colors.selections where FilterManager.defaultManager.getCurrentFilter().colors.selections?.count > 0
                {
                    //Color filtering is active
                    
                    // Determine if first variant matches color filter
                    if let firstDefinedColor = currVariant.color?.definedColorId
                    {
                        if let _: ColorResponse = selectedColors.filter({$0.colorId == firstDefinedColor }).first
                        {
                            return currVariant
                        }
                    }
                }
            }
        }
        
        return nil
    }
}