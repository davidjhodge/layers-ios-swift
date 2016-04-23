//
//  LRSessionManager.swift
//  Layers
//
//  Created by David Hodge on 4/9/16.
//  Copyright © 2016 Layers. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import ObjectMapper
import KeychainAccess

let kLRAPIBase = "http://52.22.85.12:8000/"
let kAccessToken = "kAccessToken"
let kCurrentUser = "kCurrentUser"

typealias LRCompletionBlock = ((success: Bool, error: String?, response:JSON?) -> Void)

class LRSessionManager
{
    // Static variable to handle all networking and caching activities
    static let sharedManager: LRSessionManager = LRSessionManager()
    
    // Intialized in the init method and is never deallocated. It is assumed to always exist
    var networkManager: Manager!
    
    // Background queue to handle API responses
    private let backgroundQueue: dispatch_queue_t = dispatch_queue_create("Session Background", DISPATCH_QUEUE_CONCURRENT)
    
    // Access the Keychain
    private let keychain: Keychain = Keychain(service: "Layers")
    
    var currentUser: User?
    
    var accessToken: String?
    var secretToken: String?
    
    // MARK: Initialization
    init ()
    {
        //Log debugging
        log.debug("Initializing Session")
        
        //initialize alamofire network manager
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPMaximumConnectionsPerHost = 10
        configuration.timeoutIntervalForRequest = 30
        
        networkManager = Alamofire.Manager(configuration: configuration)
        
        // Restore session credentials
        restoreCredentials()
    }
    
    //MARK: Managing Account Credentials
    
    /**
     Restores the current session credentials from keychain.
    */
    private func restoreCredentials()
    {
        log.debug("Attempting to restore session.")
        
        if let token = keychain[kAccessToken], userJson = keychain[kCurrentUser]
        {
            currentUser = Mapper<User>().map(userJson)
            accessToken = token
            
            log.debug("Successfully restored session.")
        }
        else
        {
            log.warning("Failed to restore session.")
            
            clearCredentials()
        }
    }
    
    /**
    Saves the current session credentials to keychain.
    */
    private func saveCredentials()
    {
        if let userToken = accessToken, user = currentUser
        {
            log.debug("Saving session")
            
            keychain[kAccessToken] = userToken
            keychain[kCurrentUser] = Mapper().toJSONString(user, prettyPrint: false)
        }
        else
        {
            log.error("Invalid Credentials. Session Cleared")
            
            keychain[kAccessToken] = nil
            keychain[kCurrentUser] = nil
        }
    }
    
    private func clearCredentials()
    {
        accessToken = nil
        
        currentUser = nil
        
        saveCredentials()
    }
    
    func logout()
    {
        clearCredentials()
    }
    
    func isLoggedIn() -> Bool
    {
        if accessToken != nil && currentUser != nil
        {
            return true
        }
        else
        {
            accessToken = nil
            currentUser = nil
            
            log.debug("User is not logged in.")
        }
        
        return false
    }
    
    // MARK: API Access
    
    /**
     *  Register a new user.
     */
    func register(email: String, password: String, firstName: String, lastName: String, gender: String, age: Int, completion: LRCompletionBlock?)
    {
        // Error check each param
        if email.characters.count == 0 || password.characters.count == 0
        {
            if let completionHandler = completion
            {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    completionHandler(success: false, error: "INCOMPLETE_FIELDS".localized, response: nil)
                })
            }
            
