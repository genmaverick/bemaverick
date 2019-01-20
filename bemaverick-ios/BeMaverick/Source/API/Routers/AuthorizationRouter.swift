//
//  AuthorizationRouter.swift
//  BeMaverick
//
//  Created by David McGraw on 9/25/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Alamofire

enum AuthorizationRouter: URLRequestConvertible {
    
    /// Get a token that can be used to issue requests against the API
    case getClientToken
    
    /// Get a token for an authorized user
    case getUserToken(username: String, password: String)
    
    /// Refresh a user token by using a refresh token
    case refreshUserToken(refreshToken: String)
    
    /// Register a parent account
    case registerParentAccount(username: String, password: String, email: String)
    
    /// Register a kid account
    case registerKidAccount(username: String, password: String, dateOfBirth: String, kidEmail: String, parentEmail: String)
    
    /// Get a link to reset the password
    case forgotPasswordUsingUsername(username: String)
    
    /// Get a link to fetch username
    case forgotUsername(email: String)
    
    /// Verify identity of a parent
    case verifyParentInfo(firstName: String, lastName: String, address: String, zip: String, ssn: String, retry: Int, childUserId: String)
    
    /// Find out if a username is available
    case validateUsername(username: String)
    
    /// Update the status of the VPC for the kid account
    case editVPCStatus(userId: String, vpc: Int)
    
    /// Login or register a new account using Facebook
    case authMethodFacebook(token: String, username: String, birthdate: String)
    
    /// Login or register a new account using Twitter
    case authMethodTwitter(token: String, secret: String, username: String, birthdate: String)
    
    /// Request a code via SMS to be able to login
    case authMethodSMSRequest(phone: String)
    
    /// Check that the phone and code match
    case authMethodSMSVerify(phone: String, code: String)
    
    /// Login from an SMS code and phone number
    case authMethodSMSConfirm(phone: String, code: String, username: String, birthdate: String)
    
    /// Get site config data
    case config
    
    // MARK: - Method
    
    var method: HTTPMethod {
        
        switch self {
        case .getClientToken:
            return .post
        case .getUserToken:
            return .post
        case .refreshUserToken:
            return .post
        case .registerParentAccount:
            return .post
        case .registerKidAccount:
            return .post
        case .forgotPasswordUsingUsername:
            return .post
        case .forgotUsername:
            return .post
        case .verifyParentInfo:
            return .post
        case .editVPCStatus:
            return .post
        case .authMethodFacebook:
            return .get
        case .authMethodTwitter:
            return .get
        case .authMethodSMSRequest:
            return .get
        case .authMethodSMSVerify:
            return .get
        case .authMethodSMSConfirm:
            return .get
        case .config:
            return .get
        case .validateUsername:
            return .post
        }
        
    }
    
    // MARK: - Path
    
    var path: String {
        
        switch self {
        case .getClientToken:
            return "/oauth/token"
            
        case .getUserToken(_, _):
            return "/oauth/token"
            
        case .refreshUserToken(_):
            return "/oauth/token"
            
        case .registerParentAccount(_, _, _):
            return "/auth/registerparent"
            
        case .registerKidAccount(_, _, _, _, _):
            return "/auth/registerkid"
            
        case .forgotPasswordUsingUsername(_):
            return "/auth/forgotpassword"
            
        case .validateUsername(_):
            return "/auth/validateusername"
            
        case .forgotUsername(_):
            return "/auth/forgotusername"
            
        case .verifyParentInfo(_, _, _, _, _, _, _):
            return "/coppa/verifyparent"
            
        case .editVPCStatus(_, _):
            return "/coppa/editvpcstatus"
            
        case .config:
            return "/site/config"
            
        case .authMethodFacebook(_, _, _):
            return "/auth/facebooklogin"
            
        case .authMethodTwitter(_, _, _, _):
            return "/auth/twitterlogin"
            
        case .authMethodSMSRequest(_):
            return "/auth/smsloginrequest"
            
        case .authMethodSMSVerify(_, _):
            return "/auth/smsverifycode"
            
        case .authMethodSMSConfirm(_, _, _, _):
            return "/auth/smsloginconfirm"
            
            
        }
        
    }
    
    // MARK: - URL
    
    func asURLRequest() throws -> URLRequest {
        
        let urlRequest = baseURLRequest(with: path, httpMethod: method.rawValue)
        
        switch self {
        case .getClientToken:
            return encodedRequestURL(urlRequest, params: ["client_id": "bemaverick_ios", "client_secret": "8NFnps4makvxWcyF4qZL2Nw", "grant_type": "client_credentials"])
        case .getUserToken(let username, let password):
            return encodedRequestURL(urlRequest, params: ["client_id": "bemaverick_ios", "client_secret": "8NFnps4makvxWcyF4qZL2Nw", "grant_type": "password", "username": username, "password": password])
        case .refreshUserToken(let refreshToken):
            return encodedRequestURL(urlRequest, params: ["client_id": "bemaverick_ios", "client_secret": "8NFnps4makvxWcyF4qZL2Nw", "grant_type": "refresh_token", "refresh_token": refreshToken])
        case .registerParentAccount(let username, let password, let email):
            return encodedRequestURL(urlRequest, params: ["username": username, "password": password, "emailAddress": email])
        case .registerKidAccount(let username, let password, let dateOfBirth, let kidEmail, let parentEmail):
            return encodedRequestURL(urlRequest, params: ["username": username, "password": password,"birthdate":dateOfBirth, "emailAddress":kidEmail, "parentEmailAddress": parentEmail])
        case .forgotPasswordUsingUsername(let username):
            return encodedRequestURL(urlRequest, params: ["username": username])
        case .validateUsername(let username):
            return encodedRequestURL(urlRequest, params: ["username": username])
        case .forgotUsername(let email):
            return encodedRequestURL(urlRequest, params: ["emailAddress": email])
        case .verifyParentInfo(let firstName, let lastName, let address, let zip, let ssn, let retry, let childUserId):
            return encodedRequestURL(urlRequest, params: ["childUserId": childUserId, "firstName": firstName, "lastName": lastName, "address": address, "zipCode": zip, "lastFourSSN": ssn, "retry": retry])
        case .editVPCStatus(let userId, let vpc):
            return encodedRequestURL(urlRequest, params: ["childUserId": userId, "vpc": vpc])
        case .config:
            return encodedRequestURL(urlRequest)
        case .authMethodFacebook(let token, let username, let birthdate):
            return encodedRequestURL(urlRequest, params: ["fbAccessToken": token, "username": username, "birthdate": birthdate])
        case .authMethodTwitter(let token, let secret, let username, let birthdate):
            return encodedRequestURL(urlRequest, params: ["twitterAccessToken": token, "twitterAccessTokenSecret": secret, "username": username, "birthdate": birthdate])
        case .authMethodSMSRequest(let phone):
            return encodedRequestURL(urlRequest, params: ["phoneNumber": phone])
        case .authMethodSMSVerify(let phone, let code):
            return encodedRequestURL(urlRequest, params: ["phoneNumber": phone, "code": code])
        case .authMethodSMSConfirm(let phone, let code, let username, let birthdate):
            return encodedRequestURL(urlRequest, params: ["phoneNumber": phone, "code": code, "username": username, "birthdate": birthdate])
        }
    
    }
    
}
