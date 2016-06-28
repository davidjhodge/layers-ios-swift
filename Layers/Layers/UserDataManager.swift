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
private let kUserData = "user_data"

private let kLastSyncDate = "kLastSyncDate"

class UserDataManager: NSObject
{
    static let defaultManager = UserDataManager()
    
    var tempDictionaryStore = Dictionary<String,Dictionary<String,AnyObject>>()
    
    var lastSyncDate: NSDate?
    
    override init()
    {
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(syncImmediately), name: UIApplicationWillResignActiveNotification, object: nil)
    }
    
    func syncIfNeeded()
    {
        let lastSyncTimestamp = NSUserDefaults.standardUserDefaults().doubleForKey(kLastSyncDate)
        
        if lastSyncTimestamp != 0
        {
            lastSyncDate = NSDate(timeIntervalSince1970: lastSyncTimestamp)
        }
        
        // Sync data if it has been at least one day since the last sync
        if lastSyncDate == nil || lastSyncDate?.timeIntervalSinceNow > 24*3600
        {
            let temporaryStoreData = dataFromDictionary(tempDictionaryStore)
            
            syncData(temporaryStoreData, completionHandler: { (success, error, response) -> Void in
                
                if success
                {
                    NSUserDefaults.standardUserDefaults().setDouble(NSDate().timeIntervalSince1970, forKey: kLastSyncDate)
                    NSUserDefaults.standardUserDefaults().synchronize()
                }
                else
                {
                    log.error(error)
                }
            })
        }
    }
    
    func syncImmediately(completionHandler: LRCompletionBlock?)
    {
        let temporaryStoreData = dataFromDictionary(tempDictionaryStore)
        
        syncData(temporaryStoreData, completionHandler: { (success, error, response) -> Void in
            
            if success
            {
                NSUserDefaults.standardUserDefaults().setDouble(NSDate().timeIntervalSince1970, forKey: kLastSyncDate)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
            else
            {
                log.error(error)
            }
            
            if let completion = completionHandler
            {
                completion(success: success, error: error, response: response)
            }
        })
    }
    
    private func syncData(data: NSData?, completionHandler: LRCompletionBlock?)
    {
        if let data = data
        {
            AWSManager.defaultManager.syncCognitoData(data, completionHandler: { (success, error, response) -> Void in
                
                if success
                {
                    self.lastSyncDate = NSDate()
                }
                
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
    
    private func storeInfo(info: AnyObject?, key: String?, dataset: String?, completionHandler: LRCompletionBlock?)
    {
        if let array = info as? Array<Dictionary<String,AnyObject>>,
            let dictKey: String = key,
            let datasetName: String = dataset
        {
            // Create dataset dict if one does not exist
            if tempDictionaryStore[datasetName] == nil
            {
                tempDictionaryStore[datasetName] = Dictionary<String,Dictionary<String,AnyObject>>()
            }
            
            if var datasetValue: Dictionary<String,AnyObject> = tempDictionaryStore[datasetName]
            {
                // Create dictionary for key if one does not already exist
                if datasetValue[dictKey] == nil
                {
                    datasetValue[dictKey] = Array<Dictionary<String,AnyObject>>()
                }
                
                if let keyValueArray = datasetValue[dictKey] as? Array<Dictionary<String,AnyObject>>
                {
                    if let productArray: Array<Dictionary<String,AnyObject>> = array
                    {
                        var newArray = keyValueArray
                        newArray.appendContentsOf(productArray)
                        
                        tempDictionaryStore[datasetName]?[dictKey] = newArray
                        
                        printTemporaryStore()
                        
                        if let completion = completionHandler
                        {
                            completion(success: true, error: nil, response: tempDictionaryStore)
                            
                            return
                        }
                    }
                }
            }

            // Error
            if let completion = completionHandler
            {
                completion(success: false, error: "Error writing to temporary data store.", response: nil)
            }
        }
        else
        {
            if let completion = completionHandler
            {
                completion(success: false, error: "User Data Manager: Invalid Data", response: nil)
                
                return
            }
        }
    }
    
    func resetLocalStorage()
    {
        tempDictionaryStore = Dictionary<String,Dictionary<String,AnyObject>>()
    }
    
    func printTemporaryStore()
    {
        if let stringRepresentation = JSON(tempDictionaryStore).rawString()
        {
            print(stringRepresentation)
        }
    }
    
    func facebookLogin(firstName: String?, lastName: String?, gender: String?, predictedAge: NSNumber?, email: String?, completionHandler: LRCompletionBlock?)
    {
        // Set default values if variables are nil
        var firstName = firstName
        var lastName = lastName
        var gender = gender
        var predictedAge = predictedAge
        var email = email
        
        if firstName == nil { firstName = "" }
        if lastName == nil { lastName = "" }
        if gender == nil { gender = "" }
        if predictedAge == nil { predictedAge = 0}
        if email == nil { email = "" }
        
        if let firstName = firstName,
            let lastName = lastName,
            let gender = gender,
            let predictedAge = predictedAge,
            let email = email
        {
            let array = [
                ["first_name":  firstName,
                "last_name":    lastName,
                "gender":       gender,
                "predicted_age":predictedAge,
                "email":        email]
            ]
            
            storeInfo(array, key: kUserData, dataset: kUserInfoDataset, completionHandler: { (success, error, response) -> Void in
                
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
                completion(success: false, error: "Viewed Product Invalid Parameters.", response: nil)
            }
        }
    }

    func viewedProduct(productId: NSNumber?, variantId: String?, completionHandler: LRCompletionBlock?)
    {
        if let productId = productId,
        let variantId = variantId
        {
            let array = [["product_id": productId,
                "variant_id": variantId,
                "created_at": NSDate().timeIntervalSince1970]]
            
                storeInfo(array, key: kProductViews, dataset: kBrowsingHistoryDataset, completionHandler: { (success, error, response) -> Void in
                    
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
                completion(success: false, error: "Viewed Product Invalid Parameters.", response: nil)
            }
        }
    }
    
    func selectedSize(sizeId: String?, productId: NSNumber?, completionHandler: LRCompletionBlock?)
    {
        if let sizeId = sizeId,
        let productId = productId
        {
            let array = [["size_id": sizeId,
                "product_id": productId,
                "created_at": NSDate().timeIntervalSince1970]]
            
                storeInfo(array, key: kSizeSelections, dataset: kBrowsingHistoryDataset, completionHandler: { (success, error, response) -> Void in
                    
                    if let completion = completionHandler
                    {
                        completion(success: success, error: error, response: response)
                        
                        return
                    }
                })
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
    
    private func dataFromDictionary(dictionary: Dictionary<String,AnyObject>) -> NSData?
    {
        do
        {
            return try JSON(dictionary).rawData(options: .PrettyPrinted)
        }
        catch
        {
            log.error("Error Serializing JSON")
        }
        
        return nil
    }
    
}