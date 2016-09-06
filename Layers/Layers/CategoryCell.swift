//
//  CategoryCell.swift
//  Layers
//
//  Created by David Hodge on 9/6/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit

class CategoryCell: UICollectionViewCell
{
    @IBOutlet weak var categoryImageView: UIImageView!
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = 4.0
    }
}
