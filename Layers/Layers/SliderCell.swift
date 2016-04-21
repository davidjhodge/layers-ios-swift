//
//  SliderCell.swift
//  Layers
//
//  Created by David Hodge on 4/19/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

class SliderCell: UITableViewCell
{
    @IBOutlet weak var slider: RangeSlider!
    
    @IBOutlet weak var minLabel: UILabel!
    
    @IBOutlet weak var maxLabel: UILabel!
    
    override func awakeFromNib() {
       
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        slider.minimumValue = 0
        slider.maximumValue = 100
        
        slider.lowerValue = 20
        slider.upperValue = 70
        
        slider.trackHighlightTintColor = Color.DarkNavyColor
        
    }
}