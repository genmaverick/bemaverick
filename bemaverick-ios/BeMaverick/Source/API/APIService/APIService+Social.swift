//
//  APIService+Social.swift
//  Maverick
//
//  Created by David McGraw on 5/10/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import Alamofire

extension APIService {

    /**
     Request an SMS code for authorization
     
     - parameter phone:             A phone number to send the code to
     - parameter completionHandler: The closure called upon completion with the response data
     */
    open func smsCodeRequest(withPhoneNumber phone: String,
                             completionHandler: @escaping AuthorizationRequestCompletedClosure)
    {
    
        log.verbose("📥 SMS Code Request for number \(phone)")
        
        Alamofire.request(AuthorizationRouter.authMethodSMSRequest(phone: phone))
            .validate()
            .responseObject { (response: DataResponse<AuthorizationResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to request an SMS code \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    /**
     Verify that the Phone and Code match for authorization
     
     - parameter phone:             The phone number used for authorization
     - parameter code:              The code to verify against
     - parameter completionHandler: The closure called upon completion with the response data
     */
    open func smsCodeVerify(withPhoneNumber phone: String,
                            code: String,
                            completionHandler: @escaping AuthorizationRequestCompletedClosure)
    {
        
        log.verbose("📥 SMS Code \(code) Verify for number \(phone)")
        
        Alamofire.request(AuthorizationRouter.authMethodSMSVerify(phone: phone, code: code))
            .validate()
            .responseObject { (response: DataResponse<AuthorizationResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to verify the SMS code \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    /**
     Authorize or create an account via SMS
     
     - parameter phone:             The phone number to verify
     - parameter code:              A verification code
     - parameter username:          [register only] The username for the account
     - parameter birthdate:         [register only] The birthdate for the user
     - parameter completionHandler: The closure called upon completion with the response data
     */
    open func smsCodeConfirm(withPhoneNumber phone: String,
                             code: String,
                             username: String? = nil,
                             birthdate: String? = nil,
                             completionHandler: @escaping AuthorizationRequestCompletedClosure)
    {
        
        var isNewUser: Bool = false
        if username != nil && birthdate != nil {
            isNewUser = true
        }
        
        log.verbose("📥 SMS authorization: \(isNewUser ? "NEW ACCOUNT" : "LOGIN")")
        
        Alamofire.request(AuthorizationRouter.authMethodSMSConfirm(phone: phone, code: code, username: username ?? "", birthdate: birthdate ?? ""))
            .validate()
            .responseObject { (response: DataResponse<AuthorizationResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to authorize via SMS \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    /**
     Register or Login using Facebook (> 13yo only)
     
     - parameter token:             A Facebook access token
     - parameter username:          [register only] The username for the account
     - parameter birthdate:         [register only] The birthdate for the user
     - parameter completionHandler: The closure called upon completion with the response data
     */
    open func authorizeFacebookUserAccount(withAccessToken token: String,
                                           username: String? = nil,
                                           birthdate: String? = nil,
                                           completionHandler: @escaping AuthorizationRequestCompletedClosure)
    {
        
        var isNewUser: Bool = false
        if username != nil && birthdate != nil {
            isNewUser = true
        }
        
        log.verbose("📥 Facebook authorization: \(isNewUser ? "NEW ACCOUNT" : "LOGIN")")
        
        Alamofire.request(AuthorizationRouter.authMethodFacebook(token: token, username: username ?? "", birthdate: birthdate ?? ""))
            .validate()
            .responseObject { (response: DataResponse<AuthorizationResponse>) in

                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to authorize via Facebook \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }

                completionHandler(response.value, nil)

        }
        
    }

    /**
     Register or Login using Twitter (> 13yo only)
     
     - parameter token:             A Twitter access token
     - parameter token:             A Twitter secret token
     - parameter username:          [register only] The username for the account
     - parameter birthdate:         [register only] The birthdate for the user
     - parameter completionHandler: The closure called upon completion with the response data
     */
    open func authorizeTwitterUserAccount(withAccessToken token: String,
                                          secret: String,
                                          username: String? = nil,
                                          birthdate: String? = nil,
                                          completionHandler: @escaping AuthorizationRequestCompletedClosure)
    {
        
        var isNewUser: Bool = false
        if username != nil && birthdate != nil {
            isNewUser = true
        }
        
        log.verbose("📥 Twitter authorization: \(isNewUser ? "NEW ACCOUNT" : "LOGIN")")
        
        Alamofire.request(AuthorizationRouter.authMethodTwitter(token: token, secret: secret, username: username ?? "", birthdate: birthdate ?? ""))
            .validate()
            .responseObject { (response: DataResponse<AuthorizationResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to authorize via Twitter \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
}
