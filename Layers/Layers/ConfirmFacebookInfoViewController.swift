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
    case name = 0, genderAge, email, count
}

enum GenderOption: NSInteger
{
    case male = 0, female, otherSpecific, notKnown, notSpecific, count
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
        tableView.isScrollEnabled = false
        
        submitButton.setBackgroundColor(Color.NeonBlueColor, forState: UIControlState())
        submitButton.setBackgroundColor(Color.NeonBlueHighlightedColor, forState: .highlighted)
        
        submitButton.addTarget(self, action: #selector(submit), for: .touchUpInside)
        
        headerLabel.font = Font.OxygenRegular(size: 18.0)
        
        configureGenderPicker()
        
        prepareToHandleKeyboard()
    }
    
    func configureGenderPicker()
    {        
        pickerView.backgroundColor = Color.BackgroundGrayColor
        
        pickerView.dataSource = self
        
        pickerView.delegate = self
        
        if let genderAgeCell = tableView.cellForRow(at: IndexPath(row: TableRow.genderAge.rawValue, section: 0)) as? TwoTextFieldCell
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
        let emailCell = tableView.cellForRow(at: IndexPath(row: TableRow.email.rawValue, section: 0)) as? TextFieldCell
        
        if let emailTextField = emailCell?.textField
        {
            if let email = emailTextField.text
            {
                if email.range(of: "@") != nil && email.range(of: ".") != nil
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
            if let nameCell = tableView.cellForRow(at: IndexPath(row: TableRow.name.rawValue, section: 0)) as? TwoTextFieldCell,
                
                let genderAgeCell = tableView.cellForRow(at: IndexPath(row: TableRow.genderAge.rawValue, section: 0)) as? TwoTextFieldCell,
                
                let emailCell = tableView.cellForRow(at: IndexPath(row: TableRow.email.rawValue, section: 0)) as? TextFieldCell
            {
                let firstName = nameCell.firstTextField.text
                let lastName = nameCell.secondTextField.text
                let gender = genderAgeCell.firstTextField.text
                
                var age: NSNumber = NSNumber(value: 0)
                
                if let ageText = genderAgeCell.secondTextField.text
                {
                    if let ageInteger = Int(ageText)
                    {
                        age = NSNumber(value: ageInteger)
                    }
                }

                let email = emailCell.textField.text
                
                if let email = email
                {
                    LRSessionManager.sharedManager.connectWithFacebook(email, firstName: firstName, lastName: lastName, gender: gender, age: age, completionHandler: { (success, error, response) -> Void in
                        
                        if success
                        {
                            self.completeFirstLaunchExperience()
                        }
                        else
                        {
                            //Failure
                            DispatchQueue.main.async {
                                
                                let alert = UIAlertController(title: error, message: nil, preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    })
                }
            }
        }
        else
        {
            let alert = UIAlertController(title: "Whoops! Check to make sure you entered a valid email.", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func completeFirstLaunchExperience()
    {
        LRSessionManager.sharedManager.completeFirstLaunch()
        
        DispatchQueue.main.async(execute: { () -> Void in
            
            self.view.endEditing(true)
        })
        
        DispatchQueue.main.async(execute: { () -> Void in
            
            self.dismiss(animated: true, completion: nil)
        })
        
        if let authDelegate = delegate
        {
            authDelegate.authenticationDidSucceed()
        }
    }
    
    // MARK: Table View Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
         return TableRow.count.rawValue
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let tableRow = TableRow(rawValue: (indexPath as NSIndexPath).row)
        {
            if tableRow == .name
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TwoTextFieldCell") as! TwoTextFieldCell
                
                cell.separatorView.backgroundColor = tableView.separatorColor

                cell.selectionStyle = .none
                
                // First Name
                cell.firstTextField.placeholder = "First Name"
        
                cell.firstTextField.autocapitalizationType = .words
                cell.firstTextField.autocorrectionType = .no
                
                if let firstName = facebookResponse?.firstName
                {
                    cell.firstTextField.text = firstName
                }
                
                // Last Name
                cell.secondTextField.placeholder = "Last Name"
                
                cell.secondTextField.autocapitalizationType = .words
                cell.secondTextField.autocorrectionType = .no

                if let lastName = facebookResponse?.lastName
                {
                    cell.secondTextField.text = lastName
                }
                
                return cell
            }
            else if tableRow == .genderAge
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TwoTextFieldCell") as! TwoTextFieldCell
                
                cell.separatorView.backgroundColor = tableView.separatorColor
                
                cell.selectionStyle = .none

                // Gender
                cell.firstTextField.placeholder = "Gender"
                
                // Should allow picker selection of male or female
                if let picker = pickerView
                {
                    cell.firstTextField.inputView = picker
                    
                    cell.firstTextField.tintColor = Color.clear
                    
                    cell.firstTextField.inputAccessoryView = nil
                }
                
                cell.firstTextField.autocapitalizationType = .words
                
                if let gender = facebookResponse?.gender
                {
                    cell.firstTextField.text = gender.capitalized
                }
                else
                {
                    cell.firstTextField.text = "Other Specific"
                }
                
                // Age
                cell.secondTextField.placeholder = "Age"
                
                cell.secondTextField.keyboardType = .numberPad
                
                if let ageRange = facebookResponse?.ageRange
                {
                    if let predictedAge = ageRange.predictedAge()
                    {
                        cell.secondTextField.text = predictedAge.stringValue
                    }
                }
                
                return cell
            }
            else if tableRow == .email
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell") as! TextFieldCell
                
                cell.selectionStyle = .none
                
                // Email
                cell.textField.placeholder = "Email"
                
                cell.textField.autocapitalizationType = .none
                cell.textField.autocorrectionType = .no
                
                if let email = facebookResponse?.email
                {
                    cell.textField.text = email
                }
                
                return cell
            }
        }
        
        return UITableViewCell(style: .default, reuseIdentifier: "UITableViewCell")
    }
    
    // MARK: Table View Delegate
    // None
    
    // MARK: Picker View Data Source
    // MARK: Picker View
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return GenderOption.count.rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        if view == nil
        {
            // Remove selection indicators
            pickerView.subviews[1].isHidden = true
            pickerView.subviews[2].isHidden = true
            
            if let pickerRow: PickerRow = Bundle.main.loadNibNamed("PickerRow", owner: self, options: nil)?[0] as? PickerRow
            {
                pickerRow.colorSwatchView.isHidden = true
       
                pickerRow.bounds = CGRect(x: pickerRow.bounds.origin.x, y: pickerRow.bounds.origin.y, width: UIScreen.main.bounds.width, height: pickerRow.bounds.size.height)
                
                if let genderOption = GenderOption(rawValue: row)
                {
                    switch genderOption
                    {
                    case .male:
                        pickerRow.textLabel.text = "Male"
                        
                    case .female:
                        pickerRow.textLabel.text = "Female"
                        
                    case .otherSpecific:
                        pickerRow.textLabel.text = "Other Specific"
                        
                    case .notKnown:
                        pickerRow.textLabel.text = "Not Known"
                        
                    case .notSpecific:
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
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        
        return view.bounds.size.width
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        
        return 48.0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if let gender = GenderOption(rawValue: row)
        {
            switch gender
            {
            case .male:
                return "Male"
                
            case .female:
                return "Female"
                
            case .otherSpecific:
                return "Other Specific"
                
            case .notKnown:
                return "Not Known"
                
            case .notSpecific:
                return "Not Specific"
                
            default:
                break
            }
        }
        
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if let gender = GenderOption(rawValue: row)
        {
            selectedGender = gender
            
            if let genderAgeCell = tableView.cellForRow(at: IndexPath(row: TableRow.genderAge.rawValue, section: 0)) as? TwoTextFieldCell
            {
                if let genderTextField = genderAgeCell.firstTextField
                {
                    switch gender
                    {
                    case .male:
                        genderTextField.text = "Male"
                        
                    case .female:
                        genderTextField.text = "Female"
                        
                    case .otherSpecific:
                        genderTextField.text = "Other Specific"
                        
                    case .notKnown:
                        genderTextField.text = "Not Known"
                        
                    case .notSpecific:
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
        keyboardNotificationObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil, queue: OperationQueue.main) { [weak self] (notification) -> Void in
            
            let frame : CGRect = ((notification as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            
            guard let keyboardFrameInViewCoordiantes = self?.view.convert(frame, from: nil), let bounds = self?.view.bounds else { return; }
            
            let constantModification = bounds.height - keyboardFrameInViewCoordiantes.origin.y
            
            let duration:TimeInterval = ((notification as NSNotification).userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = (notification as NSNotification).userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions().rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            
            
            UIView.animate(withDuration: duration, delay: 0.0, options: animationCurve, animations: { [weak self] () -> Void in
                
                self?.submitButtonBottomConstraint.constant = constantModification
                
                }, completion: nil)
        }
    }
}
