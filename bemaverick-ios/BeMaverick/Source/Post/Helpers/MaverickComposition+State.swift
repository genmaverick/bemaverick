//
//  MaverickComposition+State.swift
//  BeMaverick
//
//  Created by David McGraw on 2/9/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

extension MaverickComposition {
    
    /**
     Builds a path to the recording data folder using the selected index. An
     existing session is required.
     
     - parameter excludeIndex:        Returns only a path to the directory containing segment data
    */
    func directoryPathForDrawing(forIndex index: Int, excludeIndex: Bool = false) -> URL {
        
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        var location: URL?
        if excludeIndex {
            location = dir.appendingPathComponent("record-data/\(session!.identifier)")
        }
        location = dir.appendingPathComponent("record-data/\(session!.identifier)/\(index)")
        
        // Create if needed
        if !FileManager.default.fileExists(atPath: location!.path) {
            
            do {
                
                try FileManager.default.createDirectory(atPath: location!.path,
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)

            } catch { }
            
        }
        return location!
        
    }
    
    /**
     Removes files associated with a drawing based on the existing session and selected
     segment index.
    */
    func deleteDirectoryPathForDrawing() {
        
        let dir = directoryPathForDrawing(forIndex: -1, excludeIndex: true)
        
        if FileManager.default.fileExists(atPath: dir.path) {

            do {
                try FileManager.default.removeItem(at: dir)
            } catch { }

        }
        
        
    }
    
    
    /**
     Load an overlay view with the provided state. Layout must be available before
     calling this.
    */
    func loadOverlayContent(withState state: [String: Any]) {
        
        // Setup Master Overlay
        if let dict = state[Constants.RecordingStateKey.masterOverlayKey.rawValue] as? [String: Any] {
           
            if let objects = dict[Constants.RecordingStateKey.dataKey.rawValue] as? [Data] {

                for item in objects {
                    
                    if let v = unarchiveObject(item: item) {
                        
                        masterOverlayView.componentsView!.addSubview(v)
                        if let tv = v as? UITextView {
                            tv.delegate = masterOverlayView
                        }
                        
                    }
                    
                }

            }
            
        }
        
        // Set master overlay filter
        if let masterFilterName = state[Constants.RecordingStateKey.overlayFilterNameKey.rawValue] as? String {
            masterOverlayFilter = getFilter(usingName: masterFilterName)
        }
        
        // Setup Segment Overlays
        if let overlays = state[Constants.RecordingStateKey.overlayKey.rawValue] as? [[String: Any]] {
            
            for overlay in overlays {
                
                if let identifier = overlay[Constants.RecordingStateKey.identifier.rawValue] as? Int {
                    
                    segmentsFilters[identifier] = getFilter(usingName: "None")
                    segmentFilterParams[identifier] = [:]
                    
                    if let filterName = overlay[Constants.RecordingStateKey.overlayFilterNameKey.rawValue] as? String {
                        
                        if let filter = getFilter(usingName: filterName) {
                            segmentsFilters[identifier] = filter
                        }

                    }
                    
                    if let objects = overlay[Constants.RecordingStateKey.dataKey.rawValue] as? [Data],
                        let overlayView = getOverlay(forIndex: identifier)
                    {
                    
                        for item in objects {
                            
                            if let v = unarchiveObject(item: item) {
                                
                                overlayView.componentsView!.addSubview(v)
                                if let tv = v as? UITextView {
                                    tv.delegate = masterOverlayView
                                }
                                
                            }
                        
                        }
                    
                    }
                
                }
            
            }
        
        }
        
    }
    
    /**
     Builds an array representation of each overlay within a composition
     */
    func dictionaryRepresentation() -> [String: Any] {
        
        var overlayIndex = -1
        
        // First item is the master overlay
        let masterOverlay: [String: Any] = dictionaryRepresentation(forOverlayView: masterOverlayView, overlayIndex: overlayIndex)
        var dict: [String: Any] = [:]
        dict[Constants.RecordingStateKey.masterOverlayKey.rawValue] = masterOverlay
        dict[Constants.RecordingStateKey.overlayFilterNameKey.rawValue] = masterOverlayFilter?.name ?? "None"
        overlayIndex += 1
        
        // Get position data from the overlays
        var overlays: [[String: Any]] = []
        for (key, value) in segmentOverlays {

            var overlay: [String: Any] = dictionaryRepresentation(forOverlayView: value, overlayIndex: overlayIndex)
            overlay[Constants.RecordingStateKey.identifier.rawValue] = key
            overlay[Constants.RecordingStateKey.overlayFilterNameKey.rawValue] = segmentsFilters[key]?.name ?? "None"
            overlays.append(overlay)
            overlayIndex += 1
            
        }
        dict[Constants.RecordingStateKey.overlayKey.rawValue] = overlays

        return dict
        
    }
    
