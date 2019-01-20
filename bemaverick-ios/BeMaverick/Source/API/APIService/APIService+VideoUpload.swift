//
//  APIService+VideoUpload.swift
//  BeMaverick
//
//  Created by David McGraw on 9/14/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import Foundation
import AWSS3
import AWSCore
import SwiftMessages

/**
 Methods responsible for uploading content
 */
extension APIService {
    
    /**
    */
    open func setDefaultAWSServiceConfiguration() {
        
        if AWSServiceManager.default().defaultServiceConfiguration != nil {
            return
        }
        
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: globalModelsCoordinator.authorizationManager.accessKeyS3,
                                                               secretKey: globalModelsCoordinator.authorizationManager.secretKeyS3)
        
        let configuration = AWSServiceConfiguration(region: .USEast1,
                                                    credentialsProvider: credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
    }
    
    /**
     Cancel all active upload and download tasks with S3
    */
    open func cancelActiveUpload() {
        
        setDefaultAWSServiceConfiguration()
        
        let transferManager = AWSS3TransferManager.default()
        transferManager.cancelAll()
        
    }
    
    /**
     Performs an upload to S3 with the provided local path.
     
     - parameter url:           The local file path to upload
     - parameter name:          The name that'll be used on S3
     - parameter bucket:        The S3 bucket to upload to
     - parameter contentType:   The type of content beign uploaded
     */
    open func performUpload(withFileURL url: URL,
                            fileName name: String,
                            bucket: String = "bemaverick-input-videos",
                            contentType: String = "video/mp4",
                            isChallengeUpload : Bool = false,
                            completionHandler: @escaping VideoUploadCompletedClosure)
    {
        
        log.verbose("📥 Begin uploading file to S3 with the name \(name)")
        
        
        /// Set Configuration
        setDefaultAWSServiceConfiguration()
        
        /// Create Upload Request
        let request = AWSS3TransferManagerUploadRequest()!
        request.body = url
        request.key = name
        request.bucket = bucket
        request.contentType = contentType
        request.acl = .unknown
        request.uploadProgress = { (bytesSent, totalBytesSent, totalBytesExpectedToSend) in

            DispatchQueue.main.async {
                
                let progress = CGFloat(totalBytesSent) / CGFloat(totalBytesExpectedToSend)
                if !isChallengeUpload {
                    
                self.globalModelsCoordinator.onResponsesUploadProgressSignal.fire(progress * 50.0)
               
                } else {
             
                    self.globalModelsCoordinator.onChallengeUploadProgressSignal.fire(progress * 50.0)
               
                }
            }
            
        }
        
        AnalyticsManager.Post.trackPostServerCallStarted()
        
        let transferManager = AWSS3TransferManager.default()
        transferManager.upload(request).continueWith { task -> Any? in
            
            AnalyticsManager.Post.trackPostServerCallReturned()
            
            if let error = task.error {
                log.error("❌ Upload failed with error: \(error.localizedDescription)")
                completionHandler(MaverickError.recordingUploadFailureReason(reason: .unknownError(message: error.localizedDescription)))
            } else {
            
                if task.result != nil {
                    
                    let publicURL = AWSS3.default().configuration.endpoint.url?
                                            .appendingPathComponent(request.bucket!)
                                            .appendingPathComponent(request.key!)
                    
                    log.verbose("✅ Upload completed at destination: \(publicURL?.absoluteString ?? "")")
                    completionHandler(nil)
                    
                } else {
                    completionHandler(MaverickError.recordingUploadFailureReason(reason: .awsUploadError()))
                }

            }
            
            return nil
        
        }
        
    }
    
}
