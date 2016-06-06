//
//  HighlightedButton.swift
//  Layers
//
//  Created by David Hodge on 6/5/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

class HighlightedButton: UIButton
{
    var defaultColor: UIColor?
    
    var highlightedColor: UIColor?
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        self.setTitleColor(Color.whiteColor(), forState: .Normal)
        self.setTitleColor(Color.whiteColor(), forState: .Highlighted)
    }
    
    override var highlighted: Bool
    {
        didSet
        {
            if highlighted
            {
                if let highlightedColor = highlightedColor
                {
                    self.backgroundColor = highlightedColor
                }
            }
            else
            {
                if let defaultColor = defaultColor
                {
                    self.backgroundColor = defaultColor
                }
            }
        }
    }
}