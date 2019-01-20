//
//  AnalyticsOnboarding.swift
//  BeMaverick
//
//  Created by Garrett Fritz on 2/5/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//


extension AnalyticsManager {
    
     class Post {
        
        
        /* Post */
        
        static func trackPostSuccess(responseId: String, responseType: Constants.UploadResponseType, challengeId : String?) {
            
            var properties = createBasicPropertyDictionary(responseType: responseType, challengeId: challengeId)
            
            properties[Constants.Analytics.Main.Properties.ID] = responseId
        
            trackEvent(Constants.Analytics.Post.Events.POST_SUCCESS, withProperties: properties)
            
        }
        
        static func trackPostFail(responseType: Constants.UploadResponseType, challengeId: String?, postFailureError: Constants.Analytics.Post.Properties.POST_FAILURE_REASON, errorMesssage: String? = nil) {
            
            var properties = createBasicPropertyDictionary(responseType: responseType, challengeId: challengeId)
            
            properties[Constants.Analytics.Post.Properties.POST_FAILURE_REASON.key.rawValue] = postFailureError.rawValue
            
            if let err = errorMesssage {
                properties["Error Message"] = err
            }
            
            trackEvent(Constants.Analytics.Post.Events.POST_FAIL, withProperties: properties)
            
        }
        
        static func trackPostServerCallStarted() {
            trackEvent(Constants.Analytics.Post.Events.POST_SERVER_CALL_STARTED)
        }
        
        static func trackPostServerCallReturned() {
            trackEvent(Constants.Analytics.Post.Events.POST_SERVER_CALL_RETURNED)
        }
        

        /* Camera */

        static func trackCameraFlashPressed(responseType: Constants.UploadResponseType, challengeId: String?, flashState: Constants.Analytics.Post.Properties.FLASH_STATE) {
            
            var properties = createBasicPropertyDictionary(responseType: responseType, challengeId: challengeId)
            
            properties[Constants.Analytics.Post.Properties.FLASH_STATE.key.rawValue] = flashState.rawValue
            
            trackEvent(Constants.Analytics.Post.Events.CAMERA_FLASH_PRESSED, withProperties: properties)
            
        }

        static func trackCameraFlipPressed(responseType: Constants.UploadResponseType, challengeId: String?, cameraFlipState: Constants.Analytics.Post.Properties.CAPTURE_DEVICE_POSITION) {
            
            var properties = createBasicPropertyDictionary(responseType: responseType, challengeId: challengeId)
            
            properties[Constants.Analytics.Post.Properties.CAPTURE_DEVICE_POSITION.key.rawValue] = cameraFlipState.rawValue
            
            trackEvent(Constants.Analytics.Post.Events.CAMERA_FLIP_PRESSED, withProperties: properties)
            
        }

        static func trackCameraTimerPressed(responseType: Constants.UploadResponseType, challengeId: String?, timerState: Constants.Analytics.Post.Properties.TIMER_STATE) {
            
            var properties = createBasicPropertyDictionary(responseType: responseType, challengeId: challengeId)
            
            properties[Constants.Analytics.Post.Properties.TIMER_STATE.key.rawValue] = timerState.rawValue
            
            trackEvent(Constants.Analytics.Post.Events.CAMERA_TIMER_PRESSED, withProperties: properties)
            
        }

        static func trackCameraCancelTimerPressed(responseType: Constants.UploadResponseType, challengeId: String?) {
            
            let properties = createBasicPropertyDictionary(responseType: responseType, challengeId: challengeId)
            
            trackEvent(Constants.Analytics.Post.Events.CAMERA_CANCEL_TIMER_PRESSED, withProperties: properties)
            
        }

        static func trackCameraTabPressed(responseType: Constants.UploadResponseType, challengeId: String?, mediaTypePressed: Constants.Analytics.Main.Properties.MEDIA_TYPE) {
            
            var properties = createBasicPropertyDictionary(responseType: responseType, challengeId: challengeId)
            
            properties[Constants.Analytics.Main.Properties.TAB_INDEX] = mediaTypePressed.rawValue
            
            trackEvent(Constants.Analytics.Post.Events.CAMERA_TAB_PRESSED, withProperties: properties)
            
        }

