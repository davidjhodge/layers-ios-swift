//
//  BasicCollectionCell.swift
//  Layers
//
//  Created by David Hodge on 9/10/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit

class BasicCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = 4.0
    }
}
