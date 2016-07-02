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

enum GenderOption: NSInteger
{
    case Male = 0, Female, OtherSpecific, NotKnown, NotSpecific, Count
}

class ConfirmFacebookInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate
{
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var submitButtonBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet var pickerAccessoryView: PickerAccessoryView!
    
    @IBOutlet weak var pickerViewHeightConstraint: NSLayoutConstraint!
    
    var delegate: AuthenticationDelegate?
    
    var facebookResponse: FacebookUserResponse?
    
    var selectedGender: GenderOption?

    var isModal: Bool = false
    
    var keyboardNotificationObserver: AnyObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.scrollEnabled = false
        
        submitButton.setBackgroundColor(Color.NeonBlueColor, forState: .Normal)
        submitButton.setBackgroundColor(Color.NeonBlueHighlightedColor, forState: .Highlighted)
        
        submitButton.addTarget(self, action: #selector(submit), forControlEvents: .TouchUpInside)
        
        headerLabel.font = Font.OxygenRegular(size: 18.0)
        
        configureGenderPicker()
        
        prepareToHandleKeyboard()
    }
    
    func configureGenderPicker()
    {        
        pickerView.backgroundColor = Color.BackgroundGrayColor
        
        pickerView.dataSource = self
        
        pickerView.delegate = self
        
        if let genderAgeCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: TableRow.GenderAge.rawValue, inSection: 0)) as? TwoTextFieldCell
        {
            if let genderTextField = genderAgeCell.firstTextField
            {
                genderTextField.inputView = pickerView
                
                genderTextField.inputAccessoryView = nil
            }
        }
    }
    
    func validateEmail() -> Bool
    {
        let emailCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: TableRow.Email.rawValue, inSection: 0)) as? TextFieldCell
        
        if let emailTextField = emailCell?.textField
        {
            if let email = emailTextField.text
            {
                if email.rangeOfString("@") != nil && email.rangeOfString(".") != nil
                {
                    return true
                }
            }
        }
        
        return false
    }
    
    // MARK: Actions
    func submit()
    {
        if validateEmail()
        {
            if let nameCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: TableRow.Name.rawValue, inSection: 0)) as? TwoTextFieldCell,
                
                let genderAgeCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: TableRow.GenderAge.rawValue, inSection: 0)) as? TwoTextFieldCell,
                
                let emailCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: TableRow.Email.rawValue, inSection: 0)) as? TextFieldCell
            {
                let firstName = nameCell.firstTextField.text
                let lastName = nameCell.secondTextField.text
                let gender = genderAgeCell.firstTextField.text
                let age = NSNumber.aws_numberFromString(genderAgeCell.secondTextField.text)
                let email = emailCell.textField.text
                
                LRSessionManager.sharedManager.loginWithFacebook({ (success, error, response) -> Void in
                    
                    if success
                    {
                        self.completeFirstLaunchExperience()
                        
                        return
                    }
                    else
                    {
                        // Try Creating an account with Facebook
                        if let email = email
                        {
                            LRSessionManager.sharedManager.registerWithFacebook(email, firstName: firstName, lastName: lastName, gender: gender, age: age, completionHandler: { (success, error, response) -> Void in
                                
                                if success
                                {
                                    self.completeFirstLaunchExperience()
                                    
                                    return
                                }
                            })
                        }
                    }
                    
                    //Failure
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                      
                        let alert = UIAlertController(title: error, message: nil, preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    })
                })
            }
        }
        else
        {
            let alert = UIAlertController(title: "Whoops! Check to make sure you entered a valid email.", message: nil, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func completeFirstLaunchExperience()
    {
        LRSessionManager.sharedManager.completeFirstLaunch()
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            self.view.endEditing(true)
        })
        
        if isModal
        {
            // Logged in on Account Page
            dispatch_async(dispatch_get_main_queue(), { () -> Void in

                self.dismissViewControllerAnimated(true, completion: nil)
            })
        
            if let authDelegate = delegate
            {
                authDelegate.authenticationDidSucceed()
            }
        }
        else
        {
            // Logged in on Get Started Screen
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                AppStateTransitioner.transitionToMainStoryboard(true)
            })
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
                
                cell.separatorView.backgroundColor = tableView.separatorColor

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
                
                cell.separatorView.backgroundColor = tableView.separatorColor
                
                cell.selectionStyle = .None

                // Gender
                cell.firstTextField.placeholder = "Gender"
                
                // Should allow picker selection of male or female
                if let picker = pickerView
                {
                    cell.firstTextField.inputView = picker
                    
                    cell.firstTextField.tintColor = Color.clearColor()
                    
                    cell.firstTextField.inputAccessoryView = nil
                }
                
                cell.firstTextField.autocapitalizationType = .Words
                
                if let gender = facebookResponse?.gender
                {
                    cell.firstTextField.text = gender.capitalizedString
                }
                else
                {
                    cell.firstTextField.text = "Other Specific"
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
    // None
    
    // MARK: Picker View Data Source
    // MARK: Picker View
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return GenderOption.Count.rawValue
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        
        if view == nil
        {
            // Remove selection indicators
            pickerView.subviews[1].hidden = true
            pickerView.subviews[2].hidden = true
            
            if let pickerRow: PickerRow = NSBundle.mainBundle().loadNibNamed("PickerRow", owner: self, options: nil)[0] as? PickerRow
            {
                pickerRow.colorSwatchView.hidden = true
       
                pickerRow.bounds = CGRectMake(pickerRow.bounds.origin.x, pickerRow.bounds.origin.y, UIScreen .mainScreen().bounds.width, pickerRow.bounds.size.height)
                
                if let genderOption = GenderOption(rawValue: row)
                {
                    switch genderOption
                    {
                    case .Male:
                        pickerRow.textLabel.text = "Male"
                        
                    case .Female:
                        pickerRow.textLabel.text = "Female"
                        
                    case .OtherSpecific:
                        pickerRow.textLabel.text = "Other Specific"
                        
                    case .NotKnown:
                        pickerRow.textLabel.text = "Not Known"
                        
                    case .NotSpecific:
                        pickerRow.textLabel.text = "Not Specific"
                        
                    default:
                        break
                    }
                }
  
                return pickerRow
            }
            
            return UIView()
        }
        else
        {
            if let reuseView = view
            {
                return reuseView
            }
        }
        
        return UIView()
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        
        return view.bounds.size.width
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        
        return 48.0
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if let gender = GenderOption(rawValue: row)
        {
            switch gender
            {
            case .Male:
                return "Male"
                
            case .Female:
                return "Female"
                
            case .OtherSpecific:
                return "Other Specific"
                
            case .NotKnown:
                return "Not Known"
                
            case .NotSpecific:
                return "Not Specific"
                
            default:
                break
            }
        }
        
        return ""
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if let gender = GenderOption(rawValue: row)
        {
            selectedGender = gender
            
            if let genderAgeCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: TableRow.GenderAge.rawValue, inSection: 0)) as? TwoTextFieldCell
            {
                if let genderTextField = genderAgeCell.firstTextField
                {
                    switch gender
                    {
                    case .Male:
                        genderTextField.text = "Male"
                        
                    case .Female:
                        genderTextField.text = "Female"
                        
                    case .OtherSpecific:
                        genderTextField.text = "Other Specific"
                        
                    case .NotKnown:
                        genderTextField.text = "Not Known"
                        
                    case .NotSpecific:
                        genderTextField.text = "Not Specific"
                        
                    default:
                        break
                    }
                }
            }
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
                
                self?.submitButtonBottomConstraint.constant = constantModification
                
                self?.view.layoutIfNeeded()
                }, completion: nil)
        }
    }
}