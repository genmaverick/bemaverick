//
//  MaverickError.swift
//  BeMaverick
//
//  Created by David McGraw on 9/28/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation
import Alamofire

/**
 `MaverickError` represents a uniform representation of different errors a
 user can encounter.
 */
public enum MaverickError: Error {
    
    public enum ApiServiceFailureReason {
        
        case dataError(data: Data, error: Error?)
        
    }
    
    public enum AuthorizationFailureReason {
        
        case coppaFailedError()
        case coppaReviewError()
        case coppaRejectedError()
        case smsCodeInvalidError()
        
    }
    
    public enum RecordingUploadFailureReason {
        
        case awsUploadError()
        case moderationFail()
        case associateVideoError(message: String)
        case unknownError(message: String)
        
    }
    
    public enum RecordingEditorFailureReason {
        
        case glContextDrawingTextureError()
        case exceedsMaxTimeBoundary(secondsRemaining: Int)
        case exportSessionFailed()
        
    }
    
    public enum ShareFailureReason {
        
        case shareCanceledError()
        case loginCanceledError()
        case unknownError(message: String)
        
    }
    
    case apiServiceRequestFailed(reason: ApiServiceFailureReason)
    case authorizationFailureReason(reason: AuthorizationFailureReason)
    case recordingUploadFailureReason(reason: RecordingUploadFailureReason)
    case recordingEditorFailed(reason: RecordingEditorFailureReason)
    case shareFailed(reason: ShareFailureReason)
    case authenticationFailed
    
}

/**
 A quick boolean check to verify the error being worked with
 */
extension MaverickError {
    
    public var isApiServiceRequestFailed: Bool {
        if case .apiServiceRequestFailed = self { return true }
        return false
    }
    
}

/**
 Error Description
 */
extension MaverickError: LocalizedError {
    
    public var errorDescription: String? {
        
        switch self {
        case .apiServiceRequestFailed(let reason):
            return reason.localizedDescription
        case .authorizationFailureReason(let reason):
            return reason.localizedDescription
        case .recordingUploadFailureReason(let reason):
            return reason.localizedDescription
        case .recordingEditorFailed(let reason):
            return reason.localizedDescription
        case .shareFailed(let reason):
            return reason.localizedDescription
        case .authenticationFailed:
            return "There was a problem with your login"
        }
        
    }
    
    public var statusCode: Int {
        
        switch self {
        case .apiServiceRequestFailed(let reason):
            if let error = reason.underlyingError as? AFError, let code =  error.responseCode {
                return code
            } else {
                return -1
            }
        default:
            return -1
        }
        
    }
    
}

// MARK: - ApiServiceFailureReason Description Handling

extension MaverickError.ApiServiceFailureReason {
    
    var localizedDescription: String {
        
        switch self {
        case .dataError(let data, _):
            
            do {
                
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                
                if let dict = json as? [String: Any],
                    let errors = dict["errors"] as? [[String: Any]] {
                    
                    for error in errors {
                        
                        if let message = error["message"] as? String {
                            return message
                        }
                    }
                    
                }
                
            } catch {
                //
            }
            
            return ""
            
        }
        
    }
    
}

extension MaverickError.ApiServiceFailureReason {
    
    var underlyingError: Error? {
        
        switch self {
        case .dataError(_, let error):
            return error
        }
        
    }
    
}

// MARK: - AuthorizationFailureReason Description Handling

extension MaverickError.AuthorizationFailureReason {
    
    var localizedDescription: String {
        
        switch self {
        case .coppaFailedError():
            return "We couldn't verify your information. Please double check it and try again."
        case .coppaReviewError():
            return "Please check your SSN and try again."
        case .coppaRejectedError():
            return "Please contact customer support at \(Constants.MaverickSupportEmail)"
        case .smsCodeInvalidError():
            return "The code provided is invalid. Please double check it and try again."
        }
        
    }
    
}

// MARK: - RecordingUploadFailureReason Description Handling

extension MaverickError.RecordingUploadFailureReason {
    
    var localizedDescription: String {
        
        switch self {
        case .awsUploadError():
            return "S3 Upload Error. Invalid Result."
        case .associateVideoError(let message):
            return "Failed to associate the video. \(message)"
        case .moderationFail():
            return "\n\nThanks for posting! we are taking a look at it now and will let you know when it is available to view!"
        case .unknownError(let message):
            return "Upload issue! \(message)"
        }
        
    }
    
}

// MARK: - RecordingEditorFailureReason Description Handling

extension MaverickError.RecordingEditorFailureReason {
    
    var localizedDescription: String {
        
        switch self {
        case .glContextDrawingTextureError():
            return "Cannot bind texture to nil or a context other than gl context"
        case .exceedsMaxTimeBoundary(let secondsRemaining):
            return "Your video must be 30 seconds or less. Please trim your video before selecting ‘Done’."
        case .exportSessionFailed():
            return "Unable to create a session for the selected asset"
        }
        
    }
    
}

// MARK: - ShareFailureReason Description Handling

extension MaverickError.ShareFailureReason {
    
    var localizedDescription: String {
        
        switch self {
        case .shareCanceledError():
            return "Share canceled"
        case .loginCanceledError():
            return "Canceled login"
        case .unknownError(let message):
            return "Unable to share. Please try again. \(message)"
        }
        
    }
    
}