            return
        }
        
        //Send API
        let postBody = ["email":        email,
                        "password":     password,
                        "first_name":   firstName,
                        "last_name":    lastName,
                        "gender":       gender,
                        "age":          age]
        
        sendAPIRequest(jsonRequest(APIUrlAtEndpoint("user/register"), HTTPMethod: "POST", json: postBody), authorization: false, completion: { (success, error, response) -> Void in
            
            if success
            {
                if let userJson = response?["user"]
                {
                    self.currentUser = Mapper<User>().map(userJson.dictionaryObject)
                    
                    self.accessToken = response?["token"].string
                    
                    self.saveCredentials()
                    
                    //Success
                    if let completionHandler = completion
                    {
                        completionHandler(success: false, error: "NETWORK_ERROR_UNKNOWN".localized, response: nil)
                    }
                    
                }
                else
                {
                    self.clearCredentials()
                    
                    if let completionHandler = completion
                    {
                        completionHandler(success: false, error: "NETWORK_ERROR_UNKNOWN".localized, response: nil)
                    }
                }
            }
            else
            {
                self.clearCredentials()
                
                if let completionHandler = completion
                {
                    completionHandler(success: false, error: error, response: nil)
                }
            }
            
        })
    }
    
    // MARK: API Helpers
    func APIUrlAtEndpoint(endpointPath: String?) -> NSURL
    {
        if let path = endpointPath
        {
            return NSURL(string: kLRAPIBase.stringByAppendingString(path))!
        }
        
        return NSURL()
    }
    
    /**
    Create a JSON Request with HTTP Method and Body
    */
    private func jsonRequest(url: NSURL, HTTPMethod: String, json: AnyObject) -> NSMutableURLRequest
    {
        let jsonObject = JSON(json)
        
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = HTTPMethod
        
        let options = NSJSONWritingOptions(rawValue: 0)
        
        do {
            try request.HTTPBody = jsonObject.rawData(options: options)
        } catch {
            log.verbose("Failed to assign HTTP Post Body to request.")
        }
        
        return request
    }
    
    /**
    Sends a generic request to the API and either returns the desired result or handles errors dispatched from the server.
 
    This function calls the completion block on the method it was called on. You are responsible for calling completion blocks on the main thread.
    */
    private func sendAPIRequest(request: NSURLRequest, authorization: Bool, completion: LRCompletionBlock?)
    {
        let startTime = NSDate().timeIntervalSince1970
        
        if let networkRequest = request.mutableCopy() as? NSMutableURLRequest
        {
            if authorization && (accessToken != nil)
            {
                networkRequest.setValue(accessToken, forHTTPHeaderField: "Authorization")
            }
            
            networkRequest.setValue("close", forHTTPHeaderField: "Connection")
            
            networkManager.request(networkRequest)
                .validate(contentType: ["application/json"]).responseString(encoding: NSUTF8StringEncoding) { (responseInfo: Response<String, NSError>) -> Void in
                    
                    //Process responses in a queue
                    dispatch_async(self.backgroundQueue, { () -> Void in
                        
                        let requestUrlString = request.URL?.absoluteString
                        let requestTimestamp = NSDate().timeIntervalSince1970 - startTime
                        
                        log.verbose("Request: \(requestUrlString!) returned in: \(requestTimestamp)")
                        
                        //Extract data from response string
                        if let data = responseInfo.result.value?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
                        {
                            var jsonError: NSError?
                            var jsonObject = JSON(data: data, options: .AllowFragments, error: &jsonError)
                            
                            // Handle JSON parsing errors
                            if let jsonParsingError = jsonError
                            {
                                if let completionHandler = completion
                                {
                                    log.error("Networking Error: ", jsonParsingError.localizedDescription)
                                    
                                    completionHandler(success: false, error: jsonParsingError.localizedDescription, response: nil)
                                }
                                
                                return
                            }
                            
                            // Check for networking errors
                            if jsonObject["status"] == "error"
                            {
                                if let completionHandler = completion
                                {
                                    // Need to handle error
                                    completionHandler(success: false, error: "NETWORK_ERROR_UNKNOWN".localized, response: nil)
                                }
                                
                                return
                            }
                            
                            //SUCCESS
                            if let completionHandler = completion
                            {
                                completionHandler(success: true, error: nil, response: jsonObject)
                            }
                            
                        }
                        else
                        {
                            if let completionHandler = completion
                            {
                                if let errorMessage = responseInfo.result.error?.localizedDescription
                                {
                                    log.error("Networking Error: \(errorMessage)")
                                }
                                else
                                {
                                    log.error("NETWORK_ERROR_UNKNOWN".localized)
                                    completionHandler(success: false, error: "NETWORK_ERROR_UNKNOWN".localized, response: nil)
                                }
                            }
                        }
                    })
            }
        }
        else
        {
            if let completionHandler = completion
            {
                completionHandler(success: false, error: "The URL request made by the client is malformed.", response: nil)
            }
        }
    }
    
    
}