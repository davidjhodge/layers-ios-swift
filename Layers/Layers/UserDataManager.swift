//
//  UserDataManager.swift
//  Layers
//
//  Created by David Hodge on 6/24/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import SwiftyJSON

private let kUserInfoDataset = "user_info"
private let kBrowsingHistoryDataset = "browsing_history"

private let kProductViews = "product_views"
private let kProductClicks = "product_clicks"
private let kSizeSelections = "sizes"

class UserDataManager
{
    static let defaultManager = UserDataManager()
    
    private func saveData(data: NSData?, key: String?, dataset: String?, completionHandler: LRCompletionBlock?)
    {
        if let data = data,
            let key = key,
            let dataset = dataset
        {
            AWSManager.defaultManager.syncCognitoData(data, forKey: key, dataset: dataset, completionHandler: { (success, error, response) -> Void in
                
                if let completion = completionHandler
                {
                    completion(success: success, error: error, response: response)
                }
            })
        }
        else
        {
            if let completion = completionHandler
            {
                completion(success: false, error: "UserDataManager: Invalid Data", response: nil)
            }
        }
    }
    
    func viewedProduct(productId: NSNumber?, variantId: String?, completionHandler: LRCompletionBlock?)
    {
        if let productId = productId,
        let variantId = variantId
        {
            let array = [["product_id": productId,
                "variant_id": variantId]]
            
            if let data = dataFromArray(array)
            {
                saveData(data, key: kProductViews, dataset: kBrowsingHistoryDataset, completionHandler: { (success, error, response) -> Void in
                    
                    if let completion = completionHandler
                    {
                        completion(success: success, error: error, response: response)
                        
                        return
                    }
                })
            }
        }
        
        // If failure at any point
        if let completion = completionHandler
        {
            completion(success: false, error: "Logging Product View Failed", response: nil)
        }
    }
    
    func selectedSize(sizeId: String?, productId: NSNumber?, completionHandler: LRCompletionBlock?)
    {
        if let sizeId = sizeId,
        let productId = productId
        {
            let array = [["size_id": sizeId,
                "product_id": productId]]
            
            if let data = dataFromArray(array)
            {
                saveData(data, key: kSizeSelections, dataset: kBrowsingHistoryDataset, completionHandler: { (success, error, response) -> Void in
                    
                    if let completion = completionHandler
                    {
                        completion(success: success, error: error, response: response)
                        
                        return
                    }
                })
            }
        }
    }
    
    private func dataFromArray(array: Array<AnyObject>) -> NSData?
    {
        do
        {
            return try JSON(array).rawData(options: .PrettyPrinted)
        }
        catch
        {
            log.error("Error Serializing JSON")
        }
        
        return nil
    }
    
}