//
//  HighlightedButton.swift
//  Layers
//
//  Created by David Hodge on 6/5/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

extension UIButton
{
    func setBackgroundColor(backgroundColor: UIColor, forState state: UIControlState)
    {
        setBackgroundImage(UIButton.imageFromColor(backgroundColor), forState: state)
    }
    
    static func imageFromColor(color: UIColor) -> UIImage
    {
        let rect = CGRectMake(0,0,1,1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}