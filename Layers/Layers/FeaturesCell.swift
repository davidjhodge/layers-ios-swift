//
//  FeaturesCell.swift
//  Layers
//
//  Created by David Hodge on 4/12/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit
import HMSegmentedControl

protocol SegmentedControlDelegate
{
    func segmentedControlValueChanged(index: Int)
}

class FeaturesCell: UITableViewCell
{
    @IBOutlet weak var segmentedControlContainer: UIView!
    
    @IBOutlet weak var textView: UITextView!
    
    var segmentedControl: HMSegmentedControl?
    
    var segmentedControlDelegate: SegmentedControlDelegate?
    
    override func awakeFromNib() {
        
        layoutSegmentedControl(true)
        
        textView.font = Font.OxygenRegular(size: 14.0)
    }
    
    override func layoutSubviews() {
         super.layoutSubviews()

        layoutSegmentedControl(false)
    }
    
    func layoutSegmentedControl(shouldRedraw:Bool)
    {
        if shouldRedraw
        {
            // Add new
            segmentedControl = HMSegmentedControl(sectionTitles: ["Description".uppercaseString, "Features".uppercaseString])
            
            if let segmentControl = segmentedControl
            {
                segmentControl.frame = segmentedControlContainer.frame

                segmentControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), forControlEvents: .ValueChanged)
                
                segmentControl.titleTextAttributes = [NSFontAttributeName: Font.OxygenRegular(size: 16.0)]
                
                segmentControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe
                
                segmentControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown
                
                segmentControl.selectionIndicatorColor = Color.DarkNavyColor
                
                segmentControl.userDraggable = false
                
                segmentControl.shouldAnimateUserSelection = true
                
                segmentedControlContainer.addSubview(segmentControl)
            }
        }
        
        if let segmentControl = segmentedControl
        {
            if (segmentedControlContainer != nil)
            {
                segmentControl.frame = segmentedControlContainer.frame
                segmentControl.sizeToFit()
                segmentControl.layoutIfNeeded()
            }
        }
    }
    
//    func layoutSegmentedControl(shouldRedraw:Bool)
//    {
//        if shouldRedraw
//        {
//            // Remove all
//            for view in segmentedControlContainer.subviews
//            {
//                view.removeFromSuperview()
//            }
//            
//            // Add new
//            
//            segmentedControl.frame = segmentedControlContainer.bounds
//            segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), forControlEvents: .ValueChanged)
//            
//            
//            segmentedControlContainer.addSubview(segmentedControl)
//        }
//    }
    
    func segmentedControlValueChanged(index: Int)
    {
        segmentedControlDelegate?.segmentedControlValueChanged(index)
    }
    
    
}