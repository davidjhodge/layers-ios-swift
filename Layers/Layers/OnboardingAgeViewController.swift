//
//  OnboardingAgeViewController.swift
//  Layers
//
//  Created by David Hodge on 4/23/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

class OnboardingAgeViewController: UIViewController
{
    @IBOutlet weak var skipButton: UIButton!
    
    @IBOutlet weak var ageTextField: UITextField!
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var bottomStartButtonConstraint: NSLayoutConstraint!

    var keyboardNotificationObserver: AnyObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skipButton.addTarget(self, action: #selector(skip), forControlEvents: .TouchUpInside)
        
        ageTextField.addTarget(self, action: #selector(textFieldChanged(_:)), forControlEvents: .EditingChanged)
        
        startButton.addTarget(self, action: #selector(start), forControlEvents: .TouchUpInside)
        
        startButton.userInteractionEnabled = false
        
        prepareToHandleKeyboard()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kProgressViewNeedsUpdateNotification, object: nil, userInfo: ["hidden": false,
            "progress": 0.9]))
        
        ageTextField.becomeFirstResponder()
    }
    
    // MARK: Actions
    func start()
    {
        view.endEditing(true)
        
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: kProgressViewNeedsUpdateNotification, object: nil, userInfo: ["hidden": false,
            "progress": 1.0]))
        
        AppStateTransitioner.transitionToMainStoryboard(true)
    }
    
    func skip()
    {
        view.endEditing(true)
        
        AppStateTransitioner.transitionToMainStoryboard(true)
    }
    
    func textFieldChanged(textField: UITextField)
    {
        if ageTextField.text!.characters.count > 0
        {
            enableStartButton()
        }
        else if ageTextField.text!.characters.count <= 0
        {
            disableStartButton()
        }
    }
    
    func enableStartButton()
    {
        if startButton.userInteractionEnabled == false
        {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                
                self.startButton.backgroundColor = Color.NeonBlueColor
                self.startButton.userInteractionEnabled = true
                
            })
        }
    }
    
    func disableStartButton()
    {
        if startButton.userInteractionEnabled == true
        {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                
                self.startButton.userInteractionEnabled = false
                self.startButton.backgroundColor = Color.LightGray
            })
        }
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
                
                self?.bottomStartButtonConstraint.constant = constantModification
                
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