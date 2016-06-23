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
        
        priceFilterButton.addTarget(self, action: #selector(selectFilter), forControlEvents: .TouchUpInside)
        
        slider.trackTintColor = Color.LightGray
        slider.trackHighlightTintColor = Color.DarkNavyColor
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
                1:10,
                2:20,
                3:30,
                4:40,
                5:50,
                6:60,
                7:70,
                8:80,
                9:90,
                10:100,
                11:150,
                12:200,
                13:300,
                14:400,
                15:500,
                16:600,
                17:700,
                18:800,
                19:900,
                20:1000]
    }
    
    // MARK: Actions
    func sliderValueChanged()
    {
        if let lowerValue = lookupDict()[Int(slider.lowerValue)],
            let upperValue = lookupDict()[Int(slider.upperValue)]
        {
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