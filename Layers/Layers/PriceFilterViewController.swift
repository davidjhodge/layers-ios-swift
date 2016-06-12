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
    
    @IBOutlet weak var checkmarkView: UIImageView!
    
    var priceFilter: PriceFilter?
    
    var allPricesSelected: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Price".uppercaseString
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Select".uppercaseString, style: .Plain, target: self, action: #selector(selectFilter))
        
        slider.trackTintColor = Color.LightGray
        slider.trackHighlightTintColor = Color.DarkNavyColor
        slider.thumbTintColor = Color.whiteColor()
        
        slider.minimumValue = 0
        slider.maximumValue = Double(lookupDict().keys.count)
        
        slider.lowerValue = 3
        slider.upperValue = 10
        
        slider.addTarget(self, action: #selector(sliderValueChanged), forControlEvents: .ValueChanged)
        
        if let lowerValue = lookupDict()[Int(slider.lowerValue)],
        let upperValue = lookupDict()[Int(slider.upperValue)]
        {
            lowerLabel.text = String(lowerValue)
            
            upperLabel.text = String(upperValue)
        }
        
        priceFilterButton.addTarget(self, action: #selector(selectAllPrices), forControlEvents: .TouchUpInside)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let priceFilter = priceFilter
        {
            if let delegate = delegate
            {
                if allPricesSelected
                {
                    delegate.priceFilterChanged(nil)
                }
                else
                {
                    delegate.priceFilterChanged(priceFilter)
                }
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
        
        if allPricesSelected
        {
            deselectAllPrices()
        }
    }
    
    func selectAllPrices()
    {
        if !allPricesSelected
        {
            checkmarkView.hidden = false
            
            allPricesSelected = true
        }
        else
        {
            deselectAllPrices()
        }
    }
    
    func deselectAllPrices()
    {
        checkmarkView.hidden = true
        
        allPricesSelected = false
    }
    
    func selectFilter()
    {
        priceFilter = PriceFilter()
        
        if let lowerValue = lookupDict()[Int(slider.lowerValue)],
            let upperValue = lookupDict()[Int(slider.upperValue)]
        {
            priceFilter!.minPrice = NSNumber(integer: lowerValue)
            
            priceFilter!.maxPrice = NSNumber(integer: upperValue)
            
            navigationController?.popViewControllerAnimated(true)
        }
    }
}