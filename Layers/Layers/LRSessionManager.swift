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
import MBProgressHUD
import KeychainAccess

import FBSDKLoginKit

let kLRAPIBase = "https://api.trylayers.com/"
//let kLRAPIBase = "http://52.22.85.12:8000/"

let kDeviceId = "kDeviceId"
let kTokenObject = "kTokenObject"

let productCollectionPageSize = 12

typealias LRCompletionBlock = ((success: Bool, error: String?, response:AnyObject?) -> Void)
typealias LRJsonCompletionBlock = ((success: Bool, error: String?, response:JSON?) -> Void)

private let kUserPoolLoginProvider = "kUserPoolLoginProvider"

private let kUserDidCompleteFirstLaunch = "kUserDidCompleteFirstLaunch"
private let kDiscoverPopupShown = "kDiscoverPopupShown"

class LRSessionManager: NSObject
{
    // Static variable to handle all networking and caching activities
    static let sharedManager: LRSessionManager = LRSessionManager()
    
    // Access the Keychain
    private let keychain: Keychain = Keychain(service: NSBundle.mainBundle().bundleIdentifier!)
    
    // Intialized in the init method and is never deallocated. It is assumed to always exist
    var networkManager: Manager!
    
    // Background queue to handle API responses
    private let backgroundQueue: dispatch_queue_t = dispatch_queue_create("Session Background", DISPATCH_QUEUE_CONCURRENT)
    
    var deviceKey: String?
    
    var tokenObject: DeviceTokenResponse?
    
    var isShowingAlert = false
    
    // MARK: Initialization
    override init ()
    {
        super.init()
        
        //Log debugging
        log.debug("Initializing Session")
        
        //initialize alamofire network manager
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPMaximumConnectionsPerHost = 10
        configuration.timeoutIntervalForRequest = 30
        
        networkManager = Alamofire.Manager(configuration: configuration)
        
        resumeSession()
    }
    
    // MARK: First Launch
    func completeFirstLaunch()
    {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: kUserDidCompleteFirstLaunch)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func hasCompletedFirstLaunch() -> Bool
    {
        return NSUserDefaults.standardUserDefaults().boolForKey(kUserDidCompleteFirstLaunch)
    }
    
    // MARK: Discover Popup
    func completeDiscoverPopupExperience()
    {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: kDiscoverPopupShown)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func hasSeenDiscoverPopup() -> Bool
    {
        return NSUserDefaults.standardUserDefaults().boolForKey(kDiscoverPopupShown)
    }
    
    //MARK: Managing Account Credentials

    private func resumeSession()
    {
        restoreCredentials()
    }
    
    func isAuthenticated() -> Bool
    {
        if let authorized = tokenObject?.isAnonymous
        {
            if !authorized
            {
                return true
            }
        }
        
        return false
    }
    
