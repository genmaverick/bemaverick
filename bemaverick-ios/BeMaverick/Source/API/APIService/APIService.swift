//
//  APIService.swift
//  BeMaverick
//
//  Created by David McGraw on 9/14/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation
import Alamofire

public typealias VideoUploadCompletedClosure = (_ error: MaverickError?) -> ()
public typealias ResponseRequestCompletedClosure = (_ response: ResponsesResponse?, _ error: MaverickError?) -> ()
typealias CommentListClosure = (_ commentResponse: CommentResponse?, _ error: MaverickError?) -> ()
public typealias UserDetailsRequestCompletedClosure = (_ response: UserDetailsResponse?, _ error: MaverickError?) -> ()
typealias UserSearchRequestCompletedClosure = (_ response: [SearchUser]?, _ error: MaverickError?) -> ()
public typealias SiteConfigRequestCompletedClosure = (_ response: ConfigResponse?, _ error: MaverickError?) -> ()
public typealias UsersRequestCompletedClosure = (_ response: UsersResponse?, _ error: MaverickError?) -> ()
public typealias TagsRequestCompletedClosure = (_ response: [Hashtag]?, _ error: MaverickError?) -> ()
public typealias TagContentRequestCompletedClosure = (_ response: TagContentResponse?, _ error: MaverickError?) -> ()
public typealias AuthorizationRequestCompletedClosure = (_ response: AuthorizationResponse?, _ error: MaverickError?) -> ()

typealias ProjectClosure = (_ commentResponse: ProjectResponse?, _ error: MaverickError?) -> ()
typealias RewardClosure = (_ commentResponse: RewardResponse?, _ error: MaverickError?) -> ()

typealias ProgressionClosure = (_ commentResponse: ProgressionResponse?, _ error: MaverickError?) -> ()

class APIService {
    
    
    // MARK: - Public Properties
    
    /// A reference to the global model state
    open var globalModelsCoordinator: GlobalModelsCoordinator!
    
    /// The active API hostname
    open var apiHostname: String {
        
        if globalModelsCoordinator.authorizationManager.environment == .custom {
            
            return globalModelsCoordinator.authorizationManager.customBackendURL ?? globalModelsCoordinator.authorizationManager.environment.stringValue
            
        }
        
        return globalModelsCoordinator.authorizationManager.environment.stringValue
        
    }
    
    /// The active API hostname
    open var commentAPIhostname: String {
        
        return globalModelsCoordinator.authorizationManager.environment.commentBaseUrl
        
    }
    
    /// The active USER API token
    open var apiAccessToken: String? {
        return globalModelsCoordinator.authorizationManager.currentAccessToken?.accessToken
    }
    
    /// The temporary CLIENT API token
    open var apiClientToken: String? {
        return globalModelsCoordinator.authorizationManager.clientAccessToken
    }
    
    // MARK: - Lifecycle
    
    init(withGlobalModelsCoordinator coordinator: GlobalModelsCoordinator) {
        
        log.verbose("⚙ Initializing API Service")
        globalModelsCoordinator = coordinator
        
    }
    
    // MARK: - Public Methods
    
    func checkInactiveOrRevoked(request : URLRequest?, urlResponse : HTTPURLResponse, data : Data?) -> DataRequest.ValidationResult {
        
        do {
            if urlResponse.statusCode != 200, let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any] {
                
                print("⛔️⛔️⛔️⛔️⛔️⛔️⛔️⛔️⛔️⛔️⛔️⛔️⛔️\n⛔️\n⛔️\(request?.url?.absoluteString ?? "")\n⛔️\n⛔️json error:\n⛔️\n⛔️\(json)\n⛔️\n⛔️⛔️⛔️⛔️⛔️⛔️⛔️⛔️⛔️⛔️⛔️⛔️")
                
            }
            
            if urlResponse.statusCode == 400 {
                var isInactive = false
                var isRevoked : Constants.RevokedMode?
                
                
                if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any], let array = json["errors"] as? [Any] , let errors = array[safe: 0] as? [String:Any] , let id = errors["id"] as? String, let message = errors["message"] as? String {
                    
                    if id == "userInactive" {
                        
                        
                        isInactive = true
                        
                    } else if id == "userRevoked" || id == "userDeleted" {
                        
                        
                        
                        if message == "admin" || id == "userDeleted" {
                            isRevoked = .admin
                        } else {
                            isRevoked = .parent
                        }
                        
                        
                    }
                }
                
                
                
                if isRevoked != nil || isInactive {
                    DispatchQueue.main.async {
                        
                        
                        DBManager.sharedInstance.attemptLoggedInDBWrite {
                            
                            DBManager.sharedInstance.getLoggedInUser()?.isRevoked = true
                            
                        }
                        self.globalModelsCoordinator.authorizationManager.onUserInactiveSignal.fire(isRevoked)
                        
                    }
                    return .failure( NSError(domain:"", code:urlResponse.statusCode, userInfo:nil) )
                }
                
                
                
            }
        }  catch {
            
        }
        
        return .success
        
    }
    /**
     Retrieves the "Maverick Stream" feed which contains a variety of responses
     and challenges
     
     - parameter count:     The amount of content to fetch
     - parameter offset:    The offset to the fetched amount
     */
    open func getMaverickStream(completionHandler: @escaping (_ response: StreamResponse?) -> Void) {
        
        log.verbose("📥 Fetching Maverick Featured Stream content ")
        
        Alamofire.request(SiteRouter.getMaverickStream())
            .validate({ (urlRequest, urlResponse, data) -> Request.ValidationResult in
                
                return self.checkInactiveOrRevoked(request: urlRequest, urlResponse: urlResponse, data: data)
                
            })
            .validate()
            .responseObject { (response: DataResponse<StreamResponse>) in
                
                if let error = response.error {
                    
                    log.error("❌ Failed to fetch getMaverickStream: \(error)")
                }
                
                completionHandler(response.value)
                
        }
        
    }
    
    /**
     Retrieves the "Maverick Stream" feed which contains a variety of responses
     and challenges
     
     - parameter count:     The amount of content to fetch
     - parameter offset:    The offset to the fetched amount
     */
    open func moderate(text : String, completionHandler: @escaping (_ response: ModerateResponse?) -> Void) {
        
        log.verbose("📥 Fetching moderate UGC Text ")
        
        Alamofire.request(SiteRouter.moderateText(text: text))
            .validate()
            .responseObject { (response: DataResponse<ModerateResponse>) in
                
                if let error = response.error {
                    
                    log.error("❌ Failed to moderate UGC Text: \(error)")
                    
                }
                
                completionHandler(response.value)
                
        }
        
    }
    
    /**
     Retrieves the "Configurable Stream" feed which contains a variety of responses
     and challenges
     
     - parameter count:     The amount of content to fetch
     - parameter offset:    The offset to the fetched amount
     */
    open func getConfigurableStream(stream : Stream, count: Int = 20,
                                    offset: Int = 0, completionHandler: @escaping (_ response: ResponsesResponse?) -> Void) {
        
        log.verbose("📥 Fetching Configurable Stream content \(stream.identifier)")
        stream.count = count
        stream.offset = offset
        let req = SiteRouter.getConfigurableStream(stream: stream)
        Alamofire.request(req)
            .validate()
            .responseObject { (response: DataResponse<ResponsesResponse>) in
                
                if let error = response.error {
                    
                    log.error("❌ Failed to fetch Configurable Stream content \(stream.identifier) : \(error)")
                }
                
                completionHandler(response.value)
                
        }
        
    }
    
    /**
     Retrieves the "maverick badgess"
     
     */
    open func getMaverickBadges(completionHandler: @escaping (_ response: BadgesResponse?) -> Void) {
        
        log.verbose("📥 Fetching Maverick Badges")
        let req = SiteRouter.getMaverickBadges()
        Alamofire.request(req)
            .validate()
            .responseObject { (response: DataResponse<BadgesResponse>) in
                
                if let error = response.error {
                    
                    log.error("❌ Failed to fetch Maverick Badges: \(error)")
                }
                
                completionHandler(response.value)
                
        }
        
    }
    
    /**
     Retrieves the "maverick badgess"
     
     */
    open func getThemes(completionHandler: @escaping (_ response: ThemesResponse?) -> Void) {
        
        log.verbose("📥 Fetching UGC Themes")
        let req = SiteRouter.getThemes()
        
        Alamofire.request(req)
            .validate({ (urlRequest, urlResponse, data) -> Request.ValidationResult in
                
                return self.checkInactiveOrRevoked(request: urlRequest, urlResponse: urlResponse, data: data)
                
            })
            .validate()
            .responseObject { (response: DataResponse<ThemesResponse>) in
                
                if let error = response.error {
                    
                    log.error("❌ Failed to fetch UGC Themes: \(error)")
                }
                
                completionHandler(response.value)
                
        }
        
    }
    
}
