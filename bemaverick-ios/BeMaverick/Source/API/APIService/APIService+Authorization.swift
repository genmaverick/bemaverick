//
//  APIService+Authorization.swift
//  BeMaverick
//
//  Created by David McGraw on 9/25/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper

extension APIService {
    
    /**
     Get a token that can be used to issue requests as a client, not a particular user
     
     - parameter completionHandler: The closure called upon completion with the response data
     */
    open func getClientAuthorizationToken(completionHandler: @escaping AuthorizationRequestCompletedClosure) {
        
        log.verbose("📥 Fetching a CLIENT authorization token")
        
        Alamofire.request(AuthorizationRouter.getClientToken)
            .validate()
            .responseObject { (response: DataResponse<AuthorizationResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to fetch a client authorization token: \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    
    /**
     Get a USER token that can be used to issue requests on the user's behalf
     
     - parameter username:          The username for the account
     - parameter password:          The password associated with the account
     - parameter completionHandler: The closure called upon completion with the response data
     */
    open func getUserAuthorizationToken(withUsername username: String,
                                        password: String,
                                        completionHandler: @escaping AuthorizationRequestCompletedClosure)
    {
        
        log.verbose("📥 Fetching a USER authorization token")
        
        Alamofire.request(AuthorizationRouter.getUserToken(username: username, password: password))
            .validate()
            .responseObject { (response: DataResponse<AuthorizationResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to fetch a user authorization token: \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    /**
     Refresh a user authorization token using a special `refresh token`
     
     - parameter token:     The `Refresh Token` that was provided during auth
     - parameter completionHandler: The closure called upon completion with the response data
     */
    open func refreshUserAuthorizationToken(withRefreshToken token: String,
                                            completionHandler: @escaping AuthorizationRequestCompletedClosure)
    {
        
        log.verbose("📥 Fetching a refreshed authorization token")
        
        Alamofire.request(AuthorizationRouter.refreshUserToken(refreshToken: token))
            .validate()
            .responseObject { (response: DataResponse<AuthorizationResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to fetch a refreshed token: \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
    }
    
    /**
     Register a new MAVERICK (KID) or PARENT account
     
     - parameter type:              The account type to create
     - parameter username:          The username for the account
     - parameter password:          The password associated with the account
     - parameter email:             The primary e-mail that will be used for the account (or to verify the account)
     - parameter completionHandler: The closure called upon completion with the response data
     */
    open func registerUserAccount(withAccountType type: Constants.AccountType,
                                  username: String,
                                  password: String,
                                  dateOfBirth: String,
                                  kidEmail: String,
                                  parentEmail: String,
                                  completionHandler: @escaping AuthorizationRequestCompletedClosure)
    {
        
        
        if type == .maverick {
            registerKidAccount(withUsername: username, password: password, dateOfBirth: dateOfBirth, kidEmail: kidEmail, parentEmail: parentEmail, completionHandler: completionHandler)
        } else if type == .parent {
            registerParentAccount(withUsername: username, password: password, email: parentEmail, completionHandler: completionHandler)
        }
        
    }
    
    
    /**
     Register a new PARENT account
     
     - parameter username:          The username for the account
     - parameter password:          The password associated with the account
     - parameter email:             The primary e-mail that will be used to register their kids with
     - parameter completionHandler: The closure called upon completion with the response data
     */
    private func registerParentAccount(withUsername username: String,
                                       password: String,
                                       email: String,
                                       completionHandler: @escaping AuthorizationRequestCompletedClosure)
    {
        
        log.verbose("📥 Registering a new PARENT account")
        
        Alamofire.request(AuthorizationRouter.registerParentAccount(username: username, password: password, email: email))
            .validate()
            .responseObject { (response: DataResponse<AuthorizationResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to register a new PARENT account \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    /**
     Register a new KID account
     
     - parameter username:          The username for the account
     - parameter password:          The password associated with the account
     - parameter dateOfBirth:       The DoB of the kid:  YYYY-MM-DD
     - parameter kidEmail:          The kid email, if over 13
     - parameter parentEmail:       The primary e-mail that's used to register their kids with (if under 13)
     - parameter completionHandler: The closure called upon completion with the response data
     */
    private func registerKidAccount(withUsername username: String,
                                    password: String,
                                    dateOfBirth: String, kidEmail: String, parentEmail: String,
                                    completionHandler: @escaping AuthorizationRequestCompletedClosure)
    {
        
        log.verbose("📥 Registering a new KID account")
        
        Alamofire.request(AuthorizationRouter.registerKidAccount(username: username, password: password, dateOfBirth: dateOfBirth, kidEmail: kidEmail, parentEmail: parentEmail))
            .validate()
            .responseObject { (response: DataResponse<AuthorizationResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to register a new KID account: \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                DBManager.sharedInstance.attemptLoggedInDBWrite {
                    
                    DBManager.sharedInstance.getLoggedInUser()?.username = username
                    
                }
                completionHandler(response.value, nil)
                
        }
        
    }
    
    /**
     Request a reset password link using the provided username
     
     - parameter username:          The username to request the reset password link for
     - parameter completionHandler: The closure called upon completion with the response data
     */
    open func requestForgotPassword(withUsername username: String,
                                    completionHandler: @escaping AuthorizationRequestCompletedClosure)
    {
        
        log.verbose("📥 Forgot Password request using username")
        
        Alamofire.request(AuthorizationRouter.forgotPasswordUsingUsername(username: username))
            .validate()
            .responseObject { (response: DataResponse<AuthorizationResponse>) in
                
                if let error = response.error, let data = response.data  {
                    log.error("❌ Failed to request a forgot password link \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    /**
     See if a username is available
     
     - parameter username:          The username to request availability for
     - parameter completionHandler: The closure called upon completion with the response data
     */
    open func validateAvailability(withUsername username: String,
                                    completionHandler: @escaping AuthorizationRequestCompletedClosure)
    {
        
        log.verbose("📥 validate username availability: \(username)")
        
        Alamofire.request(AuthorizationRouter.validateUsername(username: username))
            .validate()
            .responseObject { (response: DataResponse<AuthorizationResponse>) in
                
                if let error = response.error, let data = response.data  {
                    log.error("❌ Failed to validate a username \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    /**
     Request a reset password link using the provided parent email
     
     - parameter username:          The username to request the reset password link for
     - parameter completionHandler: The closure called upon completion with the response data
     */
    open func requestForgotUsername(withEmailAddress email: String,
                                    completionHandler: @escaping AuthorizationRequestCompletedClosure)
    {
        
        log.verbose("📥 Forgot Username request using email")
        
        Alamofire.request(AuthorizationRouter.forgotUsername(email: email))
            .validate()
            .responseObject { (response: DataResponse<AuthorizationResponse>) in
                
                if let error = response.error, let data = response.data  {
                    log.error("❌ Failed to request a forgot password link \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    /**
     Verify the identity of the parent
     
     - parameter completionHandler: The closure called upon completion with the response data
     */
    open func verifyParentInfo(withFirstName firstName: String,
                               lastName: String,
                               address: String,
                               zip: String,
                               ssn: String,
                               childUserId: String,
                               retry: Int = 0,
                               completionHandler: @escaping AuthorizationRequestCompletedClosure)
    {
        
        log.verbose("📥 Verify parent information")
        
        Alamofire.request(AuthorizationRouter.verifyParentInfo(firstName: firstName, lastName: lastName, address: address, zip: zip, ssn: ssn, retry: retry, childUserId: childUserId))
            .validate()
            .responseObject { (response: DataResponse<AuthorizationResponse>) in
                
                if let error = response.error, let data = response.data  {
                    log.error("❌ Failed to verify parent information \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                if let coppaStatus = response.value?.coppaStatus {
                    
                    if coppaStatus == "FAIL" {
                        return completionHandler(response.value, MaverickError.authorizationFailureReason(reason: .coppaFailedError()))
                    } else if coppaStatus == "REVIEW" {
                        return completionHandler(response.value, MaverickError.authorizationFailureReason(reason: .coppaReviewError()))
                    } else if coppaStatus == "REJECT" {
                        return completionHandler(response.value, MaverickError.authorizationFailureReason(reason: .coppaRejectedError()))
                    }
                    
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    /**
     Update the status of the VPC for the kid account
     
     - parameter childId: The user id to update
     - parameter status: The VPC status (0 or 1)
     - parameter completionHandler: The closure called upon completion with the response data
     */
    open func updateVPCStatus(withChildId childId: String,
                              status: Int = 0,
                              completionHandler: @escaping AuthorizationRequestCompletedClosure)
    {
        
        log.verbose("📥 Update the status of the VPC for the kid account")
        
        Alamofire.request(AuthorizationRouter.editVPCStatus(userId: childId, vpc: status))
            .validate()
            .responseObject { (response: DataResponse<AuthorizationResponse>) in
                
                if let error = response.error, let data = response.data  {
                    log.error("❌ Failed to update the status of the VPC for the kid account \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
    /**
     Fetches the user details for the authorized user
     
     - parameter completionHandler: The closure called upon completion with the response data
     */
    func getSiteConfig(completionHandler: @escaping SiteConfigRequestCompletedClosure) {
        
        log.verbose("📥 Fetching site config")
        
        Alamofire.request(AuthorizationRouter.config)
            .validate()
            .responseObject { (response: DataResponse<ConfigResponse>) in
                
                if let error = response.error, let data = response.data {
                    log.error("❌ Failed to fetch site config data: \(error)")
                    return completionHandler(response.value, MaverickError.apiServiceRequestFailed(reason: .dataError(data: data, error: error)))
                }
                
                completionHandler(response.value, nil)
                
        }
        
    }
    
}
