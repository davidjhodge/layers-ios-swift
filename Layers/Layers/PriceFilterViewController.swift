//
//  PriceFilterViewController.swift
//  Layers
//
//  Created by David Hodge on 6/11/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation

class PriceFilter
{
    var minPrice: NSNumber?
    
    var maxPrice: NSNumber?
}

protocol PriceFilterDelegate
{
    func priceFilterChanged(_ priceFilter: PriceFilter?)
}

class PriceFilterViewController: UIViewController
{
    var delegate: PriceFilterDelegate?
    
    @IBOutlet weak var upperLabel: UILabel!
    
    @IBOutlet weak var lowerLabel: UILabel!
    
    @IBOutlet weak var priceFilterButton: UIButton!
    
    var priceFilter: PriceFilter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Price".uppercased()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset".uppercased(), style: .plain, target: self, action: #selector(reset))
        
        priceFilterButton.setBackgroundColor(Color.NeonBlueColor, forState: .normal)
        priceFilterButton.setBackgroundColor(Color.NeonBlueHighlightedColor, forState: .highlighted)
        
        priceFilterButton.addTarget(self, action: #selector(selectFilter), for: .touchUpInside)
        
        if let currentFilter = priceFilter
        {
            
        }
        else
        {
            priceFilter = PriceFilter()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
    func selectFilter()
    {
        
    }
    
    func reset()
    {
    
    }
}
