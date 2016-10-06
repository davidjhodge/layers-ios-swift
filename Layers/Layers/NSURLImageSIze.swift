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
    // These will need to change
    case kImageSize116 = 112, kImageSize200 = 200, kImageSize232 = 232, kImageSize348 = 348, kImageSize400 = 400, kImageSize600 = 600, kImageSize = 1242
}

extension URL
{
    static func imageAtUrl(_ imageUrl: URL, imageSize size: ImageSize?) -> URL
    {
        if imageUrl.absoluteString.characters.count > 0
        {
            if let size = size
            {
                // Update update URL to select correct size.
                
                
            }
        }

        return imageUrl
    }
}

extension CGFloat
{
    static func retinaSize(_ size: ImageSize) -> CGFloat
    {
        let scale = UIScreen.main.scale
        
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
