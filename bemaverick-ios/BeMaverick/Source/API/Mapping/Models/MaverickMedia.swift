//
//  MaverickModel.swift
//  BeMaverick
//
//  Created by Garrett Fritz on 2/8/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers
class MaverickMedia: Object {
    
    dynamic var ID = ""
    dynamic var textString :    String?
    dynamic var URLOriginal :   String?
    dynamic var URLThumbnail :  String?
    dynamic var height :        Int = -1
    dynamic var width :         Int = -1
    dynamic var urlHost:        String?
    dynamic var filename:       String?
    dynamic var urlProtocol:    String?
    
    func getUrlForSize(size: CGRect?) -> String? {
        
        guard let size = size, let filename = filename, let urlHost = urlHost, let urlProtocol = urlProtocol else { return URLOriginal }
        
        let urlToNewImage = "/image/\(filename)?&x=\(size.width * UIScreen.main.scale)&y=\(size.height * UIScreen.main.scale)&icq=90"
        guard let signature = "\(MaverickMedia.salt)\(urlToNewImage)".MD5() else { return URLOriginal }
        return "\(urlProtocol)://\(urlHost)\(urlToNewImage)&sig=\(signature)"
        
    }
    
    @objc dynamic private var mediaTypeRawValue = Constants.MediaType.video.rawValue
    var mediaType: Constants.MediaType {
        get {
            return Constants.MediaType(rawValue: mediaTypeRawValue)!
        }
        set {
            mediaTypeRawValue = newValue.rawValue
        }
    }
    
    override static func primaryKey() -> String? {
        return "ID"
    }
    
    func getCoverId() -> String? {
        
        guard mediaType == .cover else { return nil }
        let id = ID.replacingOccurrences(of: "cover_", with: "")
        return id
        
    }
    
    convenience init(id: String, type: Constants.MediaType) {
    
        self.init()
        self.ID = MaverickMedia.getMaverickMediaId(id: id, type: type)
        self.mediaType = type
        
    }
    
    func update(urls : [String:String]) {
        
        self.URLOriginal = urls["original"]

    }

    func update(video: Video) {
        
        self.URLThumbnail = video.thumbnailUrl
        self.URLOriginal = video.videoUrl
        self.height = video.height ?? -1
        self.width = video.width ?? -1
    
    }
    
    func update(image: Image) {
        
        self.URLThumbnail = image.url
        self.URLOriginal = image.url
        self.height = image.height ?? -1
        self.width = image.width ?? -1
        self.filename = image.filename
        self.urlHost = image.urlHost
        self.urlProtocol = image.urlProtocol
        
    }
    
    func update(media: MaverickMedia) {
        
        self.URLOriginal = media.URLOriginal
        self.mediaTypeRawValue = media.mediaTypeRawValue
        
    }
    
    static func getMaverickMediaId(id: String, type: Constants.MediaType) -> String {
        
        return "\(type.stringValue)_\(id)"
    
    }
    
    static var salt = ""
    
}