        static func trackCameraLibraryPressed(responseType: Constants.UploadResponseType, challengeId: String?) {
            
            let properties = createBasicPropertyDictionary(responseType: responseType, challengeId: challengeId)
            
            trackEvent(Constants.Analytics.Post.Events.CAMERA_LIBRARY_PRESSED, withProperties: properties)
            
        }

        static func trackCameraRecordPressed(responseType: Constants.UploadResponseType, challengeId: String?, flashState: Constants.Analytics.Post.Properties.FLASH_STATE, cameraFlipState: Constants.Analytics.Post.Properties.CAPTURE_DEVICE_POSITION, timerState: Constants.Analytics.Post.Properties.TIMER_STATE) {
            
            var properties = createBasicPropertyDictionary(responseType: responseType, challengeId: challengeId)
            
            properties[Constants.Analytics.Post.Properties.FLASH_STATE.key.rawValue] = flashState.rawValue
            properties[Constants.Analytics.Post.Properties.CAPTURE_DEVICE_POSITION.key.rawValue] = cameraFlipState.rawValue
            properties[Constants.Analytics.Post.Properties.TIMER_STATE.key.rawValue] = timerState.rawValue
            
            trackEvent(Constants.Analytics.Post.Events.CAMERA_RECORD_PRESSED, withProperties: properties)
            
        }

        static func trackCameraStopPressed(responseType: Constants.UploadResponseType, challengeId: String?) {
            
            let properties = createBasicPropertyDictionary(responseType: responseType, challengeId: challengeId)
            
            trackEvent(Constants.Analytics.Post.Events.CAMERA_STOP_PRESSED, withProperties: properties)
            
        }

        static func trackCameraNextPressed(responseType: Constants.UploadResponseType, challengeId: String?) {
            
            let properties = createBasicPropertyDictionary(responseType: responseType, challengeId: challengeId)
            
            trackEvent(Constants.Analytics.Post.Events.CAMERA_NEXT_PRESSED, withProperties: properties)
            
        }

        static func trackCameraBackPressed(responseType: Constants.UploadResponseType, challengeId: String?, sessionState: Constants.Analytics.Post.Properties.SESSION_STATE) {
            
            var properties = createBasicPropertyDictionary(responseType: responseType, challengeId: challengeId)
            
            properties[Constants.Analytics.Post.Properties.SESSION_STATE.key.rawValue] = sessionState.rawValue
            
            trackEvent(Constants.Analytics.Post.Events.CAMERA_BACK_PRESSED, withProperties: properties)
            
        }
  
        static func trackCameraSaveDraftPressed(responseType: Constants.UploadResponseType, challengeId: String?, challengeTitle : String?) {
            
            var properties = createBasicPropertyDictionary(responseType: responseType, challengeId: challengeId)
            
            if let challengeTitle = challengeTitle {
              
                properties[Constants.Analytics.Main.Properties.CHALLENGE_TITLE] = challengeTitle
          
            }
            
            trackEvent(Constants.Analytics.Post.Events.CAMERA_SAVE_DRAFT_PRESSED, withProperties: properties)
            
        }

        static func trackCameraStartOverPressed(responseType: Constants.UploadResponseType, challengeId: String?) {
            
            let properties = createBasicPropertyDictionary(responseType: responseType, challengeId: challengeId)
            
            trackEvent(Constants.Analytics.Post.Events.CAMERA_START_OVER_PRESSED, withProperties: properties)
            
        }
   
        static func trackCameraCancelPressed(responseType: Constants.UploadResponseType, challengeId: String?) {
            
            let properties = createBasicPropertyDictionary(responseType: responseType, challengeId: challengeId)
            
            trackEvent(Constants.Analytics.Post.Events.CAMERA_CANCEL_PRESSED, withProperties: properties)
            
        }
        
        
        /* Asset Picker */

        static func trackAssetPickerBackPressed(responseType: Constants.UploadResponseType, challengeId: String?) {
            
            let properties = createBasicPropertyDictionary(responseType: responseType, challengeId: challengeId)
            
            trackEvent(Constants.Analytics.Post.Events.ASSET_PICKER_BACK_PRESSED, withProperties: properties)
            
        }
        
        
        static func trackAssetPickerAssetSelected(responseType: Constants.UploadResponseType, challengeId: String?, retrievalResult: Constants.Analytics.Post.Properties.ASSET_RETRIEVAL) {
            
            var properties = createBasicPropertyDictionary(responseType: responseType, challengeId: challengeId)
            
            properties[Constants.Analytics.Post.Properties.ASSET_RETRIEVAL.key.rawValue] = retrievalResult.rawValue
            
            trackEvent(Constants.Analytics.Post.Events.ASSET_PICKER_ASSET_SELECTED, withProperties: properties)
            
        }
        
        
        /* Edit */

        static func trackEditTabPressed(responseType: Constants.UploadResponseType, challengeId: String?, tabSelected: Constants.Analytics.Post.Properties.EDIT_TAB_SELECTION_STATE) {
            
            var properties = createBasicPropertyDictionary(responseType: responseType, challengeId: challengeId)
            
            properties[Constants.Analytics.Post.Properties.EDIT_TAB_SELECTION_STATE.key.rawValue] = tabSelected.rawValue
            
            trackEvent(Constants.Analytics.Post.Events.EDIT_TAB_PRESSED, withProperties: properties)
            
        }

        static func trackEditUndoPressed(responseType: Constants.UploadResponseType, challengeId: String?) {
            
            let properties = createBasicPropertyDictionary(responseType: responseType, challengeId: challengeId)
            
            trackEvent(Constants.Analytics.Post.Events.EDIT_UNDO_PRESSED, withProperties: properties)
            
        }

        static func trackEditPlayPressed(responseType: Constants.UploadResponseType, challengeId: String?) {
            
            let properties = createBasicPropertyDictionary(responseType: responseType, challengeId: challengeId)
            
            trackEvent(Constants.Analytics.Post.Events.EDIT_PLAY_PRESSED, withProperties: properties)
            
        }

        static func trackEditPausePressed(responseType: Constants.UploadResponseType, challengeId: String?) {
            
            let properties = createBasicPropertyDictionary(responseType: responseType, challengeId: challengeId)
            
            trackEvent(Constants.Analytics.Post.Events.EDIT_PAUSE_PRESSED, withProperties: properties)
            
        }

        static func trackEditFilterSelected(responseType: Constants.UploadResponseType, challengeId: String?, filterName: String) {
            
            var properties = createBasicPropertyDictionary(responseType: responseType, challengeId: challengeId)
            
            properties[Constants.Analytics.Post.Properties.FILTER_NAME] = filterName
            
            trackEvent(Constants.Analytics.Post.Events.EDIT_FILTER_SELECTED, withProperties: properties)
            
        }

        static func trackEditStickerSelected(responseType: Constants.UploadResponseType, challengeId: String?, stickerName: String) {
            
            var properties = createBasicPropertyDictionary(responseType: responseType, challengeId: challengeId)
            
            properties[Constants.Analytics.Post.Properties.STICKER_NAME] = stickerName
            
            trackEvent(Constants.Analytics.Post.Events.EDIT_STICKER_SELECTED, withProperties: properties)
            
        }

        static func trackEditPenSelected(responseType: Constants.UploadResponseType, challengeId: String?, brushType: Constants.RecordingBrushType, brushSize: Constants.RecordingBrushSize, brushColor: UIColor) {
            
            var properties = createBasicPropertyDictionary(responseType: responseType, challengeId: challengeId)
            
            let editBrushType: String = {
                
                switch brushType {
                    
                case .brush:
                    return Constants.Analytics.Post.Properties.EDIT_BRUSH_TYPE.brush.rawValue
                case .pencil:
                    return Constants.Analytics.Post.Properties.EDIT_BRUSH_TYPE.pencil.rawValue
                case .erase:
                    return Constants.Analytics.Post.Properties.EDIT_BRUSH_TYPE.erase.rawValue
                }
                
            }()
            
            let editBrushSize: String = {
                
                switch brushSize {
                    
                case .size1:
                    return Constants.Analytics.Post.Properties.EDIT_BRUSH_SIZE.size1.rawValue
                case .size2:
                    return Constants.Analytics.Post.Properties.EDIT_BRUSH_SIZE.size2.rawValue
                case .size3:
                    return Constants.Analytics.Post.Properties.EDIT_BRUSH_SIZE.size3.rawValue
                case .size4:
                    return Constants.Analytics.Post.Properties.EDIT_BRUSH_SIZE.size4.rawValue
                case .size5:
                    return Constants.Analytics.Post.Properties.EDIT_BRUSH_SIZE.size5.rawValue
                case .size6:
                    return Constants.Analytics.Post.Properties.EDIT_BRUSH_SIZE.size6.rawValue
                    
                }
            
            }()
            
            let brushColorAsHexString: String = {
                
                if let stringVersion = brushColor.hexString {
                    return stringVersion
                } else {
                    return "ERROR"
                }
                
            }()
            
            properties[Constants.Analytics.Post.Properties.EDIT_BRUSH_TYPE.key.rawValue] = editBrushType
            properties[Constants.Analytics.Post.Properties.EDIT_BRUSH_SIZE.key.rawValue] = editBrushSize
            properties[Constants.Analytics.Post.Properties.BRUSH_COLOR] = brushColorAsHexString
            
            trackEvent(Constants.Analytics.Post.Events.EDIT_PEN_SELECTED, withProperties: properties)
            
        }

        static func trackEditTextSelected(responseType: Constants.UploadResponseType, challengeId: String?, fontName: UIFont, fontColor: UIColor) {
            
            var properties = createBasicPropertyDictionary(responseType: responseType, challengeId: challengeId)
            
            let textColorAsHexString: String = {
                
                if let stringVersion = fontColor.hexString {
                    return stringVersion
                } else {
                    return "ERROR"
                }
                
            }()
            
            properties[Constants.Analytics.Post.Properties.FONT_NAME] = fontName.fontName
            properties[Constants.Analytics.Post.Properties.FONT_COLOR] = textColorAsHexString
            
            trackEvent(Constants.Analytics.Post.Events.EDIT_TEXT_SELECTED, withProperties: properties)
            
        }
        
        static func trackEditNextPressed(responseType: Constants.UploadResponseType, challengeId: String?) {
            
            let properties = createBasicPropertyDictionary(responseType: responseType, challengeId: challengeId)
            
            trackEvent(Constants.Analytics.Post.Events.EDIT_NEXT_PRESSED, withProperties: properties)
            
        }
  
        static func trackEditBackPressed(responseType: Constants.UploadResponseType, challengeId: String?) {
            
            let properties = createBasicPropertyDictionary(responseType: responseType, challengeId: challengeId)
            
            trackEvent(Constants.Analytics.Post.Events.EDIT_BACK_PRESSED, withProperties: properties)
            
        }
        
        
        /* Trimmer */

        static func trackTrimmerBackPressed(challengeId: String?, mediaType : Constants.UploadResponseType) {
            
            let properties = createBasicPropertyDictionary(responseType: .video, challengeId: challengeId)
            
            trackEvent(Constants.Analytics.Post.Events.TRIMMER_BACK_PRESSED, withProperties: properties)
            
        }
     
        static func trackTrimmerDonePressed(challengeId: String?, mediaType : Constants.UploadResponseType) {
            
            let properties = createBasicPropertyDictionary(responseType: .video, challengeId: challengeId)
            
            trackEvent(Constants.Analytics.Post.Events.TRIMMER_DONE_PRESSED, withProperties: properties)
            
        }
        
        static func trackTrimmerPlayPressed(challengeId: String?) {
            
            let properties = createBasicPropertyDictionary(responseType: .video, challengeId: challengeId)
            
            trackEvent(Constants.Analytics.Post.Events.TRIMMER_PLAY_PRESSED, withProperties: properties)
            
        }
        
        static func trackTrimmerPausePressed(challengeId: String?) {
            
            let properties = createBasicPropertyDictionary(responseType: .video, challengeId: challengeId)
            
            trackEvent(Constants.Analytics.Post.Events.TRIMMER_PAUSE_PRESSED, withProperties: properties)
            
        }
        
        static func trackTrimmerNextPressed(challengeId: String?) {
            
            let properties = createBasicPropertyDictionary(responseType: .video, challengeId: challengeId)
            
            trackEvent(Constants.Analytics.Post.Events.TRIMMER_NEXT_PRESSED, withProperties: properties)
            
        }
        
        static func trackTrimmerPreviousPressed(challengeId: String?) {
            
            let properties = createBasicPropertyDictionary(responseType: .video, challengeId: challengeId)
            
            trackEvent(Constants.Analytics.Post.Events.TRIMMER_PREVIOUS_PRESSED, withProperties: properties)
            
        }
        
        static func trackTrimmerDeletePressed(challengeId: String?) {
            
            let properties = createBasicPropertyDictionary(responseType: .video, challengeId: challengeId)
            
            trackEvent(Constants.Analytics.Post.Events.TRIMMER_DELETE_PRESSED, withProperties: properties)
            
        }
        
        static func trackTrimmerReplayPressed(challengeId: String?) {
            
            let properties = createBasicPropertyDictionary(responseType: .video, challengeId: challengeId)
            
            trackEvent(Constants.Analytics.Post.Events.TRIMMER_REPLAY_PRESSED, withProperties: properties)
            
        }
        
        
        /* Details */

        static func trackDetailsBackPressed(responseType: Constants.UploadResponseType, challengeId: String?) {
            
            let properties = createBasicPropertyDictionary(responseType: responseType, challengeId: challengeId)
            
            trackEvent(Constants.Analytics.Post.Events.DETAILS_BACK_PRESSED, withProperties: properties)
            
        }

        static func trackDetailsChangeCoverPressed(responseType: Constants.UploadResponseType, challengeId: String?) {
            
            let properties = createBasicPropertyDictionary(responseType: responseType, challengeId: challengeId)
            
            trackEvent(Constants.Analytics.Post.Events.DETAILS_CHANGE_COVER_PRESSED, withProperties: properties)
            
        }

        static func trackDetailsDescriptionEntryStarted(responseType: Constants.UploadResponseType, challengeId: String?) {
            
            let properties = createBasicPropertyDictionary(responseType: responseType, challengeId: challengeId)
            
            trackEvent(Constants.Analytics.Post.Events.DETAILS_DESCRIPTION_ENTRY_STARTED, withProperties: properties)
            
        }
        
        static func trackDetailsSavePressed(responseType: Constants.UploadResponseType, challengeId: String?, hasTags: Bool, hasDescription: Bool) {
            
            var properties = createBasicPropertyDictionary(responseType: responseType, challengeId: challengeId)
            
            properties[Constants.Analytics.Post.Properties.HAS_TAGS] = hasTags ? "True" : "False"
            properties[Constants.Analytics.Post.Properties.HAS_DESCRIPTION] = hasDescription ? "True" : "False"
            
            trackEvent(Constants.Analytics.Post.Events.DETAILS_SAVE_PRESSED, withProperties: properties)
            
        }
        
        
        /* Cover Selector */
        
        static func trackCoverSelectorBackPressed(responseType: Constants.UploadResponseType, challengeId: String?, touchedState: Constants.Analytics.Post.Properties.COVER_SELECTOR_TOUCHED_PREVIEW_STATE) {
            
            var properties = createBasicPropertyDictionary(responseType: responseType, challengeId: challengeId)
            
            properties[Constants.Analytics.Post.Properties.COVER_SELECTOR_TOUCHED_PREVIEW_STATE.key.rawValue] = touchedState.rawValue
            
            trackEvent(Constants.Analytics.Post.Events.COVER_SELECTOR_BACK_PRESSED, withProperties: properties)
            
        }
        
        static func trackCoverSelectorSavePressed(responseType: Constants.UploadResponseType, challengeId: String?, touchedState: Constants.Analytics.Post.Properties.COVER_SELECTOR_TOUCHED_PREVIEW_STATE) {
            
            var properties = createBasicPropertyDictionary(responseType: responseType, challengeId: challengeId)
            
            properties[Constants.Analytics.Post.Properties.COVER_SELECTOR_TOUCHED_PREVIEW_STATE.key.rawValue] = touchedState.rawValue
            
            trackEvent(Constants.Analytics.Post.Events.COVER_SELECTOR_SAVE_PRESSED, withProperties: properties)
            
        }
        
        
        /* Upload */
        
        static func trackUploadPressed(responseType: Constants.UploadResponseType, challengeId: String?, hasTags: Bool, hasDescription: Bool, hasMultipleSegments: Bool? = nil, hasStickers: Bool, stickerNames: [String]?, hasText: Bool, hasDoodle: Bool, hasFilter: Bool, length: Float64? = nil) {
            
            var properties = createBasicPropertyDictionary(responseType: responseType, challengeId: challengeId)
            
            if let strongHasMultipleSegments = hasMultipleSegments {
                properties[Constants.Analytics.Post.Properties.HAS_MULTIPLE_SEGMENTS] = strongHasMultipleSegments ? "True" : "False"
            }
            
            properties[Constants.Analytics.Post.Properties.HAS_STICKERS] = hasStickers ? "True" : "False"
            
            if let stickerNames = stickerNames {
                properties[Constants.Analytics.Post.Properties.STICKER_NAMES] = stickerNames
            }
            
            properties[Constants.Analytics.Post.Properties.HAS_TEXT] = hasText ? "True" : "False"
            properties[Constants.Analytics.Post.Properties.HAS_DOODLE] = hasDoodle ? "True" : "False"
            properties[Constants.Analytics.Post.Properties.HAS_FILTER] = hasFilter ? "True" : "False"
            
            if let strongLength = length {
                properties[Constants.Analytics.Post.Properties.UPLOAD_VIDEO_LENGTH] = String(format: "%.2f", strongLength)
            }
            
            properties[Constants.Analytics.Post.Properties.HAS_TAGS] = hasTags ? "True" : "False"
            properties[Constants.Analytics.Post.Properties.HAS_DESCRIPTION] = hasDescription ? "True" : "False"
            
            trackEvent(Constants.Analytics.Post.Events.UPLOAD_PRESSED, withProperties: properties)
            
        }
        
    }
 
}



fileprivate func createBasicPropertyDictionary(responseType: Constants.UploadResponseType, challengeId: String?) -> [String:Any] {
    
    var properties: [String:Any] =
        [Constants.Analytics.Main.Properties.CONTENT_TYPE.key.rawValue: challengeId == nil ? Constants.Analytics.Main.Properties.CONTENT_TYPE.content.rawValue : Constants.Analytics.Main.Properties.CONTENT_TYPE.response.rawValue,
        ]
   
    if let challengeId = challengeId {
    
        properties[Constants.Analytics.Main.Properties.CHALLENGE_ID] = challengeId
    
    }
   
    properties[Constants.Analytics.Main.Properties.MEDIA_TYPE.key.rawValue] = responseType == .video ? Constants.Analytics.Main.Properties.MEDIA_TYPE.video.rawValue : Constants.Analytics.Main.Properties.MEDIA_TYPE.image.rawValue
    
    return properties
    
}
