//
//  DiscoverPopupView.swift
//  Layers
//
//  Created by David Hodge on 8/13/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation

class DiscoverPopupView: UIView
{
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var firstSubLabel: UILabel!
    
    @IBOutlet weak var secondSubLabel: UILabel!
    
    @IBOutlet weak var ctaButton: UIButton!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = 4.0
        
        headerLabel.textColor = Color.DarkTextColor
        
        firstSubLabel.textColor = Color.darkGray
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 4
        paragraphStyle.alignment = .center
        
        secondSubLabel.attributedText = NSAttributedString(string: "On this screen, we only" + "\n" + "show you new items that you" + "\n" + "haven't viewed before.", attributes: [NSForegroundColorAttributeName: Color.darkGray,
            NSFontAttributeName: Font.OxygenRegular(size: 16.0),
            NSParagraphStyleAttributeName: paragraphStyle])
        
        ctaButton.setBackgroundColor(Color.NeonBlueColor, forState: .normal)
        ctaButton.setBackgroundColor(Color.NeonBlueHighlightedColor, forState: .highlighted)
    }
}
