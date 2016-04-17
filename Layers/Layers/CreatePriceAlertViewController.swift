//
//  CreatePriceAlertViewController.swift
//  Layers
//
//  Created by David Hodge on 4/17/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

class CreatePriceAlertViewController: UIViewController
{
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var createPriceAlertButton: UIButton!
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var priceAlertButtonBottomConstraint: NSLayoutConstraint!
    
    var keyboardNotificationObserver: AnyObject?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        cancelButton.addTarget(self, action: #selector(cancel), forControlEvents: .TouchUpInside)
        
        prepareToHandleKeyboard()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        textField.layer.sublayerTransform = CATransform3DMakeTranslation(16, 0, 0)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        textField.becomeFirstResponder()
    }
    
    func createPriceAlert()
    {
        view.endEditing(true)
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func cancel()
    {
        view.endEditing(true)
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Handle Keyboard
    func prepareToHandleKeyboard()
    {
        keyboardNotificationObserver = NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillChangeFrameNotification, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] (notification) -> Void in
            
            let frame : CGRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            
            guard let keyboardFrameInViewCoordiantes = self?.view.convertRect(frame, fromView: nil), bounds = self?.view.bounds else { return; }
            
            let constantModification = CGRectGetHeight(bounds) - keyboardFrameInViewCoordiantes.origin.y
            
            let duration:NSTimeInterval = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            
            
            UIView.animateWithDuration(duration, delay: 0.0, options: animationCurve, animations: { [weak self] () -> Void in
                
                self?.priceAlertButtonBottomConstraint.constant = constantModification + 48
                
                self?.view.layoutIfNeeded()
                }, completion: nil)
        }
    }
    
    deinit
    {
        if let observer = keyboardNotificationObserver
        {
            NSNotificationCenter.defaultCenter().removeObserver(observer)
        }
    }
}