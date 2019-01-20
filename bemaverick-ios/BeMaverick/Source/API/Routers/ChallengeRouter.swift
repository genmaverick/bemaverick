//
//  ChallengeRouter.swift
//  BeMaverick
//
//  Created by David McGraw on 9/14/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Alamofire

enum ChallengeRouter: URLRequestConvertible {
    
    /// Get created user challenges
    case getUserCreatedChallenges(userId: String, count: Int, offset: Int)
    
    
    /// Get available challenges
    case getChallenges(count: Int, offset: Int, status: String, sort: String, featuredType: Constants.ChallengeFeaturedType)
    
    case getChallengeById(challengeId : String)
    
    case getNoResponseChallenges(minHours : Int, count: Int, offset : Int)
    
    case getMyRespondedChallenges( count: Int, offset : Int)
    
    case getLinkChallenges( count: Int, offset : Int)
    
    
    case getMyInvitedChallenges( count: Int, offset : Int)
    
    case getTrendingChallenges(versionNumber : Int, count: Int, offset: Int)
    
    /// Get the responses for a challenge
    case getResponses(id: String, count: Int, offset: Int)
    
    /// Submit a response to the challenge
    case submitResponse(id: String, type: String, filename: String,  description: String, coverImageData: Data?, coverImageFileName: String?)
    
    /// Submit a response to the challenge
    case submitPost(type: String, filename: String, description: String, coverImageData: Data?, coverImageFileName: String?)
    
    /// Submit a response to the challenge
    case submitChallenge(type: String, filename: String, title: String?, description: String?, mentions: String?, coverImageData: Data?, imageText : String?, linkUrl : String?)
    
    /// Deletes a challenge tied to the authorized user's account
    case deleteChallenge(challengeId: Int)
    
    // MARK: - Method
    case editChallenge(challengeId : String, title: String?, description: String?,  mentions: String?, linkUrl : String?)
    
    /// Marks a user unowned response as reported
    case reportChallenge(challengeId: String, reason: String)
    
    
    var method: HTTPMethod {
        
        switch self {
        case .reportChallenge(_,_):
            return .post
        case .getUserCreatedChallenges:
            return .get
        case .getLinkChallenges:
            return .get
            
        case .getChallenges:
            return .get
        case .getResponses:
            return .get
        case .submitResponse:
            return .post
        case .submitPost:
            return .post
        case .submitChallenge:
            return .post
        case .deleteChallenge:
            return .post
        case .getChallengeById:
            return .get
        case .editChallenge:
            return .post
        case .getNoResponseChallenges:
            return .get
            
        case .getMyRespondedChallenges:
            return .get
            
        case .getMyInvitedChallenges:
            return .get
            
        case .getTrendingChallenges:
            return .get
        }
        
    }
    
    // MARK: - Path
    
    var path: String {
        
        switch self {
            
        case .getLinkChallenges(_,_):
            return "/site/challenges"
            
            
        case .getUserCreatedChallenges:
            return "/site/challenges"
            
        case .getNoResponseChallenges(_,_,_):
            return "/site/challenges"
            
        case .getMyRespondedChallenges(_,_):
            return "/site/challenges"
            
        case .getMyInvitedChallenges(_,_):
            return "/site/challenges"
            
        case .getTrendingChallenges(_, _,_):
            return "/site/challenges"
            
        case .reportChallenge(_,_):
            return "/challenge/flag"
            
        case .getChallenges(_, _, _, _, _):
            return "/site/challenges"
            
        case .getResponses(_, _, _):
            return "/challenge/responses"
            
        case .getChallengeById(_):
            return "/challenge/details"
            
        case .submitResponse(_, _, _, _, _, _):
            return "/challenge/addresponse"
            
        case .submitPost(_, _, _, _, _):
            return "/response/add"
            
        case .submitChallenge(_, _, _, _, _, _, _, _):
            return "/challenge/add"
            
        case .deleteChallenge(_):
            return "/challenge/delete"
            
        case .editChallenge(_, _, _, _, _):
            return "/challenge/edit"
            
        }
        
    }
    
    // MARK: - URL
    
