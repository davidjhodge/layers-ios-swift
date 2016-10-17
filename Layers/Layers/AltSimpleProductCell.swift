//
//  AltSimpleProductCell.swift
//  Layers
//
//  Created by David Hodge on 10/17/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit

class AltSimpleProductCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var productNameLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        
        backgroundColor = .white
        
        layer.cornerRadius = 4.0
    }
}
