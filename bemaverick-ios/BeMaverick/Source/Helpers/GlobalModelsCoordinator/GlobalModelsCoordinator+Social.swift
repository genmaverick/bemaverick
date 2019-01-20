//
//  GlobalModelsCoordinator+Social.swift
//  Maverick
//
//  Created by David McGraw on 5/10/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

extension GlobalModelsCoordinator {

    /**
     Request an SMS code for authorization
     
     - parameter phone:             A phone number to send the code to
     - parameter completionHandler: The closure called upon completion with the response data
     */
    open func smsCodeRequest(withPhoneNumber phone: String,
                             completionHandler: @escaping AuthorizationRequestCompletedClosure)
    {
        
        apiService.smsCodeRequest(withPhoneNumber: phone) { response, error in
            
            if error != nil {
                completionHandler(nil, error)
                return
            }
            
            completionHandler(response, nil)
            
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
        
        apiService.smsCodeVerify(withPhoneNumber: phone, code: code) { response, error in
            
            if error != nil {
                
                if error?.localizedDescription.contains("SMS_CODE_IS_INVALID") ?? false {
                    completionHandler(nil, MaverickError.authorizationFailureReason(reason: .smsCodeInvalidError()))
                } else {
                    completionHandler(nil, error)
                }
                return
                
            }
            
            completionHandler(response, nil)
            
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
        
        apiService.smsCodeConfirm(withPhoneNumber: phone,
                                  code: code,
                                  username: username,
                                  birthdate: birthdate)
        { response, error in
        
            guard let token = response?.accessToken, let refreshToken = response?.refreshToken, error == nil else {
                completionHandler(nil, error)
                return
            }
            
            self.authorizationManager.currentAccessToken = (token, refreshToken)
            
            self.reloadLoggedInUser(completionHandler: {
                
                self.authorizationManager.onUserAuthorizedSignal.fire(true)
                completionHandler(response, nil)
                
            })
            
            
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
        
        apiService.authorizeFacebookUserAccount(withAccessToken: token, username: username, birthdate: birthdate) { response, error in
            
            guard let token = response?.accessToken, let refreshToken = response?.refreshToken, error == nil else {
                completionHandler(nil, error)
                return
            }

            
            self.authorizationManager.currentAccessToken = (token, refreshToken)
            self.reloadLoggedInUser(completionHandler: {
                
                self.authorizationManager.onUserAuthorizedSignal.fire(true)
                completionHandler(nil, nil)
                
            })
            
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
        
        apiService.authorizeTwitterUserAccount(withAccessToken: token, secret: secret, username: username, birthdate: birthdate) { response, error in
            
            guard let token = response?.accessToken, let refreshToken = response?.refreshToken, error == nil else {
                completionHandler(nil, error)
                return
            }
            
            self.authorizationManager.currentAccessToken = (token, refreshToken)
            self.reloadLoggedInUser(completionHandler: {
                
                self.authorizationManager.onUserAuthorizedSignal.fire(true)
                completionHandler(nil, nil)
                
            })
            
        }
        
    }
    
}
