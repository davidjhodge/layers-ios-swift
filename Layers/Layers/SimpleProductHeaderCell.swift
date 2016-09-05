//
//  SimpleProductHeaderCell.swift
//  Layers
//
//  Created by David Hodge on 4/12/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

class SimpleProductHeaderCell: UITableViewCell
{
    @IBOutlet weak var productImageView: UIImageView!
    
    @IBOutlet weak var brandLabel: UILabel!
    
    @IBOutlet weak var productNameLabel: UILabel!
    
    @IBOutlet weak var ctaLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = 4.0
    }
}