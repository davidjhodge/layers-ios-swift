//
//  SizeSorter.swift
//  Layers
//
//  Created by David Hodge on 6/21/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation

class SizeSorter
{
    //Sort Sizes
    // Check first element of first item to see if alphabetic or numeric.
    static func sortSizes(product: ProductResponse?) -> Array<Variant>?
    {
        if let variants = product?.variants
        {
            if let firstSizeTitle = variants.first?.sizes?.first?.sizeTitle
            {
                // Check if first element is an alphabetic character or a number
                if let _ = Int(firstSizeTitle.substringToIndex(firstSizeTitle.startIndex.successor()))
                {
                    // Number
                    return sortNumericalSizesFromVariants(variants)
                }
                else
                {
                    // String
                    return sortAlphabeticalSizes(variants)
                }
            }
        }
        
        return product?.variants
    }
    
    // Sort Numerically
    static func sortNumericalSizesFromVariants(variants: Array<Variant>) -> Array<Variant>
    {
        for variant in variants
        {
            if let sizes: Array<Size> = variant.sizes
            {
                let sortedSizes = sizes.sort({ (sizeOne, sizeTwo) -> Bool in
                    
                    if var sizeOneTitle = sizeOne.sizeTitle,
                        var sizeTwoTitle = sizeTwo.sizeTitle
                    {
                        if let slashOneIndex = sizeOneTitle.characters.indexOf("/"),
                            let slashTwoIndex = sizeTwoTitle.characters.indexOf("/")
                        {
                            sizeOneTitle = sizeOneTitle.substringToIndex(slashOneIndex)
                            sizeTwoTitle = sizeTwoTitle.substringToIndex(slashTwoIndex)
                        }
                        
                        let size1 = Int(sizeOneTitle) ?? 0 as Int
                        let size2 = Int(sizeTwoTitle) ?? 0 as Int
                        return size1 < size2
                    }
                    
                    return false
                })
                
                variant.sizes = sortedSizes
            }
        }
        
        return variants
    }
    
    // Sort Alphabetically
    static func sortAlphabeticalSizes(variants: Array<Variant>) -> Array<Variant>
    {
        let sizeSorting = ["s": 0,
                           "m": 1,
                           "l": 2,
                           "x": 3]
        
        for variant in variants
        {
            if let sizes: Array<Size> = variant.sizes
            {
                let sortedSizes = sizes.sort({ (sizeOne, sizeTwo) -> Bool in
                    
                    if let sizeOneTitle = sizeOne.sizeTitle,
                        let sizeTwoTitle = sizeTwo.sizeTitle
                    {
                        let size1 = sizeOneTitle ?? "" as String
                        let size2 = sizeTwoTitle ?? "" as String
                        
                        let size1FirstLetter: String = size1.substringToIndex(size1.startIndex.successor())
                        
                        let size2FirstLetter: String = size2.substringToIndex(size2.startIndex.successor())
                        
                            if let size1Ranking: Int = sizeSorting[size1FirstLetter.lowercaseString],
                                let size2Ranking: Int = sizeSorting[size2FirstLetter.lowercaseString]
                            {
                                return size1Ranking < size2Ranking
                            }
                        
                    }
                    
                    return false
                })
                
                variant.sizes = sortedSizes
            }
        }
        
        return variants
    }
    
}