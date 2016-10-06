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
    case email, password, count
}

class EmailLoginViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate
{
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var signInButtonBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!

    var delegate: AuthenticationDelegate?
    
    var keyboardNotificationObserver: AnyObject?
    
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        title = "login".uppercased()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        
        disableCTA()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel".uppercased(), style: .plain, target: self, action: #selector(cancel))
        
        spinner.color = Color.gray
        spinner.hidesWhenStopped = true
        spinner.isHidden = true
        view.addSubview(spinner)
        
        prepareToHandleKeyboard()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        spinner.center = tableView.center
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.layoutIfNeeded()
        
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TextFieldCell
        {
            cell.textField.becomeFirstResponder()
        }
    }
    
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Actions
    func cancel()
    {
        delegate?.userDidCancelAuthentication()
        
        view.endEditing(true)
        
        dismiss(animated: true, completion: nil)
    }
    
    // All text fields in view trigger this method on each text change
    func textFieldChanged()
    {
        let emailCell = tableView.cellForRow(at: IndexPath(row: TextField.email.rawValue, section: 0)) as! TextFieldCell
        let emailInput = emailCell.textField.text!
        
        let passwordCell = tableView.cellForRow(at: IndexPath(row: TextField.password.rawValue, section: 0)) as! TextFieldCell
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
        loginButton.isUserInteractionEnabled = false
        
        loginButton.setBackgroundColor(Color.lightGray, forState: UIControlState())
    }
    
    func enableCTA()
    {
        loginButton.isUserInteractionEnabled = true
        
        loginButton.setBackgroundColor(Color.NeonBlueColor, forState: UIControlState())
        loginButton.setBackgroundColor(Color.NeonBlueHighlightedColor, forState: .highlighted)
    }
    
    func login()
    {
        view.endEditing(true)
        
        let email = stringFromTextFieldCellAtIndex(TextField.email.rawValue)
        
        let password = stringFromTextFieldCellAtIndex(TextField.password.rawValue)
        
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
                        
                        DispatchQueue.main.async(execute: { () -> Void in
                            
                            self.view.endEditing(true)
                            
                            self.dismiss(animated: true, completion: nil)
                        })
                    }
                    else
                    {
                        DispatchQueue.main.async(execute: { () -> Void in
                            
                            let alert = UIAlertController(title: error, message: nil, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            
                            self.view.endEditing(false)
                            
                            self.enableCTA()
                        })
                    }
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.spinner.stopAnimating()
                    })
                })
            }
            else
            {
                // Invalid Password
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    let alert = UIAlertController(title: "ENTER_VALID_PASSWORD".localized, message: nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                })
            }
        }
        else
        {
            // Invalid Email
            DispatchQueue.main.async(execute: { () -> Void in
                
                let alert = UIAlertController(title: "ENTER_VALID_EMAIL".localized, message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            })
        }
    }
    
    // Helper method to access cell text fields
    func stringFromTextFieldCellAtIndex(_ index: Int) -> String
    {
        let indexPath = IndexPath(row: index, section: 0)
        
        if let textFieldCell = tableView.cellForRow(at: indexPath) as? TextFieldCell
        {
            if let textString = textFieldCell.textField.text
            {
                return textString
            }
        }
        
        return ""
    }
    
    // MARK: Text Field Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.tag == TextField.email.rawValue
        {
            let passwordCell = tableView.cellForRow(at: IndexPath(row: TextField.password.rawValue, section: 0)) as! TextFieldCell
            
            passwordCell.textField.becomeFirstResponder()
        }
        else if textField.tag == TextField.password.rawValue
        {
            view.endEditing(true)
        }
        
        return true
    }
    
    // MARK: Table View Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: TextFieldCell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell") as! TextFieldCell
        
        cell.textField.textColor = Color.DarkTextColor
        cell.selectionStyle = .none
        
        cell.textField.delegate = self
        cell.textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
                
        //Email
        if (indexPath as NSIndexPath).row == TextField.email.rawValue
        {
            cell.textField.placeholder = "Email"
            cell.textField.tag = TextField.email.rawValue
            
            cell.textField.returnKeyType = .next
        }
        //Password
        else if (indexPath as NSIndexPath).row == TextField.password.rawValue
        {
            cell.textField.placeholder = "Password"
            cell.textField.isSecureTextEntry = true
            cell.textField.tag = TextField.password.rawValue
            
            cell.textField.returnKeyType = .done
        }
        else
        {
            log.debug("cellForRowAtIndexPath Error")
        }
        
        return cell
    }
    
    // MARK: Table View Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 48.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
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
        keyboardNotificationObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil, queue: OperationQueue.main) { [weak self] (notification) -> Void in
            
            let frame : CGRect = ((notification as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            
            guard let keyboardFrameInViewCoordiantes = self?.view.convert(frame, from: nil), let bounds = self?.view.bounds else { return; }
            
            let constantModification = bounds.height - keyboardFrameInViewCoordiantes.origin.y
            
            let duration:TimeInterval = ((notification as NSNotification).userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = (notification as NSNotification).userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions().rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            
            
            UIView.animate(withDuration: duration, delay: 0.0, options: animationCurve, animations: { [weak self] () -> Void in
                
                self?.signInButtonBottomConstraint.constant = constantModification
                
                }, completion: nil)
        }
    }
    
    deinit
    {
        if let observer = keyboardNotificationObserver
        {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
