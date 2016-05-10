//
//  NSURLImageSIze.swift
//  Layers
//
//  Created by David Hodge on 5/9/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation

enum ImageSize: NSNumber
{
    case kImageSize32 = 32, kImageSize64 = 64, kImageSize112 = 112, kImageSize164 = 164, kImageSize224 = 224, kImageSize656 = 656, kImageSize900 = 900
}

extension NSURL
{
    static func imageAtUrl(imageUrl: NSURL, imageSize size: ImageSize?) -> NSURL
    {
        if imageUrl.absoluteString.characters.count > 0
        {
            if let size = size
            {
                // Replace "original" in the url with whatever size you want
                if let initialRange: Range = imageUrl.absoluteString.rangeOfString("original")
                {
                    let updatedString = imageUrl.absoluteString.stringByReplacingCharactersInRange(initialRange.startIndex..<initialRange.endIndex, withString: NSString(format: "%.0f", CGFloat.retinaSize(size)) as String)
                    
                    if let updatedUrl = NSURL(string: updatedString)
                    {
                        return updatedUrl
                    }
                }
            }
        }
        
        return imageUrl
    }
}

extension CGFloat
{
    static func retinaSize(size: ImageSize) -> CGFloat
    {
        let scale = UIScreen.mainScreen().scale
        
        var imageSize = size
        
        //@2x
        if scale == 2.0
        {
            if size == ImageSize.kImageSize112
            {
                imageSize = ImageSize.kImageSize224
            }
        }
        //@3x
        else if scale == 3.0
        {
            if size == ImageSize.kImageSize112
            {
                imageSize = ImageSize.kImageSize656
            }
        }
        
        return CGFloat(imageSize.rawValue)
    }
}