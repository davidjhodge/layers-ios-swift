//
//  StyleCell.swift
//  Layers
//
//  Created by David Hodge on 4/12/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

class StyleCell: UITableViewCell
{
    @IBOutlet weak var styleLabel: UILabel!
    
    @IBOutlet weak var colorSwatchView: UIView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        colorSwatchView.layer.cornerRadius = colorSwatchView.bounds.size.width * 0.5
    }
}