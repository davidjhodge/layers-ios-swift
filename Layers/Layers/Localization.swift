//
//  Localization.swift
//  Layers
//
//  Created by David Hodge on 4/21/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation

extension String
{
    var localized: String {
        
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}
