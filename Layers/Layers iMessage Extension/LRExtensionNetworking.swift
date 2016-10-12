//
//  LRExtensionNetworking.swift
//  Layers
//
//  Created by David Hodge on 10/12/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import UIKit
import ObjectMapper
import Alamofire
import SwiftyBeaver
import SwiftyJSON

private let log = SwiftyBeaver.self

class LRExtensionNetworking: NSObject {
    
    // Static variable to handle all networking and caching activities
    static let sharedManager: LRExtensionNetworking = LRExtensionNetworking()
    
    // Intialized in the init method and is never deallocated. It is assumed to always exist
    var networkManager: SessionManager!
    
    // Background queue to handle API responses
    fileprivate let backgroundQueue: DispatchQueue = DispatchQueue(label: "Extension Background", attributes: DispatchQueue.Attributes.concurrent)
    
    var tokenObject: DeviceTokenResponse?

    override init()
    {
        //Log debugging
        log.debug("Initializing Extension Session")
        
        //initialize alamofire network manager
        let configuration = URLSessionConfiguration.default
        configuration.httpMaximumConnectionsPerHost = 10
        configuration.timeoutIntervalForRequest = 30
        
        networkManager = SessionManager(configuration: configuration)
    }
    
    func loadProduct(_ productId: NSNumber?, completionHandler: LRCompletionBlock?)
    {
        if let productId = productId
        {
            var request = URLRequest(url: APIUrlAtEndpoint("products/\(productId.stringValue)"))
            
            request.httpMethod = "GET"
            
            sendRequest(request, authorization: true, completion: { (success, error, response) -> Void in
                
                if success
                {
                    if let jsonResponse = response?.arrayObject?[safe: 0] as? [String:Any]
                    {
                        if let product = Mapper<Product>().map(JSON: jsonResponse)
                        {
                            if let completion = completionHandler
                            {
                                completion(success, error, product)
                            }
                        }
                        else
                        {
                            if let completion = completionHandler
                            {
                                completion(success, "loadProduct JSON Parsing Error.", nil)
                            }
                        }
                    }
                }
                else
                {
                    if let completion = completionHandler
                    {
                        completion(success, error, nil)
                    }
                }
            })
        }
        else
        {
            if let completion = completionHandler
            {
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    completion(false, "NO_PRODUCT_ID".localized, nil)
                })
            }
            
