//
//  SafeIndex.swift
//  Layers
//
//  Created by David Hodge on 5/2/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Iterator.Element? {
        return index >= startIndex && index < endIndex ? self[index] : nil
    }
}
