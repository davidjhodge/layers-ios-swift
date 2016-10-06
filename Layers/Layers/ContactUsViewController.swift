//
//  ContactUsViewController.swift
//  Layers
//
//  Created by David Hodge on 4/17/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit
import UITextView_Placeholder
import MBProgressHUD

private enum TableSection: Int
{
    case email, description, count
}

class ContactUsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var tableView: UITableView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        title = "Contact Us"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .done, target: self, action: #selector(send))
        
        tableView.backgroundColor = Color.BackgroundGrayColor
        
        tableView.separatorColor = Color(red: 237.0, green: 237.0, blue: 237.0, alpha: 1.0)
    }
    
    func send()
    {
        if let emailCell = tableView.cellForRow(at: IndexPath(row: 0, section: TableSection.email.rawValue)) as? TextFieldCell,
            let contentCell = tableView.cellForRow(at: IndexPath(row: 0, section: TableSection.description.rawValue)) as? TextViewCell
        {
            if let email = emailCell.textField.text,
                let content = contentCell.textView.text
            {
                if isValidEmail(email)
                {
                    LRSessionManager.sharedManager.submitContactForm(email, content: content, completionHandler: { (success, error, response) -> Void in
                        
                        if success
                        {
                            // Show success hud for 1.5 seconds. Hide it, end editing, and pop
                            
                            DispatchQueue.main.async {
                                    
                                let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                                hud.mode = .customView
                                hud.customView = UIImageView(image: UIImage(named: "checkmark"))
                                
                                hud.label.text = "Message Sent".uppercased()
                                hud.label.font = Font.OxygenBold(size: 17.0)
                                hud.hide(animated: true, afterDelay: 1.0)
                                
                                self.perform(#selector(self.done), with: nil, afterDelay: 1.0)
                            }
                        }
                        else
                        {
                            DispatchQueue.main.async {
                                
                                let alert = UIAlertController(title: error, message: nil, preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    })

                    return
                }
                else
                {
                    // Invalid Email
                    DispatchQueue.main.async(execute: { () -> Void in
                        
                        let alert = UIAlertController(title: "ENTER_VALID_EMAIL".localized, message: nil, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    })
                    
                    return
                }
            }
        }
        
        // Invalid parameters
        let alert = UIAlertController(title: "INVALID_PARAMETERS".localized, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func done()
    {
        self.view.endEditing(true)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: Table View Data Source
    func numberOfSections(in tableView: UITableView) -> Int {
        return TableSection.count.rawValue

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: TextFieldCell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell") as! TextFieldCell
        
        cell.selectionStyle = .none
        
        if let tableSection = TableSection(rawValue: (indexPath as NSIndexPath).section)
        {
            switch tableSection {
                
            case .email:
                
                cell.textField.placeholder = "Email"

            case.description:
                
                let textViewCell: TextViewCell = tableView.dequeueReusableCell(withIdentifier: "TextViewCell") as! TextViewCell
                
                textViewCell.textView.placeholder = "Description"
                
                textViewCell.selectionStyle = .none
                
                return textViewCell

            default:
                return cell
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (indexPath as NSIndexPath).section == TableSection.description.rawValue
        {
            return 128.0
        }
        else
        {
            return 48.0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 8
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.01
    }
}
