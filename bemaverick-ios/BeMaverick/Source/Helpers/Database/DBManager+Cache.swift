//
//  DBManager+Content.swift
//  BeMaverick
//
//  Created by Garrett Fritz on 2/14/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import RealmSwift

extension DBManager {
    
    
    func updateCachedVideo(withPath path : String) {
        
        DispatchQueue.main.async {
            
            
            if let cachedVideo = self.database.object(ofType: CachedVideo.self, forPrimaryKey: path) {
                
                if self.database.isInWriteTransaction {
                    
                    cachedVideo.lastUsed = Date()
                    
                } else {
                    
                    self.attemptDBWrite {
                        
                        cachedVideo.lastUsed = Date()
                        
                    }
                    
                }
                
            } else {
                
                let cachedVideo = CachedVideo(path: path)
                
                if self.database.isInWriteTransaction {
                    
                    self.database.add(cachedVideo, update: false)
                    
                } else {
                    
                    self.attemptDBWrite {
                        
                        self.database.add(cachedVideo, update: false)
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    func getCachedVideosToPrune() -> [CachedVideo]? {
        
        let maxVideosToCache = 60
        let videos = database.objects(CachedVideo.self).sorted(byKeyPath: "lastUsed", ascending: false)
        if videos.count > maxVideosToCache {
        
            return Array( videos.prefix( videos.count - maxVideosToCache))
            
        }
        
        return nil
        
    }
    
    func deleteVideos(cachedVideos : [CachedVideo]) {
        
        attemptDBWrite {
            
            for video in cachedVideos {
                
                database.delete(video)
                
            }
            
        }
        
    }
    
}
