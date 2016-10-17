//
//  TextUtility.swift
//  Layers
//
//  Created by David Hodge on 10/15/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit

extension NSMutableAttributedString
{
    func boldenMatchesFor(_ matchString: String)
    {
        let words = matchString.characters.split{ $0 == " " }.map(String.init)
        
        for word in words
        {
            do {
                let regex = try NSRegularExpression(pattern: "\(word)", options: .caseInsensitive)
                
                let range = NSMakeRange(0, string.characters.count)
                
                regex.enumerateMatches(in: string, options: .reportCompletion, range: range, using: { (result, flags, stop) -> Void in
                    
                    if let substringRange = result?.rangeAt(0)
                    {
                        self.addAttribute(NSFontAttributeName, value: Font.PrimaryFontSemiBold(size: 12.0), range: substringRange)
                    }
                })
                
            } catch
            {
                // Substring not found
            }
        }
    }
}
