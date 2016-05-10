//
//  PriceGraphCell.swift
//  Layers
//
//  Created by David Hodge on 4/12/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import UIKit
import Charts

class PriceGraphCell: UITableViewCell, ChartViewDelegate
{
    @IBOutlet weak var createSaleAlertButton: UIButton!
    
    @IBOutlet weak var chart: LineChartView!
    
    @IBOutlet weak var percentChangeLabel: UILabel!
    
    @IBOutlet weak var timeframeLabel: UILabel!
    
    @IBOutlet weak var oldPrice: UILabel!
    
    @IBOutlet weak var newPrice: UILabel!
    
    override func awakeFromNib() {
        
        setupChart()
        
        tempCreateData()
    }
    
    func setupChart()
    {
        chart.delegate = self
        
        chart.rightAxis.enabled = false
        chart.leftAxis.enabled = false
        
        chart.xAxis.drawGridLinesEnabled = false
        chart.xAxis.drawAxisLineEnabled = false
        
        chart.leftAxis.drawAxisLineEnabled = false
        chart.rightAxis.drawGridLinesEnabled = false
        
        chart.noDataTextDescription = "No data yet."
        
        chart.descriptionText = ""
        
        chart.dragEnabled = true
        
        chart.setScaleEnabled(false)
        
        chart.pinchZoomEnabled = false

        chart.legend.enabled = false
        
        let midline: ChartLimitLine = ChartLimitLine(limit: 10.0)
        midline.lineWidth = 2.0
        midline.lineColor = Color.BackgroundGrayColor
        
        let yAxis: ChartYAxis = chart.leftAxis
        
        yAxis.removeAllLimitLines()
        
        yAxis.drawLimitLinesBehindDataEnabled = true
        
        yAxis.addLimitLine(midline)

    }
    
    func reloadData()
    {
        
    }
    
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
    
    func tempCreateData()
    {
        let xVals = [1, 2, 3, 4, 5]
        
        var yValues: Array<ChartDataEntry> = Array<ChartDataEntry>()
        
        for index in 1...5
        {
            let chartEntry: ChartDataEntry = ChartDataEntry(value: Double(1+index), xIndex: index)
            yValues.append(chartEntry)
        }
        
        let prices: LineChartDataSet = LineChartDataSet(yVals: yValues, label: "")
        prices.setColor(Color.GreenColor)
        prices.drawCirclesEnabled = false
        prices.lineWidth = 3.0
        prices.drawValuesEnabled = false
        
        let dataSets = [prices]
        
        let data:LineChartData = LineChartData(xVals: xVals, dataSets: dataSets)
        
        chart.data = data
    }
    
    // MARK: Custom Delegate
    func animateChart()
    {
        chart.animate(xAxisDuration: 2.5, easingOption: .EaseInOutQuart)
    }
    
    // MARK: Charts
    func chartValueSelected(chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: ChartHighlight) {
        print(entry.value)
    }
}