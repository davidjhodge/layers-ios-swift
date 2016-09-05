//
//  ProfileHeaderCell.swift
//  Layers
//
//  Created by David Hodge on 9/5/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit

class ProfileHeaderCell: UICollectionViewCell
{
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var fullNameLabel: UILabel!
    
    @IBOutlet weak var bio: UILabel!
    
    @IBOutlet weak var followersCountLabel: UILabel!
    
    @IBOutlet weak var followersLabel: UILabel!
    
    @IBOutlet weak var salesCountLabel: UILabel!
    
    @IBOutlet weak var salesLabel: UILabel!
    
    @IBOutlet weak var purchasesCountLabel: UILabel!
    
    @IBOutlet weak var purchasesLabel: UILabel!
    
    @IBOutlet weak var followButton: UIButton!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Profile Picture Image
        profileImageView.layer.cornerRadius = profileImageView.bounds.size.width * 0.5
        profileImageView.clipsToBounds = true
        
        // Follow Button
        followButton.layer.cornerRadius = 4.0
        followButton.clipsToBounds = true
    
        followButton.layer.borderColor = Color.PrimaryAppColor.CGColor
        followButton.layer.borderWidth = 2.0
    }
}