    func asURLRequest() throws -> URLRequest {
        
        var urlRequest = baseURLRequest(with: path, httpMethod: method.rawValue)
        
        switch self {
            
        case .getLinkChallenges(let count, let offset) :
            let req = encodedRequestURL(urlRequest, params: [ "count": count, "offset": offset, "sort": "created", "hasLinkUrl":"true"])
              print("🕸 getLinkChallenges: \(req.url?.absoluteURL.absoluteString ?? "N/A")")
            return req
            
        case .getUserCreatedChallenges(let userId, let count, let offset):
            
            let req = encodedRequestURL(urlRequest, params: ["userId" : userId, "count" : count, "offset" : offset, "sort":"created"])
            print("🕸 getUserCreatedChallenges: \(req.url?.absoluteURL.absoluteString ?? "N/A")")
            
            return req
            
            
        case .reportChallenge(let challengeId, let reason):
            return encodedRequestURL(urlRequest, params: ["challengeId": challengeId, "reason" : reason])
            
            
        case .getChallengeById(let challengeId):
            return encodedRequestURL(urlRequest, params: ["challengeId": challengeId])
            
        case .getMyRespondedChallenges(let count, let offset) :
            
            let req = encodedRequestURL(urlRequest, params: [ "count": count, "offset": offset, "sort": "created", "responseUserId":"me"])
            print("🕸 getMyRespondedChallenges request: \(req.url?.absoluteURL.absoluteString ?? "N/A")")
            return req
            
        case .getMyInvitedChallenges(let count, let offset) :
            
            let req = encodedRequestURL(urlRequest, params: [ "count": count, "offset": offset, "sort": "created", "mentionedUserId":"me"])
            print("🕸 getMyInvitedChallenges with cover request: \(req.url?.absoluteURL.absoluteString ?? "N/A")")
            return req
            
            
        case .getTrendingChallenges(let version, let count, let offset) :
            
            var sortParam = "trending"
            if version != 0 {
                sortParam = "\(sortParam)_v\(version)"
            }
            let req = encodedRequestURL(urlRequest, params: [ "count": count, "offset": offset, "sort": sortParam])
            print("🕸 getTrendingChallenges version \(version): \(req.url?.absoluteURL.absoluteString ?? "N/A")")
            return req
            
        case .getNoResponseChallenges(let minHours, let count, let offset):
            return encodedRequestURL(urlRequest, params: [ "count": count, "offset": offset, "sort": "created", "minimumHours":minHours, "hasResponse":"false" ])
            
        case .getChallenges(let count, let offset, let status, let sort, let featuredType):
             let req = encodedRequestURL(urlRequest, params: ["count": count, "offset": offset, "status": status, "sort": sort, "sortOrder":"asc", "featuredType":featuredType.rawValue])
             print("🕸 getChallenges: \(req.url?.absoluteURL.absoluteString ?? "N/A")")
             return req
            
        case .getResponses(let id, let count, let offset):
            return encodedRequestURL(urlRequest, params: ["challengeId": id, "count": count, "offset": offset])
            
        case .submitResponse(let id, let type, let filename, let description, let coverImageData, let coverImageFileName):
            
            var params = ["challengeId": id,
                          "responseType": type,
                          "filename": filename,
                          
                          "postType": "response",
                          "description": description,
                          "width": Constants.CameraManagerExportSize.width,
                          "height": Constants.CameraManagerExportSize.height] as [String : Any]
            
            
            if let coverImagefileName = coverImageFileName {
                
                params["coverImageFileName"] = coverImageFileName
                
            } else if let data = coverImageData {
                
                urlRequest.setValue("multipart/form-data; charset=utf-8; boundary=__IOS_BOUNDARY__", forHTTPHeaderField: "Content-Type")
                urlRequest.httpBody = bodyImageDataUploadRequest(withData: data, forParameterName: "coverImage")
                
                
                let req = encodedRequestURL(urlRequest, params: params, urlEncoding: URLEncoding.init(destination: URLEncoding.Destination.queryString))
                print("🕸 upload response with cover request: \(req.url?.absoluteURL.absoluteString ?? "N/A")")
                return req
                
            }
            let req = encodedRequestURL(urlRequest, params: params, urlEncoding: URLEncoding.init(destination: URLEncoding.Destination.queryString))
            print("🕸 upload response without cover request: \(req.url?.absoluteURL.absoluteString ?? "N/A")")
            return req
            
        case .submitPost(let type, let filename, let description, let coverImageData, let coverImageFileName):
            
            var params = [
                
                "responseType": type,
                "filename": filename,
                "postType": "content",
                "description": description,
                "width": Constants.CameraManagerExportSize.width,
                "height": Constants.CameraManagerExportSize.height] as [String : Any]
            
           
            if let coverImageFileName = coverImageFileName {
                
                params["coverImageFileName"] = coverImageFileName
                
            } else if let data = coverImageData {
                
                urlRequest.setValue("multipart/form-data; charset=utf-8; boundary=__IOS_BOUNDARY__", forHTTPHeaderField: "Content-Type")
                urlRequest.httpBody = bodyImageDataUploadRequest(withData: data, forParameterName: "coverImage")
                
                return encodedRequestURL(urlRequest, params: params, urlEncoding: URLEncoding.init(destination: URLEncoding.Destination.queryString))
                
            }
            
             let req = encodedRequestURL(urlRequest, params: params, urlEncoding: URLEncoding.init(destination: URLEncoding.Destination.queryString))
            print("🕸 upload content with no cover request: \(req.url?.absoluteURL.absoluteString ?? "N/A")")
            return req
            
            
        case .editChallenge(let challengeId, let title, let description, let mentions, let linkUrl):
            
            var params = ["challengeId":challengeId]
            
            var description = description ?? " "
            if description.isEmpty {
               description = " "
            }
            params["description"] =  description
            
            var title = title ?? " "
            if title.isEmpty {
                title = " "
            }
            params["title"] =  title
            
            if let mentions = mentions {
                
                params["mentions"] =  mentions
                
            }
            
            params["linkUrl"] =  linkUrl ?? ""
               
            let req = encodedRequestURL(urlRequest, params: params, urlEncoding: URLEncoding.init(destination: URLEncoding.Destination.queryString))
            print("🕸 edditing challenge request: \(req.url?.absoluteURL.absoluteString ?? "N/A")")
            return req
            
        
            
        case .submitChallenge(let type, let filename, let title,  let description, let mentions, let coverImageData, let imageText, let linkUrl):
            
            var params = ["challengeType": type,
                          "filename": filename,
                          
                          "width": Constants.CameraManagerExportSize.width,
                          "height": Constants.CameraManagerExportSize.height] as [String : Any]
            
            
            if let title = title {
                
                params["title"] =  title
                
            }
            
            if let linkUrl = linkUrl {
                
                params["linkUrl"] =  linkUrl
                
            }
            

            if let imageText = imageText {
                
                params["imageText"] =  imageText
                
            }

            
            if let description = description {
                
                params["description"] =  description
                
            }
            
            if let mentions = mentions {
                
                params["mentions"] = mentions
                
            }
            
            if let data = coverImageData {
                
                urlRequest.setValue("multipart/form-data; charset=utf-8; boundary=__IOS_BOUNDARY__", forHTTPHeaderField: "Content-Type")
                urlRequest.httpBody = bodyImageDataUploadRequest(withData: data, forParameterName: "coverImage")
                
            }
            let req = encodedRequestURL(urlRequest, params: params, urlEncoding: URLEncoding.init(destination: URLEncoding.Destination.queryString))
            print("🕸 upload challenge request: \(req.url?.absoluteURL.absoluteString ?? "N/A")")
            return req
            
        case .deleteChallenge(let challengeId):
            return encodedRequestURL(urlRequest, params: ["challengeId": challengeId])
            
        }
        
    }
    
    // MARK: - Private Methods
    
    /**
     Generate a multi-part data object that can be applied to a URL request
     
     - parameter data: The image data to use
     - parameter name: The endpoint name for the request
     */
    fileprivate func bodyImageDataUploadRequest(withData data: Data, forParameterName name: String) -> Data {
        
        let randomFilename = "iOS_videoCover_" +
            UUID().uuidString + "_" +
            String(Int(Date().timeIntervalSince1970)) + ".jpg"
        
        let contentDispositionString = "Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(randomFilename)\"\r\n"
        let contentTypeString = "Content-Type: image/jpeg\r\n\r\n"
        
        let boundaryStart = "--__IOS_BOUNDARY__\r\n"
        let boundaryEnd = "--__IOS_BOUNDARY__\r\n"
        
        let bodyData: NSMutableData = NSMutableData()
        bodyData.append(boundaryStart.data(using: .utf8)!)
        bodyData.append(contentDispositionString.data(using: .utf8)!)
        bodyData.append(contentTypeString.data(using: .utf8)!)
        bodyData.append(data)
        bodyData.append("\r\n".data(using: .utf8)!)
        bodyData.append(boundaryEnd.data(using: .utf8)!)
        
        return bodyData as Data
        
    }
    
}
