//
//  ProductPatch.swift
//  Layers
//
//  Created by David Hodge on 8/7/16.
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


extension Product
{
    func isValid() -> Bool
    {
        // Check if variants exist
        if variants?.count > 0
        {
            if let firstVariant = variants?[safe: 0]
            {
                // Check if images and sizes both exist
                if firstVariant.sizes?.count > 0
                && firstVariant.image?.count > 0
                {
                    // Check if price information exists
                    if price?.price != nil
                    {
                        return true
                    }
                }
            }
        }
        
        return false
    }
}
