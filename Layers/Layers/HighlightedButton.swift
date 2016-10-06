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
    func setBackgroundColor(_ backgroundColor: UIColor, forState state: UIControlState)
    {
        setBackgroundImage(UIButton.imageFromColor(backgroundColor), for: state)
    }
    
    static func imageFromColor(_ color: UIColor) -> UIImage
    {
        let rect = CGRect(x: 0,y: 0,width: 1,height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}
