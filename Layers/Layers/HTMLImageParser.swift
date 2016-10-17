//
//  HTMLImageParser.swift
//  Layers
//
//  Created by David Hodge on 10/16/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit

class HTMLImageParser: NSObject {

    static func imagesAtUrlString(_ urlString: String) -> Array<URL>?
    {
        if let htmlString = htmlFromUrlString(urlString)
        {
            return imagesFromHtml(htmlString)
        }
        
        return nil
    }
    
//    NSError *error = NULL;
//    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(<img\\s[\\s\\S]*?src\\s*?=\\s*?['\"](.*?)['\"][\\s\\S]*?>)+?"
//    options:NSRegularExpressionCaseInsensitive
//    error:&error];
//    
//    [regex enumerateMatchesInString:yourHTMLSourceCodeString
//    options:0
//    range:NSMakeRange(0, [yourHTMLSourceCodeString length])
//    usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
//    
//    NSString *img = [yourHTMLSourceCodeString substringWithRange:[result rangeAtIndex:2]];
//    NSLog(@"img src %@",img);
//    }];
    
    static func imagesFromHtml(_ htmlString: String) -> Array<URL>?
    {        
        var regex: NSRegularExpression?
        
        do {
            regex = try NSRegularExpression(pattern: "(<img\\s[\\s\\S]*?src\\s*?=\\s*?['\"](.*?)['\"][\\s\\S]*?>)+?", options: .caseInsensitive)
        }
        catch let error
        {
            log.error(error.localizedDescription)
        }
        
        var imageUrls = Array<URL>()
        
        if let regex = regex
        {
            regex.enumerateMatches(in: htmlString, options: .reportCompletion, range: NSMakeRange(0, htmlString.characters.count), using: { (result: NSTextCheckingResult?, _, stop) in
                
                if let nsRange = result?.rangeAt(2)
                {
                    let htmlSource = htmlString as NSString
                    
                    let imgUrlString: String = htmlSource.substring(with: nsRange) as String
                    
                    if let imgUrl = URL(string: imgUrlString)
                    {
                        imageUrls.append(imgUrl)
                    }
                }
            })
        }
        
        if imageUrls.count > 0
        {
            return imageUrls
        }
        
        return nil
    }
    
    static func htmlFromUrlString(_ urlString: String) -> String?
    {
        if let url = URL(string: urlString)
        {
            do {
                return try String(contentsOf: url, encoding: .ascii)
            }
            catch let error
            {
                log.error(error)
            }
        }
        
        return nil
    }
}
