//
//  CameraManager+State.swift
//  BeMaverick
//
//  Created by David McGraw on 2/9/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import SCRecorder

extension CameraManager {
    
    /**
     Find a saved session with the provided ID and remove the content on disk
    */
    static func removeSavedData(forSessionId identifier: String) {
        
        let sessions = UserDefaults.standard.object(forKey: Constants.KeySavedMaverickRecordingSessions) as? [[AnyHashable: Any]]
        let manager = CameraManager()
        
        for item in sessions ?? [] {
            
            if let id = item[SCRecordSessionIdentifierKey] as? String, id == identifier {
                
                manager.session = SCRecordSession(dictionaryRepresentation: item)
                manager.existingSessionMetadata = item
                manager.removeRecordSegmentsFromSession()
                return
                
            }
            
        }
        
    }
    
    /**
     Clears all saved sessions and saved assets on disk
     */
    static func removeAllSavedSessions() {
        
        log.verbose("💾 Removing all saved sessions from disk")
        
        UserDefaults.standard.removeObject(forKey: Constants.KeySavedMaverickRecordingSessions)
        UserDefaults.standard.synchronize()
        
        let directoryURL = URL(fileURLWithPath: NSTemporaryDirectory())
        
        guard let enumerator = FileManager.default.enumerator(at: directoryURL.resolvingSymlinksInPath(), includingPropertiesForKeys: nil) else {
            return
        }
        
        while let url = enumerator.nextObject() as? URL {
            
            do {
                try FileManager.default.removeItem(at: url)
            } catch { }
            
        }
        
    }
    
    /**
     Retrieve all of the saved sessions by recorded session identifier
     */
    func getAllSavedSessions() -> [[AnyHashable: Any]] {
        
        guard let saved = UserDefaults.standard.object(forKey: Constants.KeySavedMaverickRecordingSessions) as? [[AnyHashable: Any]] else { return [] }
        
        let sorted = saved.sorted { ($0["Date"] as! Date).timeIntervalSince1970 > ($1["Date"] as! Date).timeIntervalSince1970 }
        var drafts: [[AnyHashable: Any]] = []
        
        for item in sorted {
            
            if validateSavedSession(metadata: item) {
                drafts.append(item)
            }
            
        }
        
        UserDefaults.standard.set(drafts, forKey: Constants.KeySavedMaverickRecordingSessions)
        UserDefaults.standard.synchronize()
        
        return drafts
        
    }
    
    /**
     Validates that the session data exists on disk and can be loaded. If a segment no
     longer exists on disk the session will be invalid.
    */
    func validateSavedSession(metadata: [AnyHashable: Any]) -> Bool {
        
        let session = SCRecordSession(dictionaryRepresentation: metadata)
        
        // Failed to load segments
        if session.segments.count == 0 {
            
            if let name = metadata["sessionImageName"] as? String,
                let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                
                let docPath = dir.appendingPathComponent(name).appendingPathExtension("jpg").path
                return FileManager().fileExists(atPath: docPath)
            }
            
            if let _ = metadata["sessionTextColor"] {
                
                return true
                
            }
            
            return false
            
        }
        
        // Double check
        for segment in session.segments {
            
            if !segment.fileUrlExists {
                return false
            }
            
        }
        
