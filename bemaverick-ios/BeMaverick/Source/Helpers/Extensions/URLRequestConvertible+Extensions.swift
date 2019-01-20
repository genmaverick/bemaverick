//
//  URLRequestConvertible+Extensions.swift
//  BeMaverick
//
//  Created by David McGraw on 9/14/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation
import Alamofire

extension URLRequestConvertible {
    
    func baseURLRequest(with path: String, httpMethod: String?) -> URLRequest {
        
        let apiService = (UIApplication.shared.delegate as! AppDelegate).services.apiService
        var request = URLRequest(url:  URL(string: apiService!.apiHostname)!.appendingPathComponent("\(path)"))
        
        // Set HTTPMethod
        request.httpMethod = httpMethod
        
        // Set authorization
        if let userToken = apiService?.apiAccessToken {
            request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        }
        else if let clientToken = apiService?.apiClientToken {
            request.setValue("\(clientToken)", forHTTPHeaderField: "Authorization")
        }

        return request
        
    }
    
    func baseURLRequest(with stream: Stream) -> URLRequest {
        
        let apiService = (UIApplication.shared.delegate as! AppDelegate).services.apiService
        var request = URLRequest(url:  URL(string: apiService!.apiHostname)!)
        
        if let host = stream.host, let path = stream.pathname {
            request =  URLRequest(url:  URL(string: "https://\(host)")!.appendingPathComponent(path))
        }
        // Set HTTPMethod
        request.httpMethod = "get"
        
        // Set authorization
        if let userToken = apiService?.apiAccessToken {
            request.setValue("Bearer \(userToken)", forHTTPHeaderField: "Authorization")
        }
        else if let clientToken = apiService?.apiClientToken {
            request.setValue("\(clientToken)", forHTTPHeaderField: "Authorization")
        }
        
        return request
        
    }
    
    func baseCommentURLRequest(with path: String, httpMethod: String?) -> URLRequest {
        
        let apiService = (UIApplication.shared.delegate as! AppDelegate).services.apiService
        var request = URLRequest(url:  URL(string: apiService!.commentAPIhostname)!.appendingPathComponent("\(path)"))
        
        // Set HTTPMethod
        request.httpMethod = httpMethod
        
        // Set authorization
        if let userToken = apiService?.apiAccessToken {
            request.setValue("\(userToken)", forHTTPHeaderField: "Authorization")
        }
        else if let clientToken = apiService?.apiClientToken {
            request.setValue("\(clientToken)", forHTTPHeaderField: "Authorization")
        }
        
        return request
        
    }
    
    func baseProgressionURLRequest(with path: String, httpMethod: String?) -> URLRequest {
        
        let apiService = (UIApplication.shared.delegate as! AppDelegate).services.apiService
        var request = URLRequest(url:  URL(string: apiService!.commentAPIhostname)!.appendingPathComponent("\(path)"))
        
        // Set HTTPMethod
        request.httpMethod = httpMethod
        
        // Set authorization
        if let userToken = apiService?.apiAccessToken {
            request.setValue("\(userToken)", forHTTPHeaderField: "Authorization")
        }
        else if let clientToken = apiService?.apiClientToken {
            request.setValue("\(clientToken)", forHTTPHeaderField: "Authorization")
        }
        
        return request
        
        
    }
    
    func encodedRequestURL(_ request: URLRequest, params: [String: Any] = [:], urlEncoding :URLEncoding? = nil, addAppKey : Bool = true) -> URLRequest {
        
        var dict = params
        if addAppKey {
        
            dict["appKey"] = "bemaverick_ios"
        
        }
   
        if let urlEncoding = urlEncoding {
            return try! urlEncoding.encode(request, with: dict)
        }
        
        return try! URLEncoding.default.encode(request, with: dict)
        
    }
    
    
    func encodedRequestJSON(_ request: URLRequest, params: [String: Any] = [:], addAppKey : Bool = true) -> URLRequest {
        
        let dict = params
        var urlRequest = try! JSONEncoding.default.encode(request, with: dict)
        
        if addAppKey {
            let parameters = ["appKey":"bemaverick_ios"]
            if var urlComponents = URLComponents(url: request.url!, resolvingAgainstBaseURL: false), !parameters.isEmpty {
                
                let percentEncodedQuery = (urlComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + "appKey=bemaverick_ios"
                urlComponents.percentEncodedQuery = percentEncodedQuery
                urlRequest.url = urlComponents.url
            
            }
            
        }
        
        return urlRequest
        
    }
    
    func encodedRequestHTTPBodyWithString(_ request: inout URLRequest, input: String) -> URLRequest  {
        
        if let data = input.data(using: String.Encoding.utf8) {
            request.httpBody = data
        }
        return request
        
    }
    
    
}