            return
        }
    }
    
    /**
     Create a JSON Request with HTTP Method and Body
     */
    fileprivate func jsonRequest(_ url: URL, httpMethod: String, json: [String:Any]) -> URLRequest
    {
        let jsonObject = JSON(json)
        
        var request = URLRequest(url: url)
        
        request.httpMethod = httpMethod
        
        let options = JSONSerialization.WritingOptions(rawValue: 0)
        
        do {
            try request.httpBody = jsonObject.rawData(options: options)
        } catch {
            log.verbose("Failed to assign HTTP Body to request.")
        }
        
        return request
    }
    
    func refreshToken(_ completionHandler: LRJsonCompletionBlock?)
    {
        if let currentRefreshToken = tokenObject?.refreshToken
        {
            let jsonBody = ["refresh_token": currentRefreshToken]
            
            sendRequest(self.jsonRequest(APIUrlAtEndpoint("device/refresh"), httpMethod: "POST", json: jsonBody), authorization: false, completion: { (success, error, response) -> Void in
                
                if success
                {
                    if let jsonDict = response?.dictionaryObject
                    {
                        if let tokenResponse = Mapper<DeviceTokenResponse>().map(JSON: jsonDict)
                        {
                            self.tokenObject = tokenResponse
                            
                            log.debug("Successfully refreshed access token.")
                        }
                    }
                    
                    if let completion = completionHandler
                    {
                        completion(true, nil, response)
                    }
                }
                else
                {
                    log.error(error)
                }
            })
        }
        else
        {
            if let completion = completionHandler
            {
                completion(false, "User cannot retreive a new refresh token because the current refresh token does not exist.", nil)
            }
        }
    }
    
    /**
     Sends a generic request to the API and either returns the desired result or handles errors dispatched from the server.
     
     This function calls the completion block on the method it was called on. You are responsible for calling completion blocks on the main thread.
     */
    fileprivate func sendRequest(_ request: URLRequest?, authorization: Bool, completion: LRJsonCompletionBlock?)
    {
        if var networkRequest = request
        {
            if authorization
            {
                if let accessToken = tokenObject?.accessToken
                {
                    networkRequest.setValue(accessToken, forHTTPHeaderField: "Authorization")
                }
            }
            
            performNetworkRequest(networkRequest, completionHandler: { (success, error, response) -> Void in
                
                if let completion = completion
                {
                    completion(success, error, response)
                }
            })
        }
        else
        {
            if let completionHandler = completion
            {
                completionHandler(false, "The URL request made by the client is malformed.", nil)
            }
        }
    }
    
    func performNetworkRequest(_ networkRequest: URLRequest, completionHandler: LRJsonCompletionBlock?)
    {
        var newRequest = networkRequest
        
        newRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        newRequest.setValue("close", forHTTPHeaderField: "Connection")
        
        let startTime = Date().timeIntervalSince1970
        
        networkManager.request(newRequest)
            .validate(contentType: ["application/json"])
            .responseString(encoding: String.Encoding.utf8) { (response: DataResponse<String>) -> Void in
                
                //Process responses in a queue
                self.backgroundQueue.async
                    {
                        let requestUrlString = newRequest.url?.absoluteString
                        let requestTimestamp = NSDate().timeIntervalSince1970 - startTime
                        
                        let milliseconds = Int(round(requestTimestamp * 1000))
                        
                        var statusCode = response.response?.statusCode
                        if statusCode == nil { statusCode = 0 }
                        
                        log.verbose("Request: \(requestUrlString!) returned status of \(statusCode!) in: \(milliseconds) ms")
                        
                        if let data = response.result.value?.data(using: String.Encoding.utf8, allowLossyConversion: true)
                        {
                            var jsonError: NSError?
                            let jsonObject = JSON(data: data, options: .allowFragments, error: &jsonError)
                            
                            // Check if json error exists. If so, valid data cannot be extracted, so the error must be returned.
                            if let jsonParsingError = jsonError
                            {
                                if let completion = completionHandler
                                {
                                    log.error("Networking Error: ", jsonParsingError.localizedDescription)
                                    
                                    completion(false, jsonParsingError.localizedDescription, nil)
                                }
                                
                                // A JSON error occured so the method returns after passing the error back through the completion block
                                return
                            }
                            
                            // Handle Unauthorized Error
                            if response.response?.statusCode == 401
                            {
                                if let errors = jsonObject["errors"].dictionaryObject
                                {
                                    if let expiredErrorMessage = errors["expired_authorization"] as? String
                                    {
                                        log.error(expiredErrorMessage)
                                        
                                        // Token has expired
                                        self.refreshToken({ (success, error, response) -> Void in
                                            
                                            if success
                                            {
                                                // After refreshing token, perform this request again
                                                self.sendRequest(networkRequest, authorization: true, completion: { (success, error, response) -> Void in
                                                    
                                                    if let completion = completionHandler
                                                    {
                                                        completion(success, error, response)
                                                    }
                                                })
                                            }
                                            else
                                            {
                                                if let completion = completionHandler
                                                {
                                                    completion(false, error, nil)
                                                }
                                            }
                                        })
                                        
                                        return
                                        
                                    } else if let invalidCredentialsError = errors["Authentication Required"] as? String
                                    {
                                        log.error(invalidCredentialsError)
      
                                        return
                                    }
                                    
                                    // Unknown 401. Abort request and logout
                                    let error401 = "401 User is not authorized."
                                    
                                    log.debug(error401)
                                    
                                    return
                                }
                            }
                            
                            // Check for request error
                            if let statusCode = response.response?.statusCode
                            {
                                // If status code is not in the 200s, return error
                                if statusCode < 200 || statusCode > 299
                                {
                                    if let errors = jsonObject["errors"].dictionaryObject
                                    {
                                        for (key, value) in errors
                                        {
                                            let errorString = "\(key): \(value)"
                                            
                                            if let completion = completionHandler
                                            {
                                                completion(false, errorString, nil)
                                                
                                                log.error(errors)
                                                
                                                return
                                            }
                                        }
                                    }
                                    
                                    if let completion = completionHandler
                                    {
                                        let errorMessage = "Unknown Server Error."
                                        
                                        completion(false, errorMessage, nil)
                                        
                                        log.error(errorMessage)
                                        
                                        return
                                    }
                                }
                            }
                            
                            // The request succeeded and returned valid data
                            if let completion = completionHandler
                            {
                                completion(true, nil, jsonObject)
                            }
                        }
                        else
                        {
                            if let completion = completionHandler
                            {
                                if let errorMessage: String = response.result.error?.localizedDescription
                                {
                                    log.error("Networking Error: \(errorMessage)")
                                    
                                    completion(false, "Whoops! \(errorMessage)", nil)
                                }
                                else
                                {
                                    log.error("NETWORK_ERROR_UNKNOWN".localized)
                                    completion(false, "NETWORK_ERROR_UNKNOWN".localized, nil)
                                }
                            }
                        }
                }
        }
    }

}
