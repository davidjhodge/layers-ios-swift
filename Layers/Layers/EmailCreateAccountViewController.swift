//
//  EmailCreateAccountViewController.swift
//  Layers
//
//  Created by David Hodge on 4/17/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

protocol AuthenticationDelegate {
    
    func authenticationDidSucceed()
}

private enum CellType: Int
{
    case Email, Password, RetypePassword, Count
}

class EmailCreateAccountViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate
{
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var createAccountButton: UIButton!
    
    @IBOutlet weak var createAccountButtonBottomConstraint: NSLayoutConstraint!
    
    var delegate: AuthenticationDelegate?
    
    var keyboardNotificationObserver: AnyObject?
    
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        title = "create account".uppercaseString
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createAccountButton.addTarget(self, action: #selector(createAccount), forControlEvents: .TouchUpInside)
        
        // By default, CTA is disabled until valid input is entered
        disableCTA()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel".uppercaseString, style: .Plain, target: self, action: #selector(cancel))
        
        spinner.hidesWhenStopped = true
        spinner.color = Color.grayColor()
        spinner.hidesWhenStopped = true
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
        let emailCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: CellType.Email.rawValue, inSection: 0)) as! TextFieldCell
        let emailInput = emailCell.textField.text!
        
        let passwordCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: CellType.Password.rawValue, inSection: 0)) as! TextFieldCell
        let passwordInput = passwordCell.textField.text!
        
        let retypePasswordCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: CellType.RetypePassword.rawValue, inSection: 0)) as! TextFieldCell
        let retypePasswordInput = retypePasswordCell.textField.text!
        
        if isValidEmail(emailInput) && isValidPassword(passwordInput) && isValidPassword(retypePasswordInput) && passwordInput == retypePasswordInput
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
        createAccountButton.userInteractionEnabled = false
        
        createAccountButton.setBackgroundColor(Color.lightGrayColor(), forState: .Normal)
    }
    
    func enableCTA()
    {
        createAccountButton.userInteractionEnabled = true
        
        createAccountButton.setBackgroundColor(Color.NeonBlueColor, forState: .Normal)
        createAccountButton.setBackgroundColor(Color.NeonBlueHighlightedColor, forState: .Highlighted)
    }
    
    func createAccount()
    {
        let emailCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: CellType.Email.rawValue, inSection: 0)) as! TextFieldCell
        let emailInput = emailCell.textField.text!
        
        let passwordCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: CellType.Password.rawValue, inSection: 0)) as! TextFieldCell
        let passwordInput = passwordCell.textField.text!
        
        if isValidEmail(emailInput)
        {
            if isValidPassword(passwordInput)
            {
                // Email and password are valid. Disable UI and make API Call
                view.endEditing(true)
                
                tableView.userInteractionEnabled = false
                createAccountButton.userInteractionEnabled = false
                
                spinner.startAnimating()

                LRSessionManager.sharedManager.registerWithEmail(emailInput, password: passwordInput, firstName: "", lastName: "", gender: "", age: 0, completionHandler: { (success, error, response) -> Void in
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        self.spinner.stopAnimating()
                    })
                    
                    if success
                    {
                        // Signing up to user pool succeeded
                        self.delegate?.authenticationDidSucceed()
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            self.view.endEditing(true)

                            self.dismissViewControllerAnimated(true, completion: nil)
                        })
                    }
                    else
                    {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            
                            self.tableView.userInteractionEnabled = true
                            self.createAccountButton.userInteractionEnabled = true
                            
                            let alert = UIAlertController(title: error, message: nil, preferredStyle: .Alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        })
                    }
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
    
    // MARK: Text Field Delegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField.tag == CellType.Email.rawValue
        {
            let passwordCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: CellType.Password.rawValue, inSection: 0)) as! TextFieldCell
            
            passwordCell.textField.becomeFirstResponder()
        }
        else if textField.tag == CellType.Password.rawValue
        {
            let retypePasswordCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: CellType.RetypePassword.rawValue, inSection: 0)) as! TextFieldCell
            
            retypePasswordCell.textField.becomeFirstResponder()
        }
        else if textField.tag == CellType.RetypePassword.rawValue
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
        return CellType.Count.rawValue
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: TextFieldCell = tableView.dequeueReusableCellWithIdentifier("TextFieldCell") as! TextFieldCell
        
        cell.textField.textColor = Color.DarkTextColor
        cell.selectionStyle = .None
    
        cell.textField.delegate = self
        cell.textField.addTarget(self, action: #selector(textFieldChanged), forControlEvents: .EditingChanged)
        
        //Email
        if indexPath.row == CellType.Email.rawValue
        {
            cell.textField.placeholder = "Email"
            cell.textField.tag = CellType.Email.rawValue
            
            cell.textField.returnKeyType = .Next
        }
        //Password
        else if indexPath.row == CellType.Password.rawValue
        {
            cell.textField.placeholder = "Password"
            cell.textField.secureTextEntry = true
            cell.textField.tag = CellType.Password.rawValue

            cell.textField.returnKeyType = .Next
        }
        //Retype password
        else if indexPath.row == CellType.RetypePassword.rawValue
        {
            cell.textField.placeholder = "Retype your password"
            cell.textField.secureTextEntry = true
            cell.textField.tag = CellType.RetypePassword.rawValue
            
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
                
                self?.createAccountButtonBottomConstraint.constant = constantModification
                
                }, completion: nil)
        }
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}