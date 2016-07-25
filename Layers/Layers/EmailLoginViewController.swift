//
//  EmailLoginViewController.swift
//  Layers
//
//  Created by David Hodge on 4/11/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

private enum TextField: Int
{
    case Email, Password, Count
}

class EmailLoginViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate
{
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var signInButtonBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!

    var delegate: AuthenticationDelegate?
    
    var keyboardNotificationObserver: AnyObject?
    
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        title = "login".uppercaseString
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.addTarget(self, action: #selector(login), forControlEvents: .TouchUpInside)
        
        disableCTA()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel".uppercaseString, style: .Plain, target: self, action: #selector(cancel))
        
        spinner.color = Color.grayColor()
        spinner.hidesWhenStopped = true
        spinner.hidden = true
        view.addSubview(spinner)
        
        prepareToHandleKeyboard()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        spinner.center = tableView.center
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.layoutIfNeeded()
        
        if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? TextFieldCell
        {
            cell.textField.becomeFirstResponder()
        }
    }
    
    // MARK: Actions
    func cancel()
    {
        view.endEditing(true)
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // All text fields in view trigger this method on each text change
    func textFieldChanged()
    {
        let emailCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: TextField.Email.rawValue, inSection: 0)) as! TextFieldCell
        let emailInput = emailCell.textField.text!
        
        let passwordCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: TextField.Password.rawValue, inSection: 0)) as! TextFieldCell
        let passwordInput = passwordCell.textField.text!
        
        if isValidEmail(emailInput) && isValidPassword(passwordInput)
        {
            enableCTA()
        }
        else
        {
            disableCTA()
        }
    }
    
    func disableCTA()
    {
        loginButton.userInteractionEnabled = false
        
        loginButton.setBackgroundColor(Color.lightGrayColor(), forState: .Normal)
    }
    
    func enableCTA()
    {
        loginButton.userInteractionEnabled = true
        
        loginButton.setBackgroundColor(Color.NeonBlueColor, forState: .Normal)
        loginButton.setBackgroundColor(Color.NeonBlueHighlightedColor, forState: .Highlighted)
    }
    
    func login()
    {
        view.endEditing(true)
        
        let email = stringFromTextFieldCellAtIndex(TextField.Email.rawValue)
        
        let password = stringFromTextFieldCellAtIndex(TextField.Password.rawValue)
        
        if isValidEmail(email)
        {
            if isValidPassword(password)
            {
                spinner.startAnimating()
                
                disableCTA()
                
                LRSessionManager.sharedManager.loginWithEmail(email, password: password, completionHandler: { (success, error, response) -> Void in
                    
                    if success
                    {
                        // Login to user pool succeeded
                        self.delegate?.authenticationDidSucceed()
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            self.view.endEditing(true)
                            
                            self.dismissViewControllerAnimated(true, completion: nil)
                        })
                    }
                    else
                    {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            let alert = UIAlertController(title: error, message: nil, preferredStyle: .Alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                            
                            self.view.endEditing(false)
                            
                            self.enableCTA()
                        })
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.spinner.stopAnimating()
                    })
                })
            }
            else
            {
                // Invalid Password
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    let alert = UIAlertController(title: "ENTER_VALID_PASSWORD".localized, message: nil, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                })
            }
        }
        else
        {
            // Invalid Email
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                let alert = UIAlertController(title: "ENTER_VALID_EMAIL".localized, message: nil, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            })
        }
    }
    
    // Helper method to access cell text fields
    func stringFromTextFieldCellAtIndex(index: Int) -> String
    {
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        
        if let textFieldCell = tableView.cellForRowAtIndexPath(indexPath) as? TextFieldCell
        {
            if let textString = textFieldCell.textField.text
            {
                return textString
            }
        }
        
        return ""
    }
    
    // MARK: Text Field Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField.tag == TextField.Email.rawValue
        {
            let passwordCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: TextField.Password.rawValue, inSection: 0)) as! TextFieldCell
            
            passwordCell.textField.becomeFirstResponder()
        }
        else if textField.tag == TextField.Password.rawValue
        {
            view.endEditing(true)
        }
        
        return true
    }
    
    // MARK: Table View Data Source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: TextFieldCell = tableView.dequeueReusableCellWithIdentifier("TextFieldCell") as! TextFieldCell
        
        cell.textField.textColor = Color.DarkTextColor
        cell.selectionStyle = .None
        
        cell.textField.delegate = self
        cell.textField.addTarget(self, action: #selector(textFieldChanged), forControlEvents: .EditingChanged)
                
        //Email
        if indexPath.row == TextField.Email.rawValue
        {
            cell.textField.placeholder = "Email"
            cell.textField.tag = TextField.Email.rawValue
            
            cell.textField.returnKeyType = .Next
        }
        //Password
        else if indexPath.row == TextField.Password.rawValue
        {
            cell.textField.placeholder = "Password"
            cell.textField.secureTextEntry = true
            cell.textField.tag = TextField.Password.rawValue
            
            cell.textField.returnKeyType = .Done
        }
        else
        {
            log.debug("cellForRowAtIndexPath Error")
        }
        
        return cell
    }
    
    // MARK: Table View Delegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 48.0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0
        {
            return 0.01
        }
        else
        {
            return 24.0
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
                
                self?.signInButtonBottomConstraint.constant = constantModification
                
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