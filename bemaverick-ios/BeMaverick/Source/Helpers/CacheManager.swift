//
//  CacheManager.swift
//  Maverick
//
//  Created by Garrett Fritz on 4/16/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation


public enum Result<T> {
    case success(T)
    case downloading()
}

class CacheManager {
    
    static func log(_ message: String) {
        
        #if DEVELOPMENT
        
        print("🎥 \(message)")
        
        #endif
    }
    
    static let shared = CacheManager()
    
    private let fileManager = FileManager.default
    
    private var dowloadingAssets : [String:Bool] = [:]
    private var maxConcurrentDownloads = 2
    private lazy var mainDirectoryUrl: URL = {
        
        let documentsUrl = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        return documentsUrl
        
    }()
    
    func trimOldVideos() {
        
        if let oldVideos = DBManager.sharedInstance.getCachedVideosToPrune() {
            
            CacheManager.log("⛔️ Trimming Video Downloads - exceed max: \(oldVideos.count)")
            for video in oldVideos {
                
                let file = directoryFor(stringUrl: video.path)
                
                do {
                
                    try fileManager.removeItem(at: file)
                 
                
                } catch {
                    
                    CacheManager.log("⛔️ Could not remove file \(video.path)")
                    
                }
            
            }
            
            DBManager.sharedInstance.deleteVideos(cachedVideos: oldVideos)
        
        }
        
    }
        
    
    
    
    func getFileWith(stringUrl: String, ignoreMax : Bool = false, permanent : Bool = false) -> Result<URL> {
        
        let file = directoryFor(stringUrl: stringUrl)
        
        //return file path if already exists in cache directory
        guard !fileManager.fileExists(atPath: file.path)  else {
            
            if !permanent {
            
                DBManager.sharedInstance.updateCachedVideo(withPath: stringUrl)
            
            }
            
            return Result.success(file)
            
        }
        
        let downloads = (dowloadingAssets.map { $0.value }).filter{$0}
        
        if !ignoreMax {
            
            guard downloads.count <= maxConcurrentDownloads else {
                
                CacheManager.log("⛔️ Skipping Download - exceed max concurrent")
                return Result.downloading()
                
            }
        
        }
        
        if !(dowloadingAssets[stringUrl] ?? false) {
            
            CacheManager.log("Begining Download \(stringUrl.suffix(10))")
            
            guard let url = URL(string: stringUrl) else {
                
                CacheManager.log("⛔️ FAIL no url \(stringUrl.suffix(10))")
                
                return  Result.downloading()
                
            }
            
            dowloadingAssets[stringUrl] = true
            
            VideoPlayerView.remoteFileExists(url: url) { [weak self] success in
                
                CacheManager.log("file exists: \(success ? "true" : "false" ) \(stringUrl.suffix(10))")
                
                guard success else {
                    
                    self?.dowloadingAssets[stringUrl] = false
                    return
                    
                }
                
                DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
                    
                    if let videoData = NSData(contentsOf: url) {
                        
                        CacheManager.log(" 🌟 DOWNLOAD SUCCESS: \(stringUrl.suffix(10))")
                        videoData.write(to: file, atomically: true)
                        self?.dowloadingAssets[stringUrl] = false
                        if !permanent {
                            DBManager.sharedInstance.updateCachedVideo(withPath: stringUrl)
                            
                            
                        }
                        
                    } else {
                        
                        CacheManager.log(" ⛔️ FAIL DOWNLOAD: \(stringUrl.suffix(10))")
                        self?.dowloadingAssets[stringUrl] = false
                       
                        
                    }
                    
                }
                
            }
            
        }
        
        return Result.downloading()
  
    }
    
    private func directoryFor(stringUrl: String) -> URL {
        
        let fileURL = URL(string: stringUrl)!.lastPathComponent
        
        let file = self.mainDirectoryUrl.appendingPathComponent(fileURL)
        
        return file
    
    }
    
}


extension FileManager {
    
    /// This method calculates the accumulated size of a directory on the volume in bytes.
    ///
    /// As there's no simple way to get this information from the file system it has to crawl the entire hierarchy,
    /// accumulating the overall sum on the way. The resulting value is roughly equivalent with the amount of bytes
    /// that would become available on the volume if the directory would be deleted.
    ///
    /// - note: There are a couple of oddities that are not taken into account (like symbolic links, meta data of
    /// directories, hard links, ...).
    
    public func allocatedSizeOfDirectory(atUrl url: URL) throws -> UInt64 {
        
        // We'll sum up content size here:
        var accumulatedSize: UInt64 = 0
        
        // prefetching some properties during traversal will speed up things a bit.
        
        let prefetchedProperties = [
            URLResourceKey.isRegularFileKey
            , URLResourceKey.fileAllocatedSizeKey
            , URLResourceKey.totalFileAllocatedSizeKey
        ]
        
        // The error handler simply signals errors to outside code.
        var errorDidOccur: Error?
        let errorHandler: (URL, Error) -> Bool = { _, error in
            errorDidOccur = error
            return false
        }
        
        
        // We have to enumerate all directory contents, including subdirectories.
        let enumerator = self.enumerator(at: url,
                                         includingPropertiesForKeys: prefetchedProperties,
                                         options: FileManager.DirectoryEnumerationOptions.init(rawValue: 0),
                                         errorHandler: errorHandler)
        
        // Start the traversal:
        while let contentURL = (enumerator?.nextObject() as? URL)  {
            
            // Bail out on errors from the errorHandler.
            if let error = errorDidOccur {
                
                continue
//                throw error
                
            }
            
            // Get the type of this item, making sure we only sum up sizes of regular files.
            let resourceValues = try contentURL.resourceValues(forKeys: [.isRegularFileKey, .totalFileAllocatedSizeKey, .fileAllocatedSizeKey])
            
            guard resourceValues.isRegularFile ?? false else {
                continue
            }
            
            // To get the file's size we first try the most comprehensive value in terms of what the file may use on disk.
            // This includes metadata, compression (on file system level) and block size.
            var fileSize = resourceValues.fileSize
            
            // In case the value is unavailable we use the fallback value (excluding meta data and compression)
            // This value should always be available.
            fileSize = fileSize ?? resourceValues.totalFileAllocatedSize
            
            // We're good, add up the value.
            accumulatedSize += UInt64(fileSize ?? 0)
        }
        
        // Bail out on errors from the errorHandler.
        if let error = errorDidOccur {
           
//            throw error
            
        }
        
        // We finally got it.
        return accumulatedSize
    }
}
