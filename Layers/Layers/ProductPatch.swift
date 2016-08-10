//
//  ProductPatch.swift
//  Layers
//
//  Created by David Hodge on 8/7/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation

extension SimpleProductResponse
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
                && firstVariant.images?.count > 0
                {
                    // Check if price information exists
                    if let firstSize = firstVariant.sizes?[safe: 0]
                    {
                        if firstSize.price?.price != nil
                        {
                            return true
                        }
                    }
                }
            }
        }
        
        return false
    }
}