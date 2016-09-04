//
//  Font.swift
//  Layers
//
//  Created by David Hodge on 4/9/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

public class Font: UIFont
{
    // MARK: Montserrat
    public static func PrimaryFontLight(size size:(CGFloat)) -> UIFont
    {
        return UIFont(name: "Montserrat-Light", size: size)!
    }
    
    public static func PrimaryFontRegular(size size:(CGFloat)) -> UIFont
    {
        return UIFont(name: "Montserrat-Regular", size: size)!
    }
    
    public static func PrimaryFontSemiBold(size size:(CGFloat)) -> UIFont
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
    public static func OxygenLight(size size:(CGFloat)) -> UIFont
    {
        return UIFont(name: "Oxygen-Light", size: size)!
    }
    
    public static func OxygenRegular(size size:(CGFloat)) -> UIFont
    {
        return UIFont(name: "Oxygen-Regular", size: size)!
    }
    
    public static func OxygenBold(size size:(CGFloat)) -> UIFont
    {
        return UIFont(name: "Oxygen-Bold", size: size)!
    }
}