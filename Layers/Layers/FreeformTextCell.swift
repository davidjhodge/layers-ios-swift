//
//  FreeformTextCell.swift
//  Layers
//
//  Created by David Hodge on 9/5/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit

class FreeformTextCell: UITableViewCell {

    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var bodyTextLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = 4.0
    }
}
