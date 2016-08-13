//
//  BarGradient.swift
//  Layers
//
//  Created by David Hodge on 8/13/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation

extension UIImage
{
    static func navigationBarImage() -> UIImage
    {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 64.0)
        
        // Define colors for the gradient
        let colors = [
            Color.DarkNavyColor,
            UIColor(red: 30.0/255.0, green: 51.0/255.0, blue: 123.0/255.0, alpha: 1.0),
            UIColor(red: 61.0/255.0, green: 81.0/255.0, blue: 157.0/255.0, alpha: 1.0)
        ]
        
        // Map UIColors to CGColors
        gradientLayer.colors = colors.map{ $0.CGColor }
        
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        
        // Render gradient to create a UIImage
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        
        if let currentContext = UIGraphicsGetCurrentContext()
        {
            gradientLayer.renderInContext(currentContext)
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return image
        }
        
        // If current context does not exist, return default color
        return UIButton.imageFromColor(Color.DarkNavyColor)
    }
}