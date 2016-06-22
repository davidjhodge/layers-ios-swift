//
//  PriceGraphCell.swift
//  Layers
//
//  Created by David Hodge on 4/12/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit

class PriceGraphCell: UITableViewCell
{
    @IBOutlet weak var createSaleAlertButton: UIButton!
        
    @IBOutlet weak var percentChangeLabel: UILabel!
    
    @IBOutlet weak var timeframeLabel: UILabel!
    
    @IBOutlet weak var oldPrice: UILabel!
    
    @IBOutlet weak var newPrice: UILabel!

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    func setPercentChange(delta: Int)
    {
       if delta > 0
       {
        percentChangeLabel.attributedText = NSAttributedString(string: "+\(String(delta))%", attributes: [NSForegroundColorAttributeName: Color.RedColor, NSFontAttributeName: Font.OxygenBold(size: 20.0)])
        }
        else if (delta == 0)
       {
        percentChangeLabel.attributedText = NSAttributedString(string: "\(String(delta))%", attributes: [NSForegroundColorAttributeName: Color.DarkTextColor, NSFontAttributeName: Font.OxygenBold(size: 20.0)])
        }
        else if delta < 0
       {
        percentChangeLabel.attributedText = NSAttributedString(string: "\(String(delta))%", attributes: [NSForegroundColorAttributeName: Color.GreenColor, NSFontAttributeName: Font.OxygenBold(size: 20.0)])
        }
    }
}