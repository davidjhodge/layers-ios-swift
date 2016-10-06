//
//  VariantColors.swift
//  Layers
//
//  Created by David Hodge on 9/6/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit
import SDWebImage
import CoreImage

typealias LRVariantColorsCompletionBlock = ((_ variants: Array<Variant>?) -> Void)

class VariantColors: NSObject
{
    static func analyzeVariantsAndApplyDominantColors(_ variants: Array<Variant>, completionBlock: LRVariantColorsCompletionBlock?)
    {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        
            for variant in variants
            {
                if let imageResolutions = variant.image
                {
                    if let imageIndex = imageResolutions.index(where: { $0.sizeName == ImageSizeKey.Smallest.rawValue })
                    {
                        if let primaryImage: Image = imageResolutions[safe: imageIndex]
                        {
                            if let imageUrl = primaryImage.url
                            {
                                // Download Image
                                operationQueue.addOperation({ () -> Void in
                                    
                                    SDWebImageManager.shared().downloadImage(with: imageUrl as URL!, options: SDWebImageOptions.cacheMemoryOnly, progress: nil, completed: { (image, error, cacheType, finished, imageUrl) -> Void in
                                        
                                        if error == nil && image != nil
                                        {
                                            if let image = image
                                            {
                                                let context = CIContext()
                                                
                                                if let dominantColor = self.domiantColor(image, context: context)
                                                {
                                                    variant.dominantColor = dominantColor
                                                }
                                            }
                                        }
                                    })
                                })
                            }
                        }
                    }
                    
                }
            }
        
        operationQueue.addOperation({ () -> Void in
            
            if let completion = completionBlock
            {
                completion(variants)
            }
        })
    }
    
    static func domiantColor(_ image: UIImage, context: CIContext) -> UIColor?
    {
        let convertImage = CIImage(image: image)
        
        let filter = CIFilter(name: "CIAreaAverage")
        filter?.setValue(convertImage, forKey: kCIInputImageKey)
        
        if let processedImage = filter?.outputImage
        {
            let finalImage = context.createCGImage(processedImage, from: processedImage.extent)
            
            let pixelData = finalImage?.dataProvider?.data
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
