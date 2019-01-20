//
//  String+Extensions.swift
//  BeMaverick
//
//  Created by David McGraw on 9/28/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit


extension String {
    
        func encodeUrl() -> String?
        {
            return self.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
        }
    
    func decodeUrl() -> String?
        {
            return self.removingPercentEncoding
        }
    
    
    /**
 
     */
    func boldSubstrings(withColor boldColor: UIColor,
                        substrings: [String],
                        boldFont: UIFont,
                        regularFont: UIFont,
                        regulardColor: UIColor) -> NSAttributedString
    {
        
        let regularFontAttribute = [ NSAttributedStringKey.font: regularFont, NSAttributedStringKey.foregroundColor: regulardColor]
        let boldFontAttribute    = [ NSAttributedStringKey.font: boldFont, NSAttributedStringKey.foregroundColor: boldColor]
        
        let boldString = NSMutableAttributedString(string: self, attributes: regularFontAttribute)
        for substring in substrings {
            boldString.addAttributes(boldFontAttribute, range: (self as NSString).range(of: substring))
        }
        
        return boldString
        
    }
    
    var containsEmoji: Bool {
        for scalar in unicodeScalars {
            switch scalar.value {
            case 0x1F600...0x1F64F, // Emoticons
            0x1F300...0x1F5FF, // Misc Symbols and Pictographs
            0x1F680...0x1F6FF, // Transport and Map
            0x1F1E6...0x1F1FF, // Regional country flags
            0x2600...0x26FF,   // Misc symbols
            0x2700...0x27BF,   // Dingbats
            0xFE00...0xFE0F,   // Variation Selectors
            0x1F900...0x1F9FF,  // Supplemental Symbols and Pictographs
            127000...127600, // Various asian characters
            65024...65039, // Variation selector
            9100...9300, // Misc items
            8400...8447: // Combining Diacritical Marks for Symbols
                return true
            default:
                continue
            }
        }
        return false
    }
    
    /**
     Take a string and color substrings
    */
    func colorSubstrings(withColor color: UIColor,
                         substrings: [String],
                         font: UIFont,
                         regularColor: UIColor) -> NSAttributedString
    {
        
        let attribute = [ NSAttributedStringKey.font: font,
                          NSAttributedStringKey.foregroundColor: regularColor ]
        
        let coloredAttribute = [ NSAttributedStringKey.font: font,
                                 NSAttributedStringKey.foregroundColor: color ]
        
        let coloredString = NSMutableAttributedString(string: self, attributes: attribute)
        for substring in substrings {
            coloredString.addAttributes(coloredAttribute, range: (self as NSString).range(of: substring))
        }
        
        return coloredString
    }
    
    func MD5() -> String? {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)
        if let d = data(using: String.Encoding.utf8) {
            d.withUnsafeBytes { (body: UnsafePointer<UInt8>) in
                CC_MD5(body, CC_LONG(d.count), &digest)
            }
        }
        return (0..<length).reduce("") {
            $0 + String(format: "%02x", digest[$1])
        }
    }
    
    
    
        func capitalizingFirstLetter() -> String {
            return prefix(1).uppercased() + dropFirst()
        }
        
        mutating func capitalizeFirstLetter() {
            self = self.capitalizingFirstLetter()
        }
    
 
        func toBool() -> Bool? {
            switch self {
            case "True", "true", "yes", "1":
                return true
            case "False", "false", "no", "0":
                return false
            default:
                return nil
            }
        }
 
}
