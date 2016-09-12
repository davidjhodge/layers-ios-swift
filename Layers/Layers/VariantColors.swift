//
//  VariantColors.swift
//  Layers
//
//  Created by David Hodge on 9/6/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit
import SDWebImage
import DominantColor

typealias LRVariantColorsCompletionBlock = ((variants: Array<Variant>?) -> Void)

class VariantColors: NSObject
{
    static func analyzeVariantsAndApplyDominantColors(variants: Array<Variant>, completionBlock: LRVariantColorsCompletionBlock?)
    {
        let operationQueue = NSOperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        
            for variant in variants
            {
                if let imageResolutions = variant.image
                {
                    if let imageIndex = imageResolutions.indexOf({ $0.sizeName == ImageSizeKey.Smallest.rawValue })
                    {
                        if let primaryImage: Image = imageResolutions[safe: imageIndex]
                        {
                            if let imageUrl = primaryImage.url
                            {
                                // Download Image
                                operationQueue.addOperationWithBlock({ () -> Void in
                                    
                                    SDWebImageManager.sharedManager().downloadImageWithURL(imageUrl, options: SDWebImageOptions.CacheMemoryOnly, progress: nil, completed: { (image, error, cacheType, finished, imageUrl) -> Void in
                                        
                                        if error == nil && image != nil
                                        {
                                            let pixelCount = Int((image.size.width * image.size.height) * image.scale)
                                            
                                            if let cgImage = image.CGImage
                                            {
                                                if let dominantColor = dominantColorsInImage(cgImage, maxSampledPixels: pixelCount)[safe: 0]
                                                {
                                                    variant.dominantColor = UIColor(CGColor: dominantColor)
                                                }
                                            }

//                                            if let dominantColor = self.domiantColor(image, context: context)
//                                            {
//                                                variant.dominantColor = dominantColor
//                                            }
                                        }
                                    })
                                })
                            }
                        }
                    }
                    
                }
            }
        
        operationQueue.addOperationWithBlock({ () -> Void in
            
            if let completion = completionBlock
            {
                completion(variants: variants)
            }
        })
    }
    
    static func domiantColor(image: UIImage, context: CIContext) -> UIColor?
    {
        let convertImage = CIImage(image: image)
        
        let filter = CIFilter(name: "CIAreaAverage")
        filter?.setValue(convertImage, forKey: kCIInputImageKey)
        
        if let processedImage = filter?.outputImage
        {
            let finalImage = context.createCGImage(processedImage, fromRect: processedImage.extent)
            
            let pixelData = CGDataProviderCopyData(CGImageGetDataProvider(finalImage))
            let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
            
            let pixelInfo: Int = ((Int(1) * Int(0)) + Int(0)) * 4
            
            let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
            let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
            let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
            let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
            
            return UIColor(red: r, green: g, blue: b, alpha: a)
        }
        
        return nil
    }
    
}