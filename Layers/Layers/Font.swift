//
//  Font.swift
//  Layers
//
//  Created by David Hodge on 4/9/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

class Font
{
    // MARK: Charter
    static func CharterRoman(size size:(CGFloat)) -> UIFont
    {
        return UIFont(name: "Charter-Roman", size: size)!
    }
    
    static func CharterBold(size size:(CGFloat)) -> UIFont
    {
        return UIFont(name: "Charter-Bold", size: size)!
    }
    
    static func CharterBlack(size size:(CGFloat)) -> UIFont
    {
        return UIFont(name: "Charter-Black", size: size)!
    }
    
    // MARK: Oxygen
    static func OxygenLight(size size:(CGFloat)) -> UIFont
    {
        return UIFont(name: "Oxygen-Light", size: size)!
    }
    
    static func OxygenRegular(size size:(CGFloat)) -> UIFont
    {
        return UIFont(name: "Oxygen-Regular", size: size)!
    }
    
    static func OxygenBold(size size:(CGFloat)) -> UIFont
    {
        return UIFont(name: "Oxygen-Bold", size: size)!
    }
}