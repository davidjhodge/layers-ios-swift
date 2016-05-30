//
//  ColorCell.swift
//  Layers
//
//  Created by David Hodge on 5/13/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

class ColorCell: UICollectionViewCell
{
    @IBOutlet weak var colorSwatchView: UIView!
    
    @IBOutlet weak var textLabel: UILabel!
    
    @IBOutlet weak var checkmarkImageView: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        colorSwatchView.layer.cornerRadius = 8.0
    }
}