        return true
        
    }
    
    /**
     Checks User Defaults to see if metadata exists for the session identifier
     */
    func isSessionSaved() -> Bool {
        
        guard let identifier = session?.identifier else { return false }
        
        let sessions = getAllSavedSessions()
        if sessions.count == 0 {
            return false
        }
        
        for item in sessions {
            
            if let id = item[SCRecordSessionIdentifierKey] as? String, id == identifier {
                return true
            }
            
        }
        
        return false
        
    }
    
    /**
     Store the metadata for this recording
     */
    func saveRecordSession(withComposition composition: MaverickComposition? = nil, metadataOnly: Bool = false) {
        
        guard var metadata = session?.dictionaryRepresentation() else { return }
        metadata["challengeId"] = sessionChallengeId
        metadata["challengeTitle"] = sessionChallengeTitle
        metadata["description"] = sessionDescription
        
        metadata["coverImagePath"] = sessionCoverImageURL?.path ?? ""
        
        // Was this a photo session?
        if let photo = composition?.lastCapturedImage {
            
            let randomFilename = "\(session!.identifier)_sessionImage" + ".jpg"
            let data = UIImageJPEGRepresentation(photo, 0.8)
            let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
            let photoURL = dir.appendingPathComponent(randomFilename)
            FileManager.default.createFile(atPath: photoURL.path, contents: data, attributes: nil)
            
            metadata["sessionImageName"] = "\(session!.identifier)_sessionImage"
            
        }
        
        if let color = composition?.backgroundColor {
            
            metadata["sessionTextColor"] = color.hexString
            
        } else {
            
            metadata["sessionTextColor"] = nil
            
        }
        
        if !metadataOnly {
            
            if let overlays = composition?.dictionaryRepresentation() {
                metadata["overlays"] = overlays
            }
          
        }
        
        var sessions = getAllSavedSessions()
        
        var exists = false
        var idx = 0
        for saved in sessions {
            
            if let id = saved[SCRecordSessionIdentifierKey] as? String, session!.identifier == id {
                
                log.verbose("💾 Saved session exists. Replacing it.")
                exists = true
                sessions[idx] = metadata
                break
                
            }
            idx += 1
            
        }
        
        if !exists {
            sessions.append(metadata)
        }
        
        log.verbose("💾 \(sessions.count) saved sessions exist")
        
        UserDefaults.standard.set(sessions, forKey: Constants.KeySavedMaverickRecordingSessions)
        UserDefaults.standard.synchronize()
        
    }
    
    /**
     Deletes the metadata from User Defaults and removes the segments from disk
     */
    func removeRecordSegmentsFromSession() {
        
        log.verbose("💾 Deleting segment data from the record session")
        
        guard let session = session else { return }
        
        let fm = FileManager.default
        
        // Remove existing overlay videos
        var idx = 0
        for _ in session.segments {
        
            let filename = "\(session.identifier)SCVideo-Overlay.\(idx).\(session.fileExtension ?? "mp4")"
            let url = SCRecordSessionSegment.segmentURL(forFilename: filename,
                                                        andDirectory: session.segmentsDirectory)
            removeFile(atURL: url, filemanager: fm)
            idx += 1
            
        }
        
        // Remove segments and delete the files
        session.removeAllSegments(true)
        
        // Remove metadata
        var sessions = getAllSavedSessions()
        idx = sessions.count - 1
        for item in sessions.reversed() {
            
            if let id = item[SCRecordSessionIdentifierKey] as? String, id == session.identifier {
                sessions.remove(at: idx)
                break
            }
            idx -= 1
            
        }
        UserDefaults.standard.set(sessions, forKey: Constants.KeySavedMaverickRecordingSessions)
        UserDefaults.standard.synchronize()
        
        
        if let documents = fm.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            // Remove existing overlay data
            let overlayFileUrl = documents.appendingPathComponent("record-data/\(session.identifier)")
            removeFile(atURL: overlayFileUrl, filemanager: fm)
            
            // Remove existing cover image for the session
            let coverFilename = "\(session.identifier)_coverImage"
            let coverUrl = documents.appendingPathComponent("\(coverFilename)").appendingPathExtension("jpg")
            removeFile(atURL: coverUrl, filemanager: fm)
            
            // Remove session image
            let sessionImageFilename = "\(session.identifier)_sessionImage"
            let sessionImageUrl = documents.appendingPathComponent("\(sessionImageFilename)").appendingPathExtension("jpg")
            removeFile(atURL: sessionImageUrl, filemanager: fm)
            
        }
        
    }
    
    /**
     Prepares the recording session with the provided metadata. If a session cannot
     be restored the default recording session will be used.
     */
    func prepareRecordingSession(withSavedMetadata metadata: [AnyHashable: Any],
                                 existingComposition composition: MaverickComposition? = nil)
    {
        
        let restoredSession = SCRecordSession(dictionaryRepresentation: metadata)
        
        if restoredSession.identifier == "" {
            
            prepareRecordingSession()
            return
            
        }
        
        existingSessionMetadata = metadata
        session = restoredSession
        recorder.session = restoredSession
        
    }
    
    /**
     Simple convenience method to remove an item
     */
    fileprivate func removeFile(atURL url: URL, filemanager: FileManager) {
        
        if filemanager.fileExists(atPath: url.path) {
            
            do {
                try filemanager.removeItem(at: url)
            } catch {
                
            }
            
        }
        
    }
    
}