    /**
     Loops through the content of the overlay and archives the content.
    */
    func dictionaryRepresentation(forOverlayView overlay: FilterTextOverlayView, overlayIndex: Int) -> [String: Any] {
        
        var dict: [String: Any] = [:]
        
        var objects: [Data] = []
        for item in overlay.componentsView!.subviews {
            objects.append(NSKeyedArchiver.archivedData(withRootObject: item))
        }
        dict[Constants.RecordingStateKey.dataKey.rawValue] = objects

        return dict
        
    }
    
    // MARK: - VIBES
    
    /**
     Load the active overlay with the provided state
    */
    func loadActiveOverlaySavedVibeContent(withState state: [AnyHashable: Any]) {
        
        guard let components = state["components"] as? [Data],
            let filterName = state["filterName"] as? String else { return }
        
        let overlayView = getActiveOverlay()
        overlayView?.reset()
        
        for item in components {

            if let v = unarchiveObject(item: item) {
                overlayView!.componentsView!.addSubview(v)
            }

        }
        
        // Set filter
        if let filter = getFilter(usingName: filterName) {
            setFilterForSelectedIndex(filter)
        }
        
        // Move existing drawing over for the selected index
        // {session id}/{index}/{file list}
        guard let thumbnailPath = state["thumbnail"] as? String else { return }
        
        let fm = FileManager.default
        let documentsDir = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationPath = documentsDir.appendingPathComponent("record-data/\(session.identifier)/\(selectedSegmentIndex)")
        
        var vibePathComps = thumbnailPath.components(separatedBy: "/")
        _ = vibePathComps.popLast()
        let vibePath = vibePathComps.joined(separator: "/")
        
        do {

            // Create directory
            try fm.createDirectory(atPath: destinationPath.path, withIntermediateDirectories: true, attributes: nil)

            // Copy data over
            let files = try fm.contentsOfDirectory(atPath: vibePath)
            for filename in files {
                
                let path = "\(destinationPath.path)/\(filename)"
                if fm.fileExists(atPath: path) {
                    try fm.removeItem(atPath: path)
                }

                try fm.copyItem(at: URL(fileURLWithPath: "\(vibePath)/\(filename)"),
                                to: URL(fileURLWithPath: path))

            }
            
            overlayView?.reloadJotViewProxy()

        } catch {
            log.debug("💾 Failed to copy drawing for saved vibe")
        }
        
    }
    
   
    /**
     Stores the given image in the user's documents directory as `image-upload-{uuid}.jpg`
    */
    func saveImageForUpload(withImage image: UIImage) -> String {
        
        let fm = FileManager.default
        let data = UIImageJPEGRepresentation(image, 1.0)
        let uuid = UUID().uuidString
        
        let documentsDir = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let path = documentsDir.appendingPathComponent("image-upload-\(uuid)").appendingPathExtension("jpg").path
        
        let success = FileManager.default.createFile(atPath: path, contents: data, attributes: nil)
        log.verbose("💾 Saved image for upload (\(success))")
        
        return path
        
    }
    
    // MARK: - Private Methods
    
    
    /**
     Explicitly unarchive an object against the types we support. This is needed
     to make sure the object we get back contains proper transforms for its type.
    */
    fileprivate func unarchiveObject(item: Data) -> UIView? {
        
        if let text = NSKeyedUnarchiver.unarchiveObject(with: item) as? UITextView {
            return text
        }
        
        if let imageView = NSKeyedUnarchiver.unarchiveObject(with: item) as? UIImageView {
            return imageView
        }
        
        return nil
        
    }
    
    /**
     Removes an existing session directory at `sessionId`
     */
    open func removeDirectoryForSession(sessionId: String) {
        
        let fm = FileManager.default
        if let documents = fm.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let filePath = documents.appendingPathComponent("record-data/\(sessionId)")
            if fm.fileExists(atPath: filePath.path) {
                
                do {
                    try fm.removeItem(at: filePath)
                } catch {
                    
                }
                
            }
            
        }
        
    }
    
}
