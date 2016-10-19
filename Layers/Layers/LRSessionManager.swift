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

//let kLRAPIBase = "https://api.trylayers.com/"
let kLRAPIBase = "http://52.24.175.141:8000/"

let kDeviceId = "kDeviceId"
let kTokenObject = "kTokenObject"

let productCollectionPageSize = 12

typealias LRCompletionBlock = ((_ success: Bool, _ error: String?, _ response:Any?) -> Void)
typealias LRJsonCompletionBlock = ((_ success: Bool, _ error: String?, _ response:JSON?) -> Void)

private let kUserPoolLoginProvider = "kUserPoolLoginProvider"

private let kUserDidCompleteFirstLaunch = "kUserDidCompleteFirstLaunch"
private let kDiscoverPopupShown = "kDiscoverPopupShown"

class LRSessionManager: NSObject
{
    // Static variable to handle all networking and caching activities
    static let sharedManager: LRSessionManager = LRSessionManager()
    
    // Access the Keychain
    fileprivate let keychain: Keychain = Keychain(service: Bundle.main.bundleIdentifier!)
    
    // Intialized in the init method and is never deallocated. It is assumed to always exist
    var networkManager: SessionManager!
    
    // Background queue to handle API responses
    fileprivate let backgroundQueue: DispatchQueue = DispatchQueue(label: "Session Background", attributes: DispatchQueue.Attributes.concurrent)
    
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
        let configuration = URLSessionConfiguration.default
        configuration.httpMaximumConnectionsPerHost = 10
        configuration.timeoutIntervalForRequest = 30
        
        networkManager = SessionManager(configuration: configuration)
        
        resumeSession()
    }
    
    // MARK: First Launch
    func completeFirstLaunch()
    {
        UserDefaults.standard.set(true, forKey: kUserDidCompleteFirstLaunch)
        UserDefaults.standard.synchronize()
    }
    
    func hasCompletedFirstLaunch() -> Bool
    {
        return UserDefaults.standard.bool(forKey: kUserDidCompleteFirstLaunch)
    }
    
    // MARK: Discover Popup
    func completeDiscoverPopupExperience()
    {
        UserDefaults.standard.set(true, forKey: kDiscoverPopupShown)
        UserDefaults.standard.synchronize()
    }
    
    func hasSeenDiscoverPopup() -> Bool
    {
        return UserDefaults.standard.bool(forKey: kDiscoverPopupShown)
    }
    
    //MARK: Managing Account Credentials

    fileprivate func resumeSession()
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
    
    fileprivate func restoreCredentials()
    {
        log.debug("Restoring Session.")
        
        // Check if tokens and device id exist
        if let storedTokens = keychain[kTokenObject] , keychain[kDeviceId] != nil
        {
            if let storedTokenData = storedTokens.data(using: String.Encoding.utf8)
            {
                if let storedTokenDict = JSON(data: storedTokenData).dictionaryObject
                {
                    if let storedToken = Mapper<DeviceTokenResponse>().map(JSON: storedTokenDict),
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
    
    fileprivate func saveCredentials()
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

    fileprivate func clearCredentials()
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
    
    func logout(_ completionHandler: LRCompletionBlock?)
    {
        logoutRemotely({ (success, error, response) -> Void in
         
            if success
            {
                self.abortSessionAndRegisterNewDevice({ (success, error, response) -> Void in
                    
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
                    completion(false, "Unable to complete logout.", nil)
                }
            }
        })
    }
    
    func abortSessionAndRegisterNewDevice(_ completionHandler: LRCompletionBlock?)
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
                        completion(true, nil, response)
                    }
                }
            }
            else
            {
                log.error("Failed to register new device.")
                
                if let completion = completionHandler
                {
                    completion(false, error, nil)
                }
            }
        })
    }
    
    func abortRequestAndLogout()
    {
        // Clear credentials
        self.clearCredentials()
        
        // Return to login screen
        DispatchQueue.main.async(execute: { () -> Void in
            
            AppStateTransitioner.transitionToLoginStoryboard(true)
        })
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
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

    func registerDevice(_ completionHandler: LRCompletionBlock?)
    {
        let model = UIDevice.current.model
        
        let systemVersion = UIDevice.current.systemVersion
        
        let timeZone = NSTimeZone.local.secondsFromGMT()
     
        // Create unique device id and store it in keychain
        let uuidString = UUID().uuidString
        
        deviceKey = uuidString
        
//        saveDeviceToken()

        let jsonBody = ["device_id":    uuidString,
                        "device_name":  model,
                        "os_version":   systemVersion,
                        "timezone":     timeZone] as [String : Any]
        
        sendRequest(self.jsonRequest(APIUrlAtEndpoint("device"), httpMethod: "POST", json: jsonBody), authorization: false, completion: { (success, error, response) -> Void in
         
            if success
            {
                if let jsonDict = response?.dictionaryObject
                {
                    if let tokenResponse = Mapper<DeviceTokenResponse>().map(JSON: jsonDict)
                    {
                        self.tokenObject = tokenResponse
                        
                        self.saveCredentials()
                        
                        if let completion = completionHandler
                        {
                            completion(true, nil, tokenResponse)
                            
                            return
                        }
                    }
                }
                
                // Invalid Response
                if let completion = completionHandler
                {
                    completion(false, "Invalid token response.", nil)
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
                    completion(false, error, nil)
                }
            }
        })
    }
    
    func registerWithEmail(_ email: String, password: String, firstName: String, lastName: String, gender: String, age: NSNumber, completionHandler: LRCompletionBlock?)
    {
        let jsonBody = ["email": email,
                        "password": password,
                        "first_name": firstName,
                        "last_name": lastName,
                        "gender": gender,
                        "age": age] as [String : Any]
        
        sendRequest(self.jsonRequest(APIUrlAtEndpoint("user"), httpMethod: "PUT", json: jsonBody), authorization: true, completion: { (success, error, response) -> Void in
         
            if success
            {
                if let jsonDict = response?.dictionaryObject
                {
                    if let tokenResponse = Mapper<DeviceTokenResponse>().map(JSON: jsonDict)
                    {
                        self.tokenObject = tokenResponse
                        
                        self.saveCredentials()
                        
                        if let completion = completionHandler
                        {
                            completion(true, nil, tokenResponse)
                            
                            return
                        }
                    }
                }
                
                // Invalid Response
                if let completion = completionHandler
                {
                    completion(false, "Invalid token response.", nil)
                }
            }
            else
            {
                if let completion = completionHandler
                {
                    completion(false, error, nil)
                }
            }
        })
    }
    
    func registerWithFacebook(_ email: String, firstName: String?, lastName: String?, gender: String?, age: NSNumber?, completionHandler: LRCompletionBlock?)
    {
        if let facebookToken = FBSDKAccessToken.current().tokenString
        {
            var jsonBody: Dictionary<String,AnyObject> = [
                "facebook_token":   facebookToken as AnyObject,
                "email":            email as AnyObject]
            
            if firstName != nil { jsonBody["first_name"] = firstName as AnyObject? }
            
            if lastName != nil { jsonBody["last_name"] = lastName as AnyObject? }
            
            if gender != nil { jsonBody["gender"] = gender as AnyObject? }
            
            if age != nil { jsonBody["age"] = age }
            
            let httpBody = jsonBody
            
            sendRequest(self.jsonRequest(APIUrlAtEndpoint("user/register"), httpMethod: "POST", json: httpBody), authorization: true, completion: { (success, error, response) -> Void in
                
                if success
                {
                    if let jsonDict = response?.dictionaryObject
                    {
                        if let tokenResponse = Mapper<DeviceTokenResponse>().map(JSON: jsonDict)
                        {
                            self.tokenObject = tokenResponse
                            
                            self.saveCredentials()
                            
                            if let completion = completionHandler
                            {
                                completion(true, nil, tokenResponse)
                                
                                return
                            }
                        }
                    }
                    
                    // Invalid Response
                    if let completion = completionHandler
                    {
                        completion(false, "Invalid token response.", nil)
                    }
                }
                else
                {
                    if let completion = completionHandler
                    {
                        completion(false, error, nil)
                    }
                }
            })
        }
        else
        {
            if let completion = completionHandler
            {
                completion(false, "Invalid Facebook Token.", nil)
            }
        }
    }
    
    func loginWithEmail(_ email: String, password: String, completionHandler: LRCompletionBlock?)
    {
        if let deviceId = deviceKey
        {
            let jsonBody = ["email": email,
                            "password": password,
                            "device_id": deviceId]
            
            sendRequest(self.jsonRequest(APIUrlAtEndpoint("user/session"), httpMethod: "POST", json: jsonBody), authorization: false, completion: { (success, error, response) -> Void in
                
                if success
                {
                    if let jsonDict = response?.dictionaryObject
                    {
                        if let tokenResponse = Mapper<DeviceTokenResponse>().map(JSON: jsonDict)
                        {
                            log.debug("User logged in with email.")
                            
                            self.tokenObject = tokenResponse
                            
                            self.saveCredentials()
                            
                            if let completion = completionHandler
                            {
                                completion(true, nil, tokenResponse)
                                
                                return
                            }
                        }
                    }
                    
                    // Invalid Response
                    if let completion = completionHandler
                    {
                        completion(false, "Invalid token response.", nil)
                    }
                }
                else
                {
                    if let completion = completionHandler
                    {
                        completion(false, error, nil)
                    }
                }
            })
        }
    }

    func loginWithFacebook(_ completionHandler: LRCompletionBlock?)
    {
        if let facebookToken = FBSDKAccessToken.current().tokenString,
            let deviceId = deviceKey
        {
            let jsonBody = ["facebook_token": facebookToken,
                            "device_id": deviceId]

            sendRequest(self.jsonRequest(APIUrlAtEndpoint("user/session"), httpMethod: "POST", json: jsonBody), authorization: false, completion: { (success, error, response) -> Void in
                
                if success
                {
                    if let jsonDict = response?.dictionaryObject
                    {
                        if let tokenResponse = Mapper<DeviceTokenResponse>().map(JSON: jsonDict)
                        {
                            log.debug("User logged in with Facebook.")
                            
                            self.tokenObject = tokenResponse
                            
                            self.saveCredentials()
                            
                            if let completion = completionHandler
                            {
                                completion(true, nil, tokenResponse)
                                
                                return
                            }
                        }
                    }
                    
                    // Invalid Response
                    if let completion = completionHandler
                    {
                        completion(false, "Invalid token response.", nil)
                    }
                }
                else
                {
                    if let completion = completionHandler
                    {
                        completion(false, error, nil)
                    }
                }
            })
        }
        else
        {
            if let completion = completionHandler
            {
                completion(false, "Invalid Facebook Token.", nil)
            }
        }
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
                            
                            self.saveCredentials()
                            
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
                    
                    // If refresh token is invalid, clear credential cache and return to login screen
                    self.clearCredentials()
                    
                    DispatchQueue.main.async {
                        
                        AppStateTransitioner.transitionToLoginStoryboard(true)
                    }
                }
            })
        }
        else
        {
            // If refresh token is invalid, clear credential cache and return to login screen
            self.abortSessionAndRegisterNewDevice({ (success, error, response) -> Void in
                
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    AppStateTransitioner.transitionToLoginStoryboard(true)
                })
            })
            
            if let completion = completionHandler
            {
                completion(false, "User cannot retreive a new refresh token because the current refresh token does not exist.", nil)
            }
        }
    }
    
    func logoutRemotely(_ completionHandler: LRJsonCompletionBlock?)
    {
        sendRequest(self.jsonRequest(APIUrlAtEndpoint("device/logout"), httpMethod: "POST", json: [:]), authorization: true, completion: { (success, error, response) -> Void in
         
            if success
            {
                log.debug("User successfully logged out.")
                
                if let completion = completionHandler
                {
                    completion(true, nil, response)
                }
            }
            else
            {
                if let completion = completionHandler
                {
                    completion(false, nil, nil)
                }
            }
        })
    }
        
    func fetchFacebookUserInfo(_ completion: LRCompletionBlock?)
    {
        // The currentAccessToken() should be retrieved from Facebook in the View Controller that the login dialogue is shown from.
        if (FBSDKAccessToken.current() != nil)
        {
            // Get user information with Facebook Graph API
            if var request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, age_range, link, gender, locale, picture, timezone, updated_time, verified, friends, email"], httpMethod: "GET")
            {
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    request.start(completionHandler: {(connection:FBSDKGraphRequestConnection?, result: Any?, error: Error?) in
                        
                        if error == nil
                        {
                            if let jsonDict = JSON(result).dictionaryObject
                            {
                                if let response = Mapper<FacebookUserResponse>().map(JSON: jsonDict)
                                {
                                    if let gender = response.gender
                                    {
                                        // If gender exists but is not male or female
                                        if gender.characters.count > 0 && gender.lowercased() != "male" && gender.lowercased() != "female"
                                        {
                                            response.gender = "other specific"
                                        }
                                    }
                                    
                                    if let completionBlock = completion
                                    {
                                        completionBlock(true, nil, response)
                                    }
                                }
                            }
                            else
                            {
                                if let completionBlock = completion
                                {
                                    completionBlock(true, "fetchFacebookUserInfo: Invalid JSON response.", nil)
                                }
                            }
                        }
                        else
                        {
                            if let completionBlock = completion
                            {
                                completionBlock(true, error?.localizedDescription, nil)
                            }
                        }
                    })
                })
            }
        }
    }
    
    // MARK: Push Notifications
    
    func registerForRemoteNotificationsIfNeeded()
    {
        if !LRSessionManager.sharedManager.userHasEnabledNotifications()
        {
            // Prompt user to register for notifications
            let readAction: UIMutableUserNotificationAction = UIMutableUserNotificationAction()
            readAction.identifier = "READ_IDENTIFIER"
            readAction.title = "Read"
            readAction.activationMode = .foreground
            readAction.isDestructive = false
            readAction.isAuthenticationRequired = true
            
            let messageCategory = UIMutableUserNotificationCategory()
            messageCategory.identifier = "MESSAGE_CATEGORY"
            messageCategory.setActions([readAction], for: .default)
            messageCategory.setActions([readAction], for: .minimal)
            
            let categories: Set<UIUserNotificationCategory> = NSSet(object: messageCategory) as! Set<UIUserNotificationCategory>
            
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: categories)
            
            UIApplication.shared.registerForRemoteNotifications()
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
    }

    func userHasEnabledNotifications() -> Bool
    {
        if let grantedSettings: UIUserNotificationSettings = UIApplication.shared.currentUserNotificationSettings
        {
            // Check if no permission have been granted
            if grantedSettings.types == [.badge, .sound, .alert]
            {
                return true
            }
        }
        
        return false
    }
    
    // MARK: Fetching Server Data
    
    // MARK: Products
    func loadDiscoverProducts(_ completionHandler: LRCompletionBlock?)
    {
        var request = URLRequest(url: APIUrlAtEndpoint("products/531614790"))
        
        request.httpMethod = "GET"
        
        sendRequest(request, authorization: true, completion: { (success, error, response) -> Void in
            
            if success
            {
                if let jsonResponse = response
                {
                    if let array = jsonResponse.arrayObject as? [[String:Any]]
                    {
                        var products = Mapper<Product>().mapArray(JSONArray: array)
                        
                        // Incomplete Product Patch
                        if products != nil
                        {
                            products = products?.filter({ $0.isValid() })
                        }
                        
                        if let completion = completionHandler
                        {
                            completion(success, error, products)
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
    
    
    func loadProductCollection(_ page: Int, completionHandler: LRCompletionBlock?)
    {
        if page >= 0
        {
            var requestString = "search?q=%20&page=\(page)&per_page=\(productCollectionPageSize)"
            
            if FilterManager.defaultManager.getCurrentFilter().hasActiveFilters()
            {
                let paramsString = FilterManager.defaultManager.filterParamsAsString()
                
                requestString = requestString + "&\(paramsString)"
            }
            
            sendRequest(self.jsonRequest(APIUrlAtEndpoint(requestString), httpMethod: "POST", json: [:]), authorization: true, completion: { (success, error, response) -> Void in
                
                if success
                {
                    if let jsonResponse = response
                    {
                        if let results = jsonResponse.dictionaryObject?["results"] as? Dictionary<String,Any>
                        {
                            if let array = results["products"] as? [[String:Any]]
                            {
                                if let products = Mapper<Product>().mapArray(JSONArray: array)
                                {
                                    if let completion = completionHandler
                                    {
                                        completion(success, error, products)
                                        
                                        return
                                    }
                                }
                            }
                        }
                        
                        if let completion = completionHandler
                        {
                            completion(false, "Error parsing JSON.", nil)
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
                completion(false, "INVALID_PARAMETERS".localized, nil)
            }
        }
    }
    
    // MARK: Posts
    func loadPosts(_ completionHandler: LRCompletionBlock?)
    {
        var request = URLRequest(url: APIUrlAtEndpoint("posts"))
        
        request.httpMethod = "GET"
        
        sendRequest(request, authorization: true, completion: { (success, error, response) -> Void in
            
            if success
            {
                
            }
            else
            {
                if let completion = completionHandler
                {
                    completion(false, error, nil)
                }
            }
        })
    }
    
    // MARK: Filtering
    
    func loadCategories(_ completionHandler: LRCompletionBlock?)
    {
        var request = URLRequest(url: APIUrlAtEndpoint("categories"))
        
        request.httpMethod = "GET"
        
        sendRequest(request, authorization: true, completion: { (success, error, response) -> Void in
            
            if success
            {
                if let jsonArray = response?.arrayObject as? [[String:Any]]
                {
                    let categories = Mapper<Category>().mapArray(JSONArray: jsonArray)
                    
                    let sortedCategories = categories?.sorted {
                        
                        if let name1 = $0.name, let name2 = $1.name
                        {
                            return name1 < name2
                        }
                        
                        return false
                    }
                    
                    if let completion = completionHandler
                    {
                        completion(true, error, sortedCategories)
                    }
                }
            }
            else
            {
                if let completion = completionHandler
                {
                    completion(false, error, nil)
                }
            }
        })
    }
    
    func loadBrands(_ completionHandler: LRCompletionBlock?)
    {
        var request = URLRequest(url: APIUrlAtEndpoint("brands"))
        
        request.httpMethod = "GET"
        
        sendRequest(request, authorization: true, completion: { (success, error, response) -> Void in
            
            if success
            {
                if let jsonResponse = response
                {
                    if let brandArray = jsonResponse.dictionaryObject?["brands"] as? [[String:Any]]
                    {
                        let brands = Mapper<Brand>().mapArray(JSONArray: brandArray)
                        
//                        let sortedBrands = brands?.sort{ $0.name < $1.name }
                        
                        if let completion = completionHandler
                        {
                            completion(true, error, brands)
                            
                            return
                        }
                    }
                }
                
                if let completion = completionHandler
                {
                    completion(false, "Error parsing brands.", nil)
                }
            }
            else
            {
                if let completion = completionHandler
                {
                    completion(false, error, nil)
                }
            }
        })
    }
    
    func loadRetailers(_ completionHandler: LRCompletionBlock?)
    {
        var request = URLRequest(url: APIUrlAtEndpoint("retailers"))
        
        request.httpMethod = "GET"
        
        sendRequest(request, authorization: true, completion: { (success, error, response) -> Void in
            
            if success
            {
                if let jsonArray = response?.arrayObject as? Array<[String:Any]>
                {
                    let retailers = Mapper<Retailer>().mapArray(JSONArray: jsonArray)
                    
                    let sortedRetailers = retailers?.sorted {
                        
                        if let name1 = $0.name, let name2 = $1.name
                        {
                            return name1 < name2
                        }
                        
                        return false
                    }
                    
                    if let completion = completionHandler
                    {
                            completion(true, error, sortedRetailers)
                    }
                }
            }
            else
            {
                if let completion = completionHandler
                {
                    completion(false, error, nil)
                }
            }
        })
    }
    
    func loadColors(_ completionHandler: LRCompletionBlock?)
    {
        var request = URLRequest(url: APIUrlAtEndpoint("colors"))
        
        request.httpMethod = "GET"
        
        sendRequest(request, authorization: true, completion: { (success, error, response) -> Void in
            
            if success
            {
                if let jsonArray = response?.arrayObject as? [[String:Any]]
                {
                    let colors = Mapper<ColorObject>().mapArray(JSONArray: jsonArray)
                    
                    let sortedColors = colors?.sorted {
                        
                        if let name1 = $0.name, let name2 = $1.name
                        {
                            return name1 < name2
                        }
                        
                        return false
                    }
                    
                    if let completion = completionHandler
                    {
                        completion(true, error, sortedColors)
                    }
                }
            }
            else
            {
                if let completion = completionHandler
                {
                    completion(false, error, nil)
                }
            }
        })
    }
    
    // MARK: Search
    func search(_ query: String, completionHandler: LRCompletionBlock?)
    {
        if query.characters.count > 0
        {
            let pageSize = 5
            
            // Encode string to url format
            let queryString = query.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            
            let requestString = "search?&q=\(queryString)&per_page=\(pageSize)"
            
            var request = URLRequest(url: APIUrlAtEndpoint(requestString))
            
            request.httpMethod = "GET"
            
            sendRequest(request, authorization: true, completion: { (success, error, response) -> Void in
                
                if success
                {
                    if let jsonResponse = response
                    {
                        if let results = jsonResponse.dictionaryObject?["results"] as? Dictionary<String, AnyObject>
                        {
                            let searchResults = Mapper<SearchResults>().map(JSON: results)
                            
                            var compiledResults = NSMutableArray()
                            
                            if let brandResults = searchResults?.brands
                            {
                                if let firstBrand = brandResults[safe: 0]
                                {
                                    compiledResults.add(firstBrand)
                                }
                            }
                            
                            if let categoryResults = searchResults?.categories
                            {
                                if let firstCategory = categoryResults[safe: 0]
                                {
                                    compiledResults.add(firstCategory)
                                }
                            }
                            
                            if let productResults = searchResults?.products
                            {
                                compiledResults.addObjects(from: productResults)
                            }
                            
                            if let completion = completionHandler
                            {
                                completion(success, error, compiledResults)
                                
                                return
                            }
                        }
                    }
                    
                    // No results or Error
                    if let completion = completionHandler
                    {
                        completion(true, "No results.", nil)
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
                completion(false, "INVALID_PARAMETERS".localized, nil)
            }
        }
    }
    
    func searchProducts(_ query: String, completionHandler: LRCompletionBlock?)
    {
        if query.characters.count > 0
        {
            let pageSize = 5
            
            // Encode string to url format
            let queryString = query.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            
            let requestString = "search?&q=\(queryString)&per_page=\(pageSize)"
            
            var request = URLRequest(url: APIUrlAtEndpoint(requestString))
            
            request.httpMethod = "GET"
            
            sendRequest(request, authorization: true, completion: { (success, error, response) -> Void in
                
                if success
                {
                    if let jsonResponse = response
                    {
                        if let results = jsonResponse.dictionaryObject?["results"] as? Dictionary<String, AnyObject>
                        {
                            let searchResults = Mapper<SearchResults>().map(JSON: results)
                            
                            if let products: Array<SimpleProduct> = searchResults?.products
                            {
                                if let completion = completionHandler
                                {
                                    completion(success, error, products)
                                    
                                    return
                                }
                            }
                        }
                    }
                    
                    // No results or Error
                    if let completion = completionHandler
                    {
                        completion(true, "No results.", nil)
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
    }
    
    // MARK: Contact
    func submitContactForm(_ email: String, content: String, completionHandler: LRJsonCompletionBlock?)
    {
        let jsonBody = ["email": email,
                        "content": content,
                        "subject": "iOS Contact Form"
        ] as [String:Any]
        
        sendRequest(self.jsonRequest(APIUrlAtEndpoint("contact"), httpMethod: "POST", json: jsonBody), authorization: true, completion: { (success, error, response) -> Void in
            
            if let completion = completionHandler
            {
                completion(success, error, response)
            }
        })
    }
        
    // MARK: API Helpers
    func APIUrlAtEndpoint(_ endpointPath: String?) -> URL
    {
        if let path = endpointPath
        {
            return URL(string: kLRAPIBase + path)!
        }
        
        return URL(string: "")! // Make sure this does not fail
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
