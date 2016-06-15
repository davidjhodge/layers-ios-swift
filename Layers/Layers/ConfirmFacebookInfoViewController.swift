//
//  ConfirmFacebookInfoViewController.swift
//  Layers
//
//  Created by David Hodge on 6/13/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

private enum TableRow: NSInteger
{
    case Name = 0, GenderAge, Email, Count
}

class ConfirmFacebookInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var submitButtonBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var headerLabel: UILabel!
    
    var facebookResponse: FacebookUserResponse?
    
    var isModal: Bool = false
    
    var keyboardNotificationObserver: AnyObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.scrollEnabled = false
        
        submitButton.addTarget(self, action: #selector(submit), forControlEvents: .TouchUpInside)
        
        headerLabel.font = Font.OxygenRegular(size: 18.0)
        
        prepareToHandleKeyboard()
    }
    
    // MARK: Actions
    func submit()
    {
        completeFirstLaunchExperience()
    }
    
    func completeFirstLaunchExperience()
    {
        LRSessionManager.sharedManager.completeFirstLaunch()
        
        if isModal
        {
            // Logged in on Account Page
            dismissViewControllerAnimated(true, completion: nil)
        }
        else
        {
            // Logged in on Get Started Screen
            AppStateTransitioner.transitionToMainStoryboard(true)
        }
    }
    
    // MARK: Table View Data Source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
         return TableRow.Count.rawValue
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let tableRow = TableRow(rawValue: indexPath.row)
        {
            if tableRow == .Name
            {
                let cell = tableView.dequeueReusableCellWithIdentifier("TwoTextFieldCell") as! TwoTextFieldCell
                
                cell.selectionStyle = .None
                
                // First Name
                cell.firstTextField.placeholder = "First Name"
        
                cell.firstTextField.autocapitalizationType = .Words
                cell.firstTextField.autocorrectionType = .No
                
                if let firstName = facebookResponse?.firstName
                {
                    cell.firstTextField.text = firstName
                }
                
                // Last Name
                cell.secondTextField.placeholder = "Last Name"
                
                cell.secondTextField.autocapitalizationType = .Words
                cell.secondTextField.autocorrectionType = .No

                if let lastName = facebookResponse?.lastName
                {
                    cell.secondTextField.text = lastName
                }
                
                return cell
            }
            else if tableRow == .GenderAge
            {
                let cell = tableView.dequeueReusableCellWithIdentifier("TwoTextFieldCell") as! TwoTextFieldCell
                
                cell.selectionStyle = .None

                // Gender
                cell.firstTextField.placeholder = "Gender"
                
                // Should allow picker selection of male or female
                cell.firstTextField.autocapitalizationType = .Words
                
                if let gender = facebookResponse?.gender
                {
                    cell.firstTextField.text = gender.capitalizedString
                }
                
                // Age
                cell.secondTextField.placeholder = "Age"
                
                cell.secondTextField.keyboardType = .NumberPad
                
                if let ageRange = facebookResponse?.ageRange
                {
                    if let predictedAge = ageRange.predictedAge()
                    {
                        cell.secondTextField.text = String(predictedAge)
                    }
                }
                
                return cell
            }
            else if tableRow == .Email
            {
                let cell = tableView.dequeueReusableCellWithIdentifier("TextFieldCell") as! TextFieldCell
                
                cell.selectionStyle = .None
                
                // Email
                cell.textField.placeholder = "Email"
                
                cell.textField.autocapitalizationType = .None
                cell.textField.autocorrectionType = .No
                
                if let email = facebookResponse?.email
                {
                    cell.textField.text = email
                }
                
                return cell
            }
        }
        
        return UITableViewCell(style: .Default, reuseIdentifier: "UITableViewCell")
    }
    
    // MARK: Table View Delegate
    
    
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
                
                self?.submitButtonBottomConstraint.constant = constantModification
                
                self?.view.layoutIfNeeded()
                }, completion: nil)
        }
    }
}