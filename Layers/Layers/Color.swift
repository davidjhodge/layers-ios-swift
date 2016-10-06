//
//  Color.swift
//  Layers
//
//  Created by David Hodge on 4/9/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

func ColorCode(_ red:CGFloat, green:CGFloat, blue:CGFloat, alpha:CGFloat) -> UIColor {
    return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
}

open class Color: UIColor
{
    static func colorFromHex(_ hexString: String?) -> UIColor?
    {
        if let hexString = hexString
        {
            if ((hexString.characters.count) != 6) {
                return UIColor.white
            }
            
            var rgbValue:UInt32 = 0
            Scanner(string: hexString).scanHexInt32(&rgbValue)
            
            return UIColor(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: CGFloat(1.0)
            )
        }
        
        return UIColor.white
    }
    
    // MARK: New Colors
    static let PrimaryAppColor: UIColor = ColorCode(76, green: 133, blue: 238, alpha: 1.0)
    
    static let HighlightedPrimaryAppColor: UIColor = ColorCode(37, green: 114, blue: 212, alpha: 1.0)
    
    static let GrayColor: UIColor = ColorCode(0, green: 0, blue: 0, alpha: 0.3)
    
    static let DarkTextColor: UIColor = ColorCode(40, green: 45, blue: 44, alpha: 1.0)

//    static let DarkNavyColor: UIColor = ColorCode(14, green: 36, blue: 106, alpha: 1.0)
    
//    static let VeryDarkNavyColor: UIColor = ColorCode(7, green: 22, blue: 69, alpha: 1.0)
    
    // MARK: Old Colors
    static let RedColor: UIColor = ColorCode(244, green: 67, blue: 54, alpha: 1.0)
    
    static let GreenColor: UIColor = ColorCode(90, green: 182, blue: 94, alpha: 1.0)

    static let BackgroundGrayColor: UIColor = ColorCode(246, green: 246, blue: 246, alpha: 1.0)
    
    static let NeonBlueColor: UIColor = ColorCode(76, green: 133, blue: 238, alpha: 1.0)

    static let NeonBlueHighlightedColor: UIColor = ColorCode(66, green: 110, blue: 192, alpha: 1.0)

    static let LightGray: UIColor = ColorCode(200, green: 200, blue: 200, alpha: 1.0)
    
    static let HighlightedGrayColor: UIColor = ColorCode(230, green: 230, blue: 230, alpha: 1.0)
    
    static let HighlightedWhiteColor: UIColor = ColorCode(239, green: 239, blue: 239, alpha: 1.0)

}
