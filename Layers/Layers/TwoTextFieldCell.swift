//
//  TwoTextFieldCell.swift
//  Layers
//
//  Created by David Hodge on 6/13/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation

class TwoTextFieldCell: UITableViewCell
{
    @IBOutlet weak var firstTextField: UITextField!
    
    @IBOutlet weak var secondTextField: UITextField!
    
    @IBOutlet weak var separatorView: UIView!
    
    @IBOutlet weak var separatorViewWidthConstraint: NSLayoutConstraint!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        separatorViewWidthConstraint.constant = 1.0 / UIScreen.main.scale
    }
}
