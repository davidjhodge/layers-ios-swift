//
//  AnimatedImageView.swift
//  Layers
//
//  Created by David Hodge on 7/22/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation

class AnimatedImageView: UIImageView {
    
    var hasShown = false
    
    override var image: UIImage? {
        didSet {
            
            if image != nil && hasShown == false
            {
                hasShown = true

                self.alpha = 0.0
                
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                  
                    self.alpha = 1.0
                })
            }
            
            super.image = image
        }
    }
}