//
//  FontAttributes.swift
//  Layers
//
//  Created by David Hodge on 9/4/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit

public class FontAttributes: NSObject
{
    static let buttonAttributes = [
        NSForegroundColorAttributeName: Color.PrimaryAppColor,
        NSFontAttributeName: Font.PrimaryFontSemiBold(size: 14.0),
        NSKernAttributeName: 1.3
    ]
    
    static let filledButtonAttributes = [
        NSForegroundColorAttributeName: Color.whiteColor(),
        NSFontAttributeName: Font.PrimaryFontSemiBold(size: 14.0),
        NSKernAttributeName: 1.3
    ]
}
