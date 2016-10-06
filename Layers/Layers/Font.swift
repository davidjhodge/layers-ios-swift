//
//  Font.swift
//  Layers
//
//  Created by David Hodge on 4/9/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

open class Font: UIFont
{
    // MARK: Montserrat
    open static func PrimaryFontLight(size:(CGFloat)) -> UIFont
    {
        return UIFont(name: "Montserrat-Light", size: size)!
    }
    
    open static func PrimaryFontRegular(size:(CGFloat)) -> UIFont
    {
        return UIFont(name: "Montserrat-Regular", size: size)!
    }
    
    open static func PrimaryFontSemiBold(size:(CGFloat)) -> UIFont
    {
        return UIFont(name: "Montserrat-SemiBold", size: size)!
    }
    
    // MARK: Charter
//    public static func CharterRoman(size size:(CGFloat)) -> UIFont
//    {
//        return UIFont(name: "Charter-Roman", size: size)!
//    }
//    
//    public static func CharterBold(size size:(CGFloat)) -> UIFont
//    {
//        return UIFont(name: "Charter-Bold", size: size)!
//    }
//    
//    public static func CharterBlack(size size:(CGFloat)) -> UIFont
//    {
//        return UIFont(name: "Charter-Black", size: size)!
//    }
    
    // MARK: Oxygen
    open static func OxygenLight(size:(CGFloat)) -> UIFont
    {
        return UIFont(name: "Oxygen-Light", size: size)!
    }
    
    open static func OxygenRegular(size:(CGFloat)) -> UIFont
    {
        return UIFont(name: "Oxygen-Regular", size: size)!
    }
    
    open static func OxygenBold(size:(CGFloat)) -> UIFont
    {
        return UIFont(name: "Oxygen-Bold", size: size)!
    }
}
