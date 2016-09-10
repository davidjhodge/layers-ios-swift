//
//  AccountHeaderCell.swift
//  Layers
//
//  Created by David Hodge on 9/10/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit

class AccountHeaderCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var fullNameLabel: UILabel!
    
    @IBOutlet weak var ctaLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = 4.0
        
        profileImageView.layer.cornerRadius = profileImageView.bounds.size.width * 0.5
        profileImageView.clipsToBounds = true
    }
}
