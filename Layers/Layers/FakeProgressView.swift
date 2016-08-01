//
//  FakeProgressView.swift
//  Layers
//
//  Created by David Hodge on 8/1/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

class FakeProgressView: UIProgressView
{
    var isComplete: Bool = false
    
    var timer: NSTimer?
    
    override func awakeFromNib()
    {
        self.progress = 0
        
        progressTintColor = Color.NeonBlueColor
        
        tintColor = Color.LightGray
        
        // 0.01667 = 1/60 = 60fps
        timer = NSTimer.scheduledTimerWithTimeInterval(0.01667, target: self, selector: #selector(timerCycle), userInfo: nil, repeats: true)
    }
    
//    override func layoutSubviews()
//    {
//        code
//    }
    
    func timerCycle()
    {
        if isComplete == true
        {
            // If progress view is fully loaded, hide it
            if progress >= 1
            {
                // Hide progress view
                UIView.animateWithDuration(0.05, animations: { () -> Void in
                    
                    self.alpha = 0.0
                    
                    }, completion: { (finished) -> Void in
                 
                        self.hidden = true
                })
                
                if let timer = timer
                {
                    timer.invalidate()
                }
            }
            else
            {
                // Loading is complete, speed up progress load
                progress += 0.05
            }
        }
        else
        {
            // Loading is occuring, progress should increment slowly
            progress += 0.005
            
            if progress >= 0.95
            {
                progress = 0.95
            }
        }
    }
}