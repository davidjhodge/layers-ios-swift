//
//  Color.swift
//  Layers
//
//  Created by David Hodge on 4/9/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

func ColorCode(red:CGFloat, green:CGFloat, blue:CGFloat, alpha:CGFloat) -> UIColor {
    return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
}

class Color: UIColor
{
    static let DarkNavyColor: UIColor = ColorCode(14, green: 36, blue: 106, alpha: 1.0)
    
    static let DarkTextColor: UIColor = ColorCode(36, green: 40, blue: 49, alpha: 1.0)
    
    static let RedColor: UIColor = ColorCode(244, green: 67, blue: 54, alpha: 1.0)
    
    static let GreenColor: UIColor = ColorCode(90, green: 182, blue: 94, alpha: 1.0)

    static let BackgroundGrayColor: UIColor = ColorCode(246, green: 246, blue: 246, alpha: 1.0)
    
    static let NeonBlueColor: UIColor = ColorCode(76, green: 133, blue: 238, alpha: 1.0)
    
    static let LightGray: UIColor = ColorCode(200, green: 200, blue: 200, alpha: 1.0)
}