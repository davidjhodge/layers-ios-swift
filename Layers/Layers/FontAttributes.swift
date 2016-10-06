//
//  FontAttributes.swift
//  Layers
//
//  Created by David Hodge on 9/4/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit

open class FontAttributes: NSObject
{
    static let buttonAttributes = [
        NSForegroundColorAttributeName: Color.PrimaryAppColor,
        NSFontAttributeName: Font.PrimaryFontSemiBold(size: 14.0),
        NSKernAttributeName: 1.3
    ] as [String : Any]
    
    static let filledButtonAttributes = [
        NSForegroundColorAttributeName: Color.white,
        NSFontAttributeName: Font.PrimaryFontSemiBold(size: 14.0),
        NSKernAttributeName: 1.3
    ] as [String : Any]
    
    static let smallCtaAttributes = [
        NSForegroundColorAttributeName: Color.PrimaryAppColor,
        NSFontAttributeName: Font.PrimaryFontRegular(size: 12.0),
        NSKernAttributeName: 0.7
    ] as [String : Any]
    
    static let headerTextAttributes = [
        NSForegroundColorAttributeName: Color.DarkTextColor,
        NSFontAttributeName: Font.PrimaryFontRegular(size: 14.0),
        NSKernAttributeName: 1.3
    ] as [String : Any]
    
    static let largeHeaderTextAttributes = [
        NSForegroundColorAttributeName: Color.DarkTextColor,
        NSFontAttributeName: Font.PrimaryFontRegular(size: 16.0),
        NSKernAttributeName: 1.3
    ] as [String : Any]
    
    static let defaultTextAttributes = [
        NSForegroundColorAttributeName: Color.DarkTextColor,
        NSFontAttributeName: Font.PrimaryFontLight(size: 14.0),
        NSKernAttributeName: 0.8
    ] as [String : Any]
    
    static let bodyTextAttributes = [
        NSForegroundColorAttributeName: Color.GrayColor,
        NSFontAttributeName: Font.PrimaryFontLight(size: 12.0),
        NSKernAttributeName: 0.7
    ] as [String : Any]
    
    static let darkBodyTextAttributes = [
        NSForegroundColorAttributeName: Color.DarkTextColor,
        NSFontAttributeName: Font.PrimaryFontLight(size: 12.0),
        NSKernAttributeName: 0.7
    ] as [String : Any]
    
    static let boldBodyTextAttributes = [
        NSForegroundColorAttributeName: Color.GrayColor,
        NSFontAttributeName: Font.PrimaryFontRegular(size: 12.0),
        NSKernAttributeName: 0.7
    ] as [String : Any]
}
