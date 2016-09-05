//
//  NotificationCell.swift
//  Layers
//
//  Created by David Hodge on 9/3/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit

class NotificationCell: UICollectionViewCell {
    
    @IBOutlet weak var leftImageView: UIImageView!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var rightImageView: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        leftImageView.layer.cornerRadius = leftImageView.bounds.size.width * 0.5
        
        rightImageView.layer.cornerRadius = rightImageView.bounds.size.width * 0.5

        layer.cornerRadius = 4.0
    }
}
