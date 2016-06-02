//
//  ColorObject.swift
//  Layers
//
//  Created by David Hodge on 6/1/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import ObjectMapper

class ColorObject: Mappable
{
    var color: UIColor?
    
    var definedColorId: NSNumber?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map)
    {
        let colorTransform = TransformOf<UIColor, Dictionary<String, NSNumber>>(fromJSON: { (value: Dictionary?) -> UIColor? in
            
            if let colorDict = value
            {
                if let red = colorDict["red"] as? CGFloat, green = colorDict["green"] as? CGFloat, blue = colorDict["blue"] as? CGFloat
                {
                    return ColorCode(red, green: green, blue: blue, alpha: 1.0)
                }
                else
                {
                    return nil
                }
            }
            
            return nil
            
            }, toJSON:  { (value: UIColor?) -> Dictionary<String, NSNumber>? in
                
                if let thisColor = value
                {
                    var colorDict = Dictionary<String, NSNumber>()
                    
                    let coreImageColor = CIColor(color: thisColor)
                    
                    let red = Int(coreImageColor.red * 255)
                    let green = Int(coreImageColor.green * 255)
                    let blue = Int(coreImageColor.blue * 255)
                    
                    colorDict["red"] = red
                    colorDict["blue"] = blue
                    colorDict["green"] = green
                    
                    return colorDict
                }
                else
                {
                    return nil
                }
        })
        
        color               <- (map, colorTransform)
        definedColorId      <- map["definedcolor_id"]
    }
}