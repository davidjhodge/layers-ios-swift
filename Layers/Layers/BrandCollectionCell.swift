//
//  BrandCollectionCell.swift
//  Layers
//
//  Created by David Hodge on 4/23/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

class BrandCollectionCell: UICollectionViewCell
{
    @IBOutlet weak var brandLabel: UILabel!
 
    @IBOutlet weak var logoImageView: UIImageView!
    
    func setDefault()
    {
        backgroundColor = Color.whiteColor()
        
        brandLabel.textColor = Color.DarkNavyColor
    }
    
    func setHighlighted()
    {
        backgroundColor = Color.DarkNavyColor
        
        brandLabel.textColor = Color.whiteColor()
    }
}