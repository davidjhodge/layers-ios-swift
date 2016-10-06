//
//  VariantColorMatcher.swift
//  Layers
//
//  Created by David Hodge on 6/1/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


extension Variant
{
    static func variantMatchingFilterColorsInVariants(_ variants: Array<Variant>?) -> Variant?
    {
        if let variants = variants
        {
            for currVariant in variants
            {
                if let selectedColors = FilterManager.defaultManager.getCurrentFilter().colors.selections , FilterManager.defaultManager.getCurrentFilter().colors.selections?.count > 0
                {
                    //Color filtering is active
                    
                    // Determine if first variant matches color filter
//                    if let firstDefinedColor = currVariant.color?.definedColorId
//                    {
//                        if let _: ColorResponse = selectedColors.filter({$0.colorId == firstDefinedColor }).first
//                        {
//                            return currVariant
//                        }
//                    }
                }
            }
        }
        
        return nil
    }
}
