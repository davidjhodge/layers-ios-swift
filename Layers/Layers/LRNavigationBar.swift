//
//  LRNavigationBar.swift
//  Layers
//
//  Created by David Hodge on 4/9/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

class LRNavigationBar: UINavigationBar
{
    private let kNavHeightIncreaseInterval: CGFloat = 38.0
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        
        var newSize: CGSize = super.sizeThatFits(size)
        newSize.height += kNavHeightIncreaseInterval
        
        return newSize
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.initialize()
    }
    
    func initialize()
    {
        transform = CGAffineTransformMakeTranslation(0, -(kNavHeightIncreaseInterval))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let classNamesToResposition: Array = ["_UINavigationBarBackground"]
        
        for view:UIView in subviews
        {
            if classNamesToResposition.contains(String(view.dynamicType))
            {
                let statusBarHeight: CGFloat = UIApplication.sharedApplication().statusBarHidden ? 0.0 : 20.0
                
                var frame: CGRect = view.frame
                frame.origin.y = bounds.origin.y + kNavHeightIncreaseInterval - statusBarHeight
                frame.size.height = bounds.size.height + statusBarHeight
                
                view.frame = frame
            }
        }
    }
}