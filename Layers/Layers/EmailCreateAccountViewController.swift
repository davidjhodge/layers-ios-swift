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
    
    func userDidCancelAuthentication()
    
    func authenticationDidSucceed()
}

private enum CellType: Int
{
    case email, password, retypePassword, count
}

class EmailCreateAccountViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate
{
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var createAccountButton: UIButton!
    
    @IBOutlet weak var createAccountButtonBottomConstraint: NSLayoutConstraint!
    
    var delegate: AuthenticationDelegate?
    
    var keyboardNotificationObserver: AnyObject?
    
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        title = "create account".uppercased()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createAccountButton.addTarget(self, action: #selector(createAccount), for: .touchUpInside)
        
        // By default, CTA is disabled until valid input is entered
        disableCTA()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel".uppercased(), style: .plain, target: self, action: #selector(cancel))
        
        spinner.hidesWhenStopped = true
        spinner.color = Color.gray
        spinner.hidesWhenStopped = true
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
        let emailCell = tableView.cellForRow(at: IndexPath(row: CellType.email.rawValue, section: 0)) as! TextFieldCell
        let emailInput = emailCell.textField.text!
        
        let passwordCell = tableView.cellForRow(at: IndexPath(row: CellType.password.rawValue, section: 0)) as! TextFieldCell
        let passwordInput = passwordCell.textField.text!
        
        let retypePasswordCell = tableView.cellForRow(at: IndexPath(row: CellType.retypePassword.rawValue, section: 0)) as! TextFieldCell
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
        createAccountButton.isUserInteractionEnabled = false
        
        createAccountButton.setBackgroundColor(Color.lightGray, forState: UIControlState())
    }
    
    func enableCTA()
    {
        createAccountButton.isUserInteractionEnabled = true
        
        createAccountButton.setBackgroundColor(Color.NeonBlueColor, forState: UIControlState())
        createAccountButton.setBackgroundColor(Color.NeonBlueHighlightedColor, forState: .highlighted)
    }
    
    func createAccount()
    {
        let emailCell = tableView.cellForRow(at: IndexPath(row: CellType.email.rawValue, section: 0)) as! TextFieldCell
        let emailInput = emailCell.textField.text!
        
        let passwordCell = tableView.cellForRow(at: IndexPath(row: CellType.password.rawValue, section: 0)) as! TextFieldCell
        let passwordInput = passwordCell.textField.text!
        
        if isValidEmail(emailInput)
        {
            if isValidPassword(passwordInput)
            {
                // Email and password are valid. Disable UI and make API Call
                view.endEditing(true)
                
                tableView.isUserInteractionEnabled = false
                
                disableCTA()
                
                spinner.startAnimating()

                LRSessionManager.sharedManager.registerWithEmail(emailInput, password: passwordInput, firstName: "", lastName: "", gender: "", age: 0, completionHandler: { (success, error, response) -> Void in
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                        
                        self.spinner.stopAnimating()
                    })
                    
                    if success
                    {
                        // Signing up to user pool succeeded
                        self.delegate?.authenticationDidSucceed()
                        
                        DispatchQueue.main.async(execute: { () -> Void in
                            
                            self.view.endEditing(true)

                            self.dismiss(animated: true, completion: nil)
                        })
                    }
                    else
                    {
                        DispatchQueue.main.async(execute: { () -> Void in
                            
                            self.tableView.isUserInteractionEnabled = true
                            self.createAccountButton.isUserInteractionEnabled = true
                            
                            let alert = UIAlertController(title: error, message: nil, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            
                            self.enableCTA()
                        })
                    }
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
    
    // MARK: Text Field Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.tag == CellType.email.rawValue
        {
            let passwordCell = tableView.cellForRow(at: IndexPath(row: CellType.password.rawValue, section: 0)) as! TextFieldCell
            
            passwordCell.textField.becomeFirstResponder()
        }
        else if textField.tag == CellType.password.rawValue
        {
            let retypePasswordCell = tableView.cellForRow(at: IndexPath(row: CellType.retypePassword.rawValue, section: 0)) as! TextFieldCell
            
            retypePasswordCell.textField.becomeFirstResponder()
        }
        else if textField.tag == CellType.retypePassword.rawValue
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
        return CellType.count.rawValue
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: TextFieldCell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell") as! TextFieldCell
        
        cell.textField.textColor = Color.DarkTextColor
        cell.selectionStyle = .none
    
        cell.textField.delegate = self
        cell.textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        //Email
        if (indexPath as NSIndexPath).row == CellType.email.rawValue
        {
            cell.textField.placeholder = "Email"
            cell.textField.tag = CellType.email.rawValue
            
            cell.textField.returnKeyType = .next
        }
        //Password
        else if (indexPath as NSIndexPath).row == CellType.password.rawValue
        {
            cell.textField.placeholder = "Password"
            cell.textField.isSecureTextEntry = true
            cell.textField.tag = CellType.password.rawValue

            cell.textField.returnKeyType = .next
        }
        //Retype password
        else if (indexPath as NSIndexPath).row == CellType.retypePassword.rawValue
        {
            cell.textField.placeholder = "Retype your password"
            cell.textField.isSecureTextEntry = true
            cell.textField.tag = CellType.retypePassword.rawValue
            
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
                
                self?.createAccountButtonBottomConstraint.constant = constantModification
                
                }, completion: nil)
        }
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver(self)
    }
}