    func hasCredentials() -> Bool
    {
        if deviceKey != nil && keychain[kDeviceId] != nil
            && tokenObject != nil && keychain[kTokenObject] != nil
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    private func restoreCredentials()
    {
        log.debug("Restoring Session.")
        
        // Check if tokens and device id exist
        if let storedTokens = keychain[kTokenObject] where keychain[kDeviceId] != nil
        {
            if let storedTokenData = storedTokens.dataUsingEncoding(NSUTF8StringEncoding)
            {
                if let storedTokenDict = JSON(data: storedTokenData).dictionaryObject
                {
                    if let storedToken = Mapper<DeviceTokenResponse>().map(storedTokenDict),
                        let deviceKey = keychain[kDeviceId]
                    {
                        if storedToken.accessToken != nil
                        {
                            self.tokenObject = storedToken
                            
                            self.deviceKey = deviceKey
                            
                            log.debug("Tokens successfully retreived. Session Restored.")
                            
                            return
                        }
                    }
                }
            }
        }
       
        // If failure, clear cache
        log.debug("Failed to restore session.")
            
        clearCredentials()
    }
    
    private func saveCredentials()
    {
        if let tokenObject = tokenObject,
            let deviceKey = deviceKey
        {
            keychain[kTokenObject] = Mapper().toJSONString(tokenObject, prettyPrint: false)
            
            keychain[kDeviceId] = deviceKey
        }
        else
        {
            log.error("Attempted to save credentials but token object does not exist. Clearing session.")
            
            tokenObject = nil
            deviceKey = nil
            
            keychain[kTokenObject] = nil
            keychain[kDeviceId] = nil
        }
    }

    private func clearCredentials()
    {
        tokenObject = nil
        deviceKey = nil
        
        saveCredentials()
        
        // Register new unauthorized device
        self.registerDevice({ (success, error, response) -> Void in
            
            if success
            {
                if let deviceId = self.deviceKey
                {
                    log.debug("Successfully registered new device: \(deviceId)")
                }
            }
        })
    }
    
    func logout(completionHandler: LRCompletionBlock?)
    {
        logoutRemotely({ (success, error, response) -> Void in
         
            if success
            {
                self.abortSessionAndRegisterNewDevice({ (success, error, response) -> Void in
                    
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
                    completion(success: false, error: "Unable to complete logout.", response: nil)
                }
            }
        })
    }
    
    func abortSessionAndRegisterNewDevice(completionHandler: LRCompletionBlock?)
    {
        self.clearCredentials()
        
        self.registerDevice({ (success, error, response) -> Void in
            
            if success
            {
                if let deviceId = self.deviceKey
                {
                    log.debug("Successfully registered new device: \(deviceId)")
                    
                    if let completion = completionHandler
                    {
                        completion(success: true, error: nil, response: response)
                    }
                }
            }
            else
            {
                log.error("Failed to register new device.")
                
                if let completion = completionHandler
                {
                    completion(success: false, error: error, response: nil)
                }
            }
        })
    }
    
    func abortRequestAndLogout()
    {
        // Clear credentials
        self.clearCredentials()
        
        // Return to login screen
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            AppStateTransitioner.transitionToLoginStoryboard(true)
        })
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    // Determines if the device has registered. Note that this is not the same as creating a fully-authorized account using a login provider. This merely represents notifying the backend that this device exists is allowed to access the API.
    func deviceIsRegistered() -> Bool
    {
        if tokenObject != nil
        {
            return true
        }
        else
        {
            // tokenObject is already nil. Save to keychain to ensure persistent nil state
            saveCredentials()
            
            log.debug("Device has not been registered. Tokens cleared.")
            
            return false
        }
    }
    
    // MARK: Authorization

    func registerDevice(completionHandler: LRCompletionBlock?)
    {
        let model = UIDevice.currentDevice().model
        
        let systemVersion = UIDevice.currentDevice().systemVersion
        
        let timeZone = NSTimeZone.localTimeZone().secondsFromGMT
     
        // Create unique device id and store it in keychain
        let uuidString = NSUUID().UUIDString
        
        deviceKey = uuidString
        
//        saveDeviceToken()

        let jsonBody = ["device_id":    uuidString,
                        "device_name":  model,
                        "os_version":   systemVersion,
                        "timezone":     timeZone]
        
        sendRequest(self.jsonRequest(APIUrlAtEndpoint("device"), HTTPMethod: "POST", json: jsonBody), authorization: false, completion: { (success, error, response) -> Void in
         
            if success
            {
                if let jsonResponse = response
                {
                    if let tokenResponse = Mapper<DeviceTokenResponse>().map(jsonResponse.dictionaryObject)
                    {
                        self.tokenObject = tokenResponse
                        
                        self.saveCredentials()
                        
                        if let completion = completionHandler
                        {
                            completion(success: true, error: nil, response: tokenResponse)
                            
                            return
                        }
                    }
                }
                
                // Invalid Response
                if let completion = completionHandler
                {
                    completion(success: false, error: "Invalid token response.", response: nil)
                }
            }
            else
            {
                log.error("Failed to register new device.")

                // Clear Device Id
                self.deviceKey = nil
                
                self.saveCredentials()
                
                if let completion = completionHandler
                {
                    completion(success: false, error: error, response: nil)
                }
            }
        })
    }
    
    func registerWithEmail(email: String, password: String, firstName: String, lastName: String, gender: String, age: NSNumber, completionHandler: LRCompletionBlock?)
    {
        let jsonBody = ["email": email,
                        "password": password,
                        "first_name": firstName,
                        "last_name": lastName,
                        "gender": gender,
                        "age": age]
        
        sendRequest(self.jsonRequest(APIUrlAtEndpoint("user"), HTTPMethod: "PUT", json: jsonBody), authorization: true, completion: { (success, error, response) -> Void in
         
            if success
            {
                if let jsonResponse = response
                {
                    if let tokenResponse = Mapper<DeviceTokenResponse>().map(jsonResponse.dictionaryObject)
                    {
                        self.tokenObject = tokenResponse
                        
                        self.saveCredentials()
                        
                        if let completion = completionHandler
                        {
                            completion(success: true, error: nil, response: tokenResponse)
                            
                            return
                        }
                    }
                }
                
                // Invalid Response
                if let completion = completionHandler
                {
                    completion(success: false, error: "Invalid token response.", response: nil)
                }
            }
            else
            {
                if let completion = completionHandler
                {
                    completion(success: false, error: error, response: nil)
                }
            }
        })
    }
    
    func registerWithFacebook(email: String, firstName: String?, lastName: String?, gender: String?, age: NSNumber?, completionHandler: LRCompletionBlock?)
    {
        if let facebookToken = FBSDKAccessToken.currentAccessToken().tokenString
        {
            var jsonBody: Dictionary<String,AnyObject> = [
                "facebook_token":   facebookToken,
                "email":            email]
            
            if firstName != nil { jsonBody["first_name"] = firstName }
            
            if lastName != nil { jsonBody["last_name"] = lastName }
            
            if gender != nil { jsonBody["gender"] = gender }
            
            if age != nil { jsonBody["age"] = age }
            
            let httpBody = jsonBody
            
            sendRequest(self.jsonRequest(APIUrlAtEndpoint("user"), HTTPMethod: "PUT", json: httpBody), authorization: true, completion: { (success, error, response) -> Void in
                
                if success
                {
                    if let jsonResponse = response
                    {
                        if let tokenResponse = Mapper<DeviceTokenResponse>().map(jsonResponse.dictionaryObject)
                        {
                            self.tokenObject = tokenResponse
                            
                            self.saveCredentials()
                            
                            if let completion = completionHandler
                            {
                                completion(success: true, error: nil, response: tokenResponse)
                                
                                return
                            }
                        }
                    }
                    
                    // Invalid Response
                    if let completion = completionHandler
                    {
                        completion(success: false, error: "Invalid token response.", response: nil)
                    }
                }
                else
                {
                    if let completion = completionHandler
                    {
                        completion(success: false, error: error, response: nil)
                    }
                }
            })
        }
        else
        {
            if let completion = completionHandler
            {
                completion(success: false, error: "Invalid Facebook Token.", response: nil)
            }
        }
    }
    
    func loginWithEmail(email: String, password: String, completionHandler: LRCompletionBlock?)
    {
        if let deviceId = deviceKey
        {
            let jsonBody = ["email": email,
                            "password": password,
                            "device_id": deviceId]
            
            sendRequest(self.jsonRequest(APIUrlAtEndpoint("user/session"), HTTPMethod: "POST", json: jsonBody), authorization: false, completion: { (success, error, response) -> Void in
                
                if success
                {
                    if let jsonResponse = response
                    {
                        if let tokenResponse = Mapper<DeviceTokenResponse>().map(jsonResponse.dictionaryObject)
                        {
                            log.debug("User logged in with email.")
                            
                            self.tokenObject = tokenResponse
                            
                            self.saveCredentials()
                            
                            if let completion = completionHandler
                            {
                                completion(success: true, error: nil, response: tokenResponse)
                                
                                return
                            }
                        }
                    }
                    
                    // Invalid Response
                    if let completion = completionHandler
                    {
                        completion(success: false, error: "Invalid token response.", response: nil)
                    }
                }
                else
                {
                    if let completion = completionHandler
                    {
                        completion(success: false, error: error, response: nil)
                    }
                }
            })
        }
    }

    func loginWithFacebook(completionHandler: LRCompletionBlock?)
    {
        if let facebookToken = FBSDKAccessToken.currentAccessToken().tokenString,
            let deviceId = deviceKey
        {
            let jsonBody = ["facebook_token": facebookToken,
                            "device_id": deviceId]

            sendRequest(self.jsonRequest(APIUrlAtEndpoint("user/session"), HTTPMethod: "POST", json: jsonBody), authorization: false, completion: { (success, error, response) -> Void in
                
                if success
                {
                    if let jsonResponse = response
                    {
                        if let tokenResponse = Mapper<DeviceTokenResponse>().map(jsonResponse.dictionaryObject)
                        {
                            log.debug("User logged in with Facebook.")
                            
                            self.tokenObject = tokenResponse
                            
                            self.saveCredentials()
                            
                            if let completion = completionHandler
                            {
                                completion(success: true, error: nil, response: tokenResponse)
                                
                                return
                            }
                        }
                    }
                    
                    // Invalid Response
                    if let completion = completionHandler
                    {
                        completion(success: false, error: "Invalid token response.", response: nil)
                    }
                }
                else
                {
                    if let completion = completionHandler
                    {
                        completion(success: false, error: error, response: nil)
                    }
                }
            })
        }
        else
        {
            if let completion = completionHandler
            {
                completion(success: false, error: "Invalid Facebook Token.", response: nil)
            }
        }
    }
    
    func refreshToken(completionHandler: LRJsonCompletionBlock?)
    {
        if let currentRefreshToken = tokenObject?.refreshToken
        {
            let jsonBody = ["refresh_token": currentRefreshToken]
            
            sendRequest(self.jsonRequest(APIUrlAtEndpoint("device/refresh"), HTTPMethod: "POST", json: jsonBody), authorization: false, completion: { (success, error, response) -> Void in
             
                if success
                {
                    if let jsonResponse = response
                    {
                        if let tokenResponse = Mapper<DeviceTokenResponse>().map(jsonResponse.dictionaryObject)
                        {
                            self.tokenObject = tokenResponse
                            
                            self.saveCredentials()
                            
                            log.debug("Successfully refreshed access token.")
                        }
                    }
                    
                    if let completion = completionHandler
                    {
                        completion(success: true, error: nil, response: response)
                    }
                }
                else
                {
                    log.error(error)
                    
                    // If refresh token is invalid, clear credential cache and return to login screen
                    self.clearCredentials()
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        AppStateTransitioner.transitionToLoginStoryboard(true)
                    })
                }
            })
        }
        else
        {
            // If refresh token is invalid, clear credential cache and return to login screen
            self.abortSessionAndRegisterNewDevice({ (success, error, response) -> Void in
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    AppStateTransitioner.transitionToLoginStoryboard(true)
                })
            })
            
            if let completion = completionHandler
            {
                completion(success: false, error: "User cannot retreive a new refresh token because the current refresh token does not exist.", response: nil)
            }
        }
    }
    
    func logoutRemotely(completionHandler: LRJsonCompletionBlock?)
    {
        sendRequest(self.jsonRequest(APIUrlAtEndpoint("device/logout"), HTTPMethod: "POST", json: []), authorization: true, completion: { (success, error, response) -> Void in
         
            if success
            {
                log.debug("User successfully logged out.")
                
                if let completion = completionHandler
                {
                    completion(success: true, error: nil, response: response)
                }
            }
            else
            {
                if let completion = completionHandler
                {
                    completion(success: false, error: nil, response: nil)
                }
            }
        })
    }
        
    func fetchFacebookUserInfo(completion: LRCompletionBlock?)
    {
        // The currentAccessToken() should be retrieved from Facebook in the View Controller that the login dialogue is shown from.
        if (FBSDKAccessToken.currentAccessToken() != nil)
        {
            // Get user information with Facebook Graph API
            let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, age_range, link, gender, locale, picture, timezone, updated_time, verified, friends, email"], HTTPMethod: "GET")
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                request.startWithCompletionHandler({(connection:FBSDKGraphRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
                    
                    if error == nil
                    {
                        if let response = Mapper<FacebookUserResponse>().map(JSON(result).dictionaryObject)
                        {
                            if let gender = response.gender
                            {
                                // If gender exists but is not male or female
                                if gender.characters.count > 0 && gender.lowercaseString != "male" && gender.lowercaseString != "female"
                                {
                                    response.gender = "other specific"
                                }
                            }
                            
                            if let completionBlock = completion
                            {
                                completionBlock(success: true, error: nil, response: response)
                            }
                        }
                    }
                    else
                    {
                        if let completionBlock = completion
                        {
                            completionBlock(success: true, error: error.localizedDescription, response: nil)
                        }
                    }
                })
            })
        }
    }
    
    // MARK: Push Notifications
    func registerForPushNotifications(deviceToken: NSData?, completionHandler: LRCompletionBlock?)
    {        
        AWSManager.defaultManager.registerWithSNS(deviceToken, completionHandler: { (success, error, response) -> Void in
            
            if success
            {
                if let endpointARN = response as? String
                {
                    self.registerDeviceEndpoint(endpointARN, completionHandler: { (success, error, response) -> Void in
                     
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
                        completion(success: false, error: "Invalid Endpoint ARN returned from SNS.", response: nil)
                    }
                }
            }
            else
            {
                if let completion = completionHandler
                {
                    completion(success: success, error: error, response: response)
                }
            }
        })
    }
    
    private func registerDeviceEndpoint(deviceEndpointARN: String, completionHandler: LRCompletionBlock?)
    {
        let jsonBody = ["sns_endpoint": deviceEndpointARN]
        
        sendRequest(self.jsonRequest(APIUrlAtEndpoint("device"), HTTPMethod: "PUT", json: jsonBody), authorization: true, completion: { (success, error, response) -> Void in
         
            if success
            {
                if let dictionaryResponse = response?.dictionaryObject
                {
                    if let completion = completionHandler
                    {
                        completion(success: success, error: error, response: dictionaryResponse)
                    }
                }
                else
                {
                    if let completion = completionHandler
                    {
                        completion(success: false, error: "SNS Registration returned invalid response.", response: nil)
                    }
                }
            }
            else
            {
                if let completion = completionHandler
                {
                    completion(success: false, error: nil, response: nil)
                }
            }
        })
    }
    
    func registerForRemoteNotificationsIfNeeded()
    {
        if !LRSessionManager.sharedManager.userHasEnabledNotifications()
        {
            // Prompt user to register for notifications
            let readAction: UIMutableUserNotificationAction = UIMutableUserNotificationAction()
            readAction.identifier = "READ_IDENTIFIER"
            readAction.title = "Read"
            readAction.activationMode = .Foreground
            readAction.destructive = false
            readAction.authenticationRequired = true
            
            let messageCategory = UIMutableUserNotificationCategory()
            messageCategory.identifier = "MESSAGE_CATEGORY"
            messageCategory.setActions([readAction], forContext: .Default)
            messageCategory.setActions([readAction], forContext: .Minimal)
            
            let categories: Set<UIUserNotificationCategory> = NSSet(object: messageCategory) as! Set<UIUserNotificationCategory>
            
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: categories)
            
            UIApplication.sharedApplication().registerForRemoteNotifications()
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        }
    }

    func userHasEnabledNotifications() -> Bool
    {
        if let grantedSettings: UIUserNotificationSettings = UIApplication.sharedApplication().currentUserNotificationSettings()
        {
            // Check if no permission have been granted
            if grantedSettings.types == [.Badge, .Sound, .Alert]
            {
                return true
            }
        }
        
        return false
    }
    
    // MARK: Fetching Server Data
    func loadDiscoverProducts(completionHandler: LRCompletionBlock?)
    {
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: APIUrlAtEndpoint("discover"))
        
        request.HTTPMethod = "GET"
        
        sendRequest(request, authorization: true, completion: { (success, error, response) -> Void in
            
            if success
            {
                if let jsonResponse = response
                {
                    var products = Mapper<SimpleProductResponse>().mapArray(jsonResponse.arrayObject)
                    
                    // Incomplete Product Patch
                    if products != nil
                    {
                        products = products?.filter({ $0.isValid() })
                    }
                    
                    if let completion = completionHandler
                    {
                        completion(success: success, error: error, response: products)
                    }
                }
            }
            else
            {
                if let completion = completionHandler
                {
                    completion(success: success, error: error, response: nil)
                }
            }
        })
    }
    
    func loadProduct(productId: NSNumber?, completionHandler: LRCompletionBlock?)
    {
        if let productId = productId
        {
            let request: NSMutableURLRequest = NSMutableURLRequest(URL: APIUrlAtEndpoint("products/\(productId.stringValue)"))
            
            request.HTTPMethod = "GET"
            
            sendRequest(request, authorization: true, completion: { (success, error, response) -> Void in
                
                if success
                {
                    if let jsonResponse = response
                    {
                        let product = Mapper<ProductResponse>().map(jsonResponse.dictionaryObject)
                        
                        if let sortedVariants = SizeSorter.sortSizes(product)
                        {
                            product?.variants = sortedVariants
                        }
                        
                        if let completion = completionHandler
                        {
                            completion(success: success, error: error, response: product)
                        }
                    }
                }
                else
                {
                    if let completion = completionHandler
                    {
                        completion(success: success, error: error, response: nil)
                    }
                }
            })
        }
        else
        {
            if let completion = completionHandler
            {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    completion(success: false, error: "NO_PRODUCT_ID".localized, response: nil)
                })
            }
            
            return
        }
    }
    
    func loadPriceHistory(productId: NSNumber?, variantId: String?, sizeId: String?, completionHandler: LRCompletionBlock?)
    {
        if let productId = productId,
            variantId = variantId,
            sizeId = sizeId
            where productId.integerValue >= 0
        {
            let request: NSMutableURLRequest = NSMutableURLRequest(URL: APIUrlAtEndpoint("products/\(productId.stringValue)/\(variantId)/\(sizeId)"))
            
            request.HTTPMethod = "GET"
            
            sendRequest(request, authorization: true, completion: { (success, error, response) -> Void in
                
                if success
                {
                    if let jsonResponse = response
                    {
                        let product = Mapper<Price>().map(jsonResponse.dictionaryObject)
                        
                        if let completion = completionHandler
                        {
                            completion(success: success, error: error, response: product)
                        }
                    }
                }
                else
                {
                    if let completion = completionHandler
                    {
                        completion(success: success, error: error, response: nil)
                    }
                }
            })
        }
        else
        {
            if let completion = completionHandler
            {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    completion(success: false, error: "NO_PRODUCT_ID".localized, response: nil)
                })
            }
            
            return
        }
    }
    
    func loadProductCollection(page: Int, completionHandler: LRCompletionBlock?)
    {
        if page >= 0
        {
            var requestString = "products?page=\(page)&per_page=\(productCollectionPageSize)"
            
            if FilterManager.defaultManager.getCurrentFilter().hasActiveFilters()
            {
                let paramsString = FilterManager.defaultManager.filterParamsAsString()
                
                requestString = requestString.stringByAppendingString("&\(paramsString)")
            }
            
            let request: NSMutableURLRequest = NSMutableURLRequest(URL: APIUrlAtEndpoint(requestString))
                        
            request.HTTPMethod = "GET"
            
            sendRequest(request, authorization: true, completion: { (success, error, response) -> Void in
                
                if success
                {
                    if let jsonResponse = response
                    {
                        var products = Mapper<SimpleProductResponse>().mapArray(jsonResponse.arrayObject)
                        
                        // Incomplete Product Patch
                        if products?.count > 0
                        {
                            products = products?.filter({ $0.isValid() })
                        }
                        
                        if let completion = completionHandler
                        {
                            completion(success: success, error: error, response: products)
                        }
                    }
                }
                else
                {
                    if let completion = completionHandler
                    {
                        completion(success: success, error: error, response: nil)
                    }
                }
            })
        }
        else
        {
            if let completion = completionHandler
            {
                completion(success: false, error: "INVALID_PARAMETERS".localized, response: nil)
            }
        }
    }
    
    func loadReviewsForProduct(productId: NSNumber, completionHandler: LRCompletionBlock?)
    {
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: APIUrlAtEndpoint("reviews/\(productId.stringValue)"))
        
        request.HTTPMethod = "GET"
        
        sendRequest(request, authorization: true, completion: { (success, error, response) -> Void in
            
            if success
            {
                if let jsonResponse = response
                {
                    let reviews = Mapper<ReviewResponse>().mapArray(jsonResponse.arrayObject)
                    
                    if let completion = completionHandler
                    {
                        completion(success: success, error: error, response: reviews)
                    }
                }
            }
            else
            {
                if let completion = completionHandler
                {
                    completion(success: success, error: error, response: nil)
                }
            }
        })
    }
    
    // MARK: Filtering
    
    func loadCategories(completionHandler: LRCompletionBlock?)
    {
        let request = NSMutableURLRequest(URL: APIUrlAtEndpoint("categories"))
        
        request.HTTPMethod = "GET"
        
        sendRequest(request, authorization: true, completion: { (success, error, response) -> Void in
            
            if success
            {
                if let jsonResponse = response
                {
                    let categories = Mapper<CategoryResponse>().mapArray(jsonResponse.arrayObject)
                    
                    let sortedCategories = categories?.sort{ $0.categoryName < $1.categoryName }
                    
                    // Empty Category Patch
                    let categoriesToRemove = [
                        "activewear",
                        "athletic",
                        "grooming",
                        "jeans",
                        "sleepwear",
                        "sweats & hoodies",
                        "underwear",
                        "watches & jewelry",
                        "wool"]
                    
                    let filteredCategories = sortedCategories?.filter({
                        
                        // Parent Categories have a parentId of 1291772459766252500
                        if $0.parentId == NSNumber(longLong: 1291772459766252500)
                        {
                            if let categoryName = $0.categoryName?.lowercaseString
                            {
                                return !categoriesToRemove.contains(categoryName)
                            }
                        }
                        
                        return true
                    })
                    
                    if let completion = completionHandler
                    {
                        completion(success: true, error: error, response: filteredCategories)
                    }
                }
            }
            else
            {
                if let completion = completionHandler
                {
                    completion(success: false, error: error, response: nil)
                }
            }
        })
    }
    
    func loadBrands(completionHandler: LRCompletionBlock?)
    {
        let request = NSMutableURLRequest(URL: APIUrlAtEndpoint("brands"))
        
        request.HTTPMethod = "GET"
        
        sendRequest(request, authorization: true, completion: { (success, error, response) -> Void in
            
            if success
            {
                if let jsonResponse = response
                {
                    let brands = Mapper<BrandResponse>().mapArray(jsonResponse.arrayObject)
                    
                    let sortedBrands = brands?.sort{ $0.brandName < $1.brandName }
                    
                    if let completion = completionHandler
                    {
                        completion(success: true, error: error, response: sortedBrands)
                    }
                }
            }
            else
            {
                if let completion = completionHandler
                {
                    completion(success: false, error: error, response: nil)
                }
            }
        })
    }
    
    func loadRetailers(completionHandler: LRCompletionBlock?)
    {
        let request = NSMutableURLRequest(URL: APIUrlAtEndpoint("retailers"))
        
        request.HTTPMethod = "GET"
        
        sendRequest(request, authorization: true, completion: { (success, error, response) -> Void in
            
            if success
            {
                if let jsonResponse = response
                {
                    let retailers = Mapper<RetailerResponse>().mapArray(jsonResponse.arrayObject)
                    
                    let sortedRetailers = retailers?.sort{ $0.retailerName < $1.retailerName }
                    
                    if let completion = completionHandler
                    {
                            completion(success: true, error: error, response: sortedRetailers)
                    }
                }
            }
            else
            {
                if let completion = completionHandler
                {
                    completion(success: false, error: error, response: nil)
                }
            }
        })
    }
    
    func loadColors(completionHandler: LRCompletionBlock?)
    {
        let request = NSMutableURLRequest(URL: APIUrlAtEndpoint("colors"))
        
        request.HTTPMethod = "GET"
        
        sendRequest(request, authorization: true, completion: { (success, error, response) -> Void in
            
            if success
            {
                if let jsonResponse = response
                {
                    let colors = Mapper<ColorResponse>().mapArray(jsonResponse.arrayObject)
                    
                    let sortedColors = colors?.sort{ $0.colorName < $1.colorName }
                    
                    if let completion = completionHandler
                    {
                        completion(success: true, error: error, response: sortedColors)
                    }
                }
            }
            else
            {
                if let completion = completionHandler
                {
                    completion(success: false, error: error, response: nil)
                }
            }
        })
    }
    
    // MARK: Search
    func search(query: String, completionHandler: LRCompletionBlock?)
    {
        if query.characters.count > 0
        {
            let pageSize = 5
            
            // Encode string to url format
            let queryString = query.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
            
            let requestString = "search?&q=\(queryString)&per_page=\(pageSize)"
            
            let request: NSMutableURLRequest = NSMutableURLRequest(URL: APIUrlAtEndpoint(requestString))
            
            request.HTTPMethod = "GET"
            
            sendRequest(request, authorization: true, completion: { (success, error, response) -> Void in
                
                if success
                {
                    if let jsonResponse = response
                    {
                        let searchResponse = Mapper<SearchResponse>().map(jsonResponse.dictionaryObject)
                        
                        var results = Array<AnyObject>()
                        
                        // Add all brands
                        if let brands = searchResponse?.brands
                        {
                            for brand in brands
                            {
                                results.append(brand)
                            }
                        }
                        
                        // Add 2 categories
                        if let categories = searchResponse?.categories
                        {
                            var index = 0
                            
                            for category in categories
                            {
                                if index > 1
                                {
                                    break
                                }
                                
                                // If not "Mens" Category, append the current category
                                if category.parentId != nil
                                {
                                    results.append(category)
                                    
                                    index += 1
                                }
                            }
                        }
                        
                        // Add all products
                        
                        if let productDicts = searchResponse?.products
                        {
                            for (_, productResponse) in productDicts
                            {
                                if let product: SearchProductResponse = productResponse
                                {
                                    results.append(product)
                                }
                            }
                        }
                        
                        if let completion = completionHandler
                        {
                            completion(success: success, error: error, response: results)
                        }
                    }
                }
                else
                {
                    if let completion = completionHandler
                    {
                        completion(success: success, error: error, response: nil)
                    }
                }
            })
        }
        else
        {
            if let completion = completionHandler
            {
                completion(success: false, error: "INVALID_PARAMETERS".localized, response: nil)
            }
        }
    }

    // MARK: Sale Alerts
    func loadSaleAlerts(completionHandler: LRCompletionBlock?)
    {
        let request = NSMutableURLRequest(URL: APIUrlAtEndpoint("watch"))
        
        request.HTTPMethod = "GET"
                
        sendRequest(request, authorization: true, completion: { (success, error, response) -> Void in
            
            if success
            {
                if let jsonResponse = response
                {                    
                    let saleAlertResponse = Mapper<SaleAlertResponse>().map(jsonResponse.dictionaryObject)
                    
                    if let completion = completionHandler
                    {
                        completion(success: true, error: error, response: saleAlertResponse)
                    }
                }
            }
            else
            {
                if let completion = completionHandler
                {
                    completion(success: false, error: error, response: nil)
                }
            }
        })
    }
    
    func createSaleAlert(productId: NSNumber?, completionHandler: LRCompletionBlock?)
    {
        if let productId = productId
        {
            sendRequest(self.jsonRequest(APIUrlAtEndpoint("watch/products/\(productId.stringValue)"), HTTPMethod: "POST", json: []), authorization: true, completion: { (success, error, response) -> Void in
                
                if success
                {
                    if let jsonResponse = response
                    {
                        if let completion = completionHandler
                        {
                            completion(success: true, error: error, response: jsonResponse.dictionaryObject)
                        }
                    }
                }
                else
                {
                    if let completion = completionHandler
                    {
                        completion(success: false, error: error, response: nil)
                    }
                }
            })
        }
        else
        {
            if let completion = completionHandler
            {
                completion(success: false, error: "INVALID_PARAMETERS".localized, response: nil)
            }
        }
    }
    
    func deleteSaleAlert(productId: NSNumber?, completionHandler: LRCompletionBlock?)
    {
        if let productId = productId
        {
            sendRequest(self.jsonRequest(APIUrlAtEndpoint("watch/products/\(productId.stringValue)"), HTTPMethod:  "DELETE", json: []), authorization: true, completion: { (success, error, response) -> Void in
                
                if success
                {
                    if let jsonResponse = response
                    {
                        if let completion = completionHandler
                        {
                            completion(success: true, error: error, response: jsonResponse.dictionaryObject)
                        }
                    }
                }
                else
                {
                    if let completion = completionHandler
                    {
                        completion(success: false, error: error, response: nil)
                    }
                }
            })
        }
        else
        {
            if let completion = completionHandler
            {
                completion(success: false, error: "INVALID_PARAMETERS".localized, response: nil)
            }
        }
    }
    
    // MARK: Contact
    func submitContactForm(email: String, content: String, completionHandler: LRJsonCompletionBlock?)
    {
        let jsonBody = ["email": email,
                        "content": content,
                        "subject": "iOS Contact Form"
        ]
        
        sendRequest(self.jsonRequest(APIUrlAtEndpoint("contact"), HTTPMethod: "POST", json: jsonBody), authorization: true, completion: { (success, error, response) -> Void in
            
            if let completion = completionHandler
            {
                completion(success: success, error: error, response: response)
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
            log.verbose("Failed to assign HTTP Body to request.")
        }
        
        return request
    }
    
    /**
    Sends a generic request to the API and either returns the desired result or handles errors dispatched from the server.
 
    This function calls the completion block on the method it was called on. You are responsible for calling completion blocks on the main thread.
    */
    private func sendRequest(request: NSURLRequest, authorization: Bool, completion: LRJsonCompletionBlock?)
    {
        if let networkRequest = request.mutableCopy() as? NSMutableURLRequest
        {
            if authorization
            {
                if let accessToken = tokenObject?.accessToken
                {
                    networkRequest.setValue(accessToken, forHTTPHeaderField: "Authorization")
                }
            }
            
            performNetworkRequest(request, networkRequest: networkRequest, completionHandler: { (success, error, response) -> Void in
                
                if let completion = completion
                {
                    completion(success: success, error: error, response: response)
                }
            })
        }
        else
        {
            if let completionHandler = completion
            {
                completionHandler(success: false, error: "The URL request made by the client is malformed.", response: nil)
            }
        }
    }
    
    func performNetworkRequest(initialRequest: NSURLRequest, networkRequest: NSMutableURLRequest, completionHandler: LRJsonCompletionBlock?)
    {
        let newRequest = networkRequest
        
        newRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        newRequest.setValue("close", forHTTPHeaderField: "Connection")
        
        let startTime = NSDate().timeIntervalSince1970
        
        networkManager.request(newRequest)
            .validate(contentType: ["application/json"])
            .responseString(encoding: NSUTF8StringEncoding) { (response: Response<String, NSError>) -> Void in
                
                //Process responses in a queue
                dispatch_async(self.backgroundQueue, { () -> Void in
                    
                    let requestUrlString = initialRequest.URL?.absoluteString
                    let requestTimestamp = NSDate().timeIntervalSince1970 - startTime
                    
                    let milliseconds = Int(round(requestTimestamp * 1000))
                    
                    var statusCode = response.response?.statusCode
                    if statusCode == nil { statusCode = 0 }
                    
                    log.verbose("Request: \(requestUrlString!) returned status of \(statusCode!) in: \(milliseconds) ms")
                    
                    if let data = response.result.value?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
                    {
                        var jsonError: NSError?
                        let jsonObject = JSON(data: data, options: .AllowFragments, error: &jsonError)
                        
                        // Check if json error exists. If so, valid data cannot be extracted, so the error must be returned.
                        if let jsonParsingError = jsonError
                        {
                            if let completion = completionHandler
                            {
                                log.error("Networking Error: ", jsonParsingError.localizedDescription)
                                
                                completion(success: false, error: jsonParsingError.localizedDescription, response: nil)
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
                                            self.sendRequest(initialRequest, authorization: true, completion: { (success, error, response) -> Void in
                                             
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
                                                completion(success: false, error: error, response: nil)
                                            }
                                        }
                                    })
                                    
                                    return
                                    
                                } else if let invalidCredentialsError = errors["Authentication Required"] as? String
                                {
                                    log.error(invalidCredentialsError)

                                    // If refresh token is invalid, clear credential cache and return to login screen
                                    self.abortRequestAndLogout()
                                    
                                    return
                                }
                                
                                // Unknown 401. Abort request and logout
                                let error401 = "401 User is not authorized."
                            
                                log.debug(error401)
                                
                                self.abortRequestAndLogout()
                                
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
                                            completion(success: false, error: errorString, response: nil)
                                            
                                            log.error(errors)
                                            
                                            return
                                        }
                                    }
                                }
                                
                                if let completion = completionHandler
                                {
                                    let errorMessage = "Unknown Server Error."
                                    
                                    completion(success: false, error: errorMessage, response: nil)
                                    
                                    log.error(errorMessage)
                                    
                                    return
                                }
                            }
                        }
                        
                        // The request succeeded and returned valid data
                        if let completion = completionHandler
                        {
                            completion(success: true, error: nil, response: jsonObject)
                        }
                    }
                    else
                    {
                        if let completion = completionHandler
                        {
                            if let errorMessage: String = response.result.error?.localizedDescription
                            {
                                log.error("Networking Error: \(errorMessage)")
                                
                                completion(success: false, error: "Whoops! \(errorMessage)", response: nil)
                            }
                            else
                            {
                                log.error("NETWORK_ERROR_UNKNOWN".localized)
                                completion(success: false, error: "NETWORK_ERROR_UNKNOWN".localized, response: nil)
                            }
                        }
                    }
                })
        }
    }
}