//
//  UserProductCell.swift
//  Layers
//
//  Created by David Hodge on 9/5/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit

class UserProductCell: UICollectionViewCell
{
    @IBOutlet weak var productImageView: UIImageView!
    
    @IBOutlet weak var brandLabel: UILabel!
    
    @IBOutlet weak var productNameLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = 4.0
    }
}
