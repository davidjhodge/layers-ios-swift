//
//  OnboardingContainerViewController.swift
//  Layers
//
//  Created by David Hodge on 5/1/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

let kProgressViewNeedsUpdateNotification = "kProgressViewNeedsUpdateNotification"

class OnboardingContainerViewController: UIViewController
{
    @IBOutlet weak var progressView: UIProgressView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateProgressView(_:)), name: kProgressViewNeedsUpdateNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressView.hidden = true
    }
    
    // Actions
    func updateProgressView(notification: NSNotification)
    {
        if let userInfo = notification.userInfo
        {
            if let isHidden = userInfo["hidden"] as? Bool
            {
                // If progress view should be shown
                if !isHidden
                {
                    if progressView.alpha < 1.0 || progressView.hidden == true
                    {
                        progressView.alpha = 0.0
                        progressView.hidden = false
                        
                        UIView.animateWithDuration(0.6, delay: 0.0, options: .CurveEaseOut, animations: { () -> Void in
                            
                            self.progressView.alpha = 1.0
                            }, completion: { (finished) -> Void in })
                    }
                }
                    // If progress view should be hidden
                else
                {
                    if progressView.hidden == false
                    {
                        UIView.animateWithDuration(0.6, delay: 0.0, options: .CurveEaseOut, animations: { () -> Void in
                            
                            self.progressView.alpha = 0.0
                            }, completion: { (finished) -> Void in
                                self.progressView.hidden = true
                        })
                    }
                }
            }
            
            if let progress = userInfo["progress"] as? NSNumber
            {
                progressView.setProgress(progress.floatValue, animated: true)
                
//                UIView.animateWithDuration(0.6, delay: 0.0, options: .CurveEaseOut, animations: { () -> Void in
//                    
//                    self.progressView.progress = progress.floatValue
//                }, completion: { (finished) -> Void in })
            }
        }
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}