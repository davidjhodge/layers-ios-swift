//
//  SubtitleFilterCell.swift
//  Layers
//
//  Created by David Hodge on 5/11/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

class SubtitleFilterCell: UITableViewCell
{
    @IBOutlet weak var selectedCircleView: UIView!
    
    @IBOutlet weak var filterTypeLabel: UILabel!
    
    @IBOutlet weak var filterSelectionLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        selectedCircleView.layer.cornerRadius = 0.5 * selectedCircleView.bounds.size.width
    }
}