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
    
    static let smallCtaAttributes = [
        NSForegroundColorAttributeName: Color.PrimaryAppColor,
        NSFontAttributeName: Font.PrimaryFontRegular(size: 12.0),
        NSKernAttributeName: 0.7
    ]
    
    static let headerTextAttributes = [
        NSForegroundColorAttributeName: Color.DarkTextColor,
        NSFontAttributeName: Font.PrimaryFontRegular(size: 14.0),
        NSKernAttributeName: 1.3
    ]
    
    static let largeHeaderTextAttributes = [
        NSForegroundColorAttributeName: Color.DarkTextColor,
        NSFontAttributeName: Font.PrimaryFontRegular(size: 16.0),
        NSKernAttributeName: 1.3
    ]
    
    static let defaultTextAttributes = [
        NSForegroundColorAttributeName: Color.DarkTextColor,
        NSFontAttributeName: Font.PrimaryFontLight(size: 14.0),
        NSKernAttributeName: 1.0
    ]
    
    static let bodyTextAttributes = [
        NSForegroundColorAttributeName: Color.GrayColor,
        NSFontAttributeName: Font.PrimaryFontLight(size: 12.0),
        NSKernAttributeName: 0.7
    ]
    
    static let darkBodyTextAttributes = [
        NSForegroundColorAttributeName: Color.DarkTextColor,
        NSFontAttributeName: Font.PrimaryFontLight(size: 12.0),
        NSKernAttributeName: 0.7
    ]
    
    static let boldBodyTextAttributes = [
        NSForegroundColorAttributeName: Color.GrayColor,
        NSFontAttributeName: Font.PrimaryFontRegular(size: 12.0),
        NSKernAttributeName: 0.7
    ]
}
