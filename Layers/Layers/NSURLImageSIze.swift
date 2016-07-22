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
    case kImageSize116 = 112, kImageSize200 = 200, kImageSize232 = 232, kImageSize348 = 348, kImageSize400 = 400, kImageSize600 = 600, kImageSize = 1242
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
            if size == .kImageSize116
            {
                imageSize = .kImageSize232
            }
            else if size == .kImageSize232
            {
                imageSize = .kImageSize600
            }
        }
        //@3x
        else if scale == 3.0
        {
            if size == .kImageSize116
            {
                imageSize = .kImageSize348
            }
            else if size == .kImageSize232
            {
                imageSize = .kImageSize600
            }
        }
        
        return CGFloat(imageSize.rawValue)
    }
}