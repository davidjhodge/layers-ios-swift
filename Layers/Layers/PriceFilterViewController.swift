//
//  PriceFilterViewController.swift
//  Layers
//
//  Created by David Hodge on 6/11/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import SwiftRangeSlider

class PriceFilter
{
    var minPrice: NSNumber?
    
    var maxPrice: NSNumber?
}

protocol PriceFilterDelegate
{
    func priceFilterChanged(priceFilter: PriceFilter?)
}

class PriceFilterViewController: UIViewController
{
    var delegate: PriceFilterDelegate?
    
    @IBOutlet weak var slider: RangeSlider!
    
    @IBOutlet weak var upperLabel: UILabel!
    
    @IBOutlet weak var lowerLabel: UILabel!
    
    @IBOutlet weak var priceFilterButton: UIButton!
    
    var priceFilter: PriceFilter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Price".uppercaseString
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset".uppercaseString, style: .Plain, target: self, action: #selector(reset))
        
        priceFilterButton.setBackgroundColor(Color.NeonBlueColor, forState: .Normal)
        priceFilterButton.setBackgroundColor(Color.NeonBlueHighlightedColor, forState: .Highlighted)
        
        priceFilterButton.addTarget(self, action: #selector(selectFilter), forControlEvents: .TouchUpInside)
        
        slider.trackTintColor = Color.LightGray
        slider.trackHighlightTintColor = Color.PrimaryAppColor
        slider.thumbTintColor = Color.whiteColor()
        
        slider.minimumValue = 0
        slider.maximumValue = 20
        
        slider.lowerValue = slider.minimumValue
        slider.upperValue = slider.maximumValue
        
        if let currentFilter = priceFilter
        {
            if let lowPrice = currentFilter.minPrice?.integerValue,
                let highPrice = currentFilter.maxPrice?.integerValue
            {
                var reverseDict = Dictionary<Int,Int>()
                
                for key in lookupDict().keys
                {
                    if let value = lookupDict()[key]
                    {
                        reverseDict[value] = key
                    }
                }
                
                if let lowerSliderValue = reverseDict[lowPrice],
                    let upperSliderValue = reverseDict[highPrice]
                {
                    slider.lowerValue = Double(lowerSliderValue)
                    slider.upperValue = Double(upperSliderValue)
                }
            }
        }
        else
        {
            priceFilter = PriceFilter()
        }
        
        slider.addTarget(self, action: #selector(sliderValueChanged), forControlEvents: .ValueChanged)
        
        if let lowerValue = lookupDict()[Int(slider.lowerValue)],
        let upperValue = lookupDict()[Int(slider.upperValue)]
        {
            lowerLabel.text = String(lowerValue)
            
            upperLabel.text = String(upperValue)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let delegate = delegate
        {
            if let priceFilter = priceFilter
            {
                delegate.priceFilterChanged(priceFilter)
            }
            else
            {
                delegate.priceFilterChanged(nil)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        slider.updateLayerFrames()
    }
    
    func lookupDict() -> Dictionary<Int, Int>
    {
        return [0:0,
                1:10, // Prices['20']
                2:25,
                3:50,
                4:75,
                5:100,
                6:125,
                7:150,
                8:200,
                9:250,
                10:300,
                11:350,
                12:400,
                13:500,
                14:600,
                15:700,
                16:800,
                17:900,
                18:1000,
                19:1250,
                20:1500,
                21:1750,
                22:2000,
                23:2250,
                24:2500,
                25:3000,
                26:3500,
                27:4000,
                28:4500 // Prices['47']
        ]
    }
    
    // MARK: Actions
    func sliderValueChanged()
    {
        if let lowerValue = lookupDict()[Int(slider.lowerValue)],
            let upperValue = lookupDict()[Int(slider.upperValue)]
        {
            priceFilter?.minPrice = NSNumber(integer: lowerValue)
                
            priceFilter?.maxPrice = NSNumber(integer: upperValue)
            
            lowerLabel.text = String(lowerValue)
            
            upperLabel.text = String(upperValue)
        }
    }
    
    func selectFilter()
    {
        if let lowerValue = lookupDict()[Int(slider.lowerValue)],
            let upperValue = lookupDict()[Int(slider.upperValue)]
        {
            priceFilter = PriceFilter()

            priceFilter!.minPrice = NSNumber(integer: lowerValue)
            
            priceFilter!.maxPrice = NSNumber(integer: upperValue)
        }
        else
        {
            priceFilter = nil
        }
        
        navigationController?.popViewControllerAnimated(true)
    }
    
    func reset()
    {
        priceFilter = nil

        slider.lowerValue = 0
        slider.upperValue = Double(lookupDict().keys.count)
        
        if let lowerValue = lookupDict()[Int(slider.minimumValue)],
            let upperValue = lookupDict()[Int(slider.maximumValue)]
        {
            lowerLabel.text = String(lowerValue)
            
            upperLabel.text = String(upperValue)
        }
    }
}