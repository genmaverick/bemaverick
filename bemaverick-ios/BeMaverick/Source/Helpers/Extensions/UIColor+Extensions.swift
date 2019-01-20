//
//  UIColor+Extensions.swift
//  BeMaverick
//
//  Created by David McGraw on 9/27/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit

extension UIColor {
    
    // MARK: - Lifecycle
    
    /**
     The rgba string representation of color with alpha of the form #RRGGBBAA/#RRGGBB
     
     - parameter rgba: String value.
     */
    public convenience init?(rgba: String) {
        
        var colorToTest = rgba
        if !colorToTest.hasPrefix("#") {
            
            colorToTest = "#\(rgba)"
        
        }
        
        let hexString: String = String(colorToTest[String.Index.init(encodedOffset: 1)...])
        var hexValue:  UInt32 = 0
        
        guard Scanner(string: hexString).scanHexInt32(&hexValue) else {
            return nil
        }
        
        switch (hexString.count) {
        case 6:
            self.init(hex6: hexValue)
        case 8:
            self.init(hex8: hexValue)
        default:
            return nil
        }
        
    }
    
    /**
     The six-digit hexadecimal representation of color of the form #RRGGBB
     
     - parameter hex6: Six-digit hexadecimal value
     */
    public convenience init(hex6: UInt32, alpha: CGFloat = 1) {
        
        let divisor = CGFloat(255)
        let red     = CGFloat((hex6 & 0xFF0000) >> 16) / divisor
        let green   = CGFloat((hex6 & 0x00FF00) >>  8) / divisor
        let blue    = CGFloat( hex6 & 0x0000FF       ) / divisor
        self.init(red: red, green: green, blue: blue, alpha: alpha)
        
    }
    
    /**
     The eight-digit hexadecimal representation of color of the form #RRGGBBAA
     
     - parameter hex6: Six-digit hexadecimal value
     */
    public convenience init(hex8: UInt32) {
        
        let divisor = CGFloat(255)
        let red     = CGFloat((hex8 & 0xFF000000) >> 24) / divisor
        let green   = CGFloat((hex8 & 0x00FF0000) >> 16) / divisor
        let blue    = CGFloat((hex8 & 0x0000FF00) >> 8 ) / divisor
        let alpha    = CGFloat(hex8 & 0x000000FF      ) / divisor
        self.init(red: red, green: green, blue: blue, alpha: alpha)
        
    }
    
   static func textColor(bgColor: UIColor) -> UIColor {
        
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        
        bgColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        // algorithm from: http://www.w3.org/WAI/ER/WD-AERT/#color-contrast
        brightness = ((r * 299) + (g * 587) + (b * 114)) / 1000;
        if (brightness < 0.5) {
            return UIColor.white
        }
        else {
            return UIColor.black
        }
    }
    
    
    // MARK: - Maverick Colors
    
    open class var MaverickBadgePrimaryColor: UIColor {
        if Variables.Colors.colorsInitialized {
            return Variables.Colors.BadgePrimaryColor.colorValue()
        }
        return UIColor(rgba: "#F1495A")!
    }
    
   
    
    
    open class var MaverickPrimaryColor: UIColor {
        if Variables.Colors.colorsInitialized {
            return Variables.Colors.PrimaryColor.colorValue()
        }
        return UIColor(rgba: "#00A8B0")!
    }
    
   
    open class var MaverickBackgroundColor: UIColor {
        if Variables.Colors.colorsInitialized {
            return Variables.Colors.BackgroundColor.colorValue()
        }
        return UIColor(rgba: "#FFFFFF")!
    }
    
    open class var MaverickUnselectedBadgeButton: UIColor {
        if Variables.Colors.colorsInitialized {
            return Variables.Colors.UnselectedBadgeButton.colorValue()
        }
        return UIColor(rgba: "#ffffff")!
    }
    
    
    open class var MaverickTabBarBackgroundColor: UIColor {
        if Variables.Colors.colorsInitialized {
            return Variables.Colors.TabBarBackgroundColor.colorValue()
        }
        return UIColor(rgba: "#FFFFFF")!
    }
    
    open class var MaverickTabBarUnselectedColor: UIColor {
        return UIColor(rgba: "#959595")!
    }
    
    open class var MaverickTextColor: UIColor {
        if Variables.Colors.colorsInitialized {
            return Variables.Colors.TextColor.colorValue()
        }
        return UIColor(rgba: "#FCFCFC")!
    }
    open class var MaverickSecondaryTextColor: UIColor {
        if Variables.Colors.colorsInitialized {
            return Variables.Colors.SecondaryTextColor.colorValue()
        }
        return UIColor(rgba: "#959595")!
    }
    
    open class var MaverickDarkTextColor: UIColor {
        if Variables.Colors.colorsInitialized {
            return Variables.Colors.DarkTextColor.colorValue()
        }
        return UIColor(rgba: "#333333")!
    }
    open class var MaverickDarkSecondaryTextColor: UIColor {
        if Variables.Colors.colorsInitialized {
            return Variables.Colors.DarkSecondaryTextColor.colorValue()
        }
        return UIColor(rgba: "#7B7B7B")!
    }
    
    open class var MaverickDarkTerciaryTextColor: UIColor {
       
        return UIColor(rgba: "#CECECE")!
    }
    
    
    open class var MaverickProfilePowerBackgroundColor: UIColor {
        if Variables.Colors.colorsInitialized {
            return Variables.Colors.ProfilePowerBackgroundColor.colorValue()
        }
        return UIColor(rgba: "#F2F2F2")!
    }
    
    
    
    open class var MaverickVPCBackground: UIColor {
        return UIColor(rgba: "#7B7B7B")!
    }
    
    open class var MaverickDaring: UIColor {
        return UIColor(rgba: "#379155")!
    }
    
    open class var MaverickUnique: UIColor {
        return UIColor(rgba: "#5A175D")!
    }
    
    open class var MaverickUnstoppable: UIColor {
        return UIColor(rgba: "#186A88")!
    }
    
    open class var MaverickCreative: UIColor {
        return UIColor(rgba: "#DD9933")!
    }
    
    
    
    open class var maverickYellow: UIColor {
        return UIColor(rgba: "#F3CC26")!
    }
    
    open class var maverickLightGreen: UIColor {
        return UIColor(rgba: "#BAE1DE")!
    }
    
    open class var maverickPurple: UIColor {
        return UIColor(rgba: "#951A71")!
    }
    
    open class var maverickPink: UIColor {
        return UIColor(rgba: "#E62767")!
    }
    
    open class var maverickOrange: UIColor {
        return UIColor(rgba: "#F47112")!
    }
    
    open class var maverickLightOrange: UIColor {
        return UIColor(rgba: "#F5961A")!
    }
    
    open class var maverickLightGrey: UIColor {
        return UIColor(rgba: "#F6F5F4")!
    }
    
    open class var maverickRed: UIColor {
        return UIColor(rgba: "#E3260B")!
    }
    
    open class var maverickRedOrange: UIColor {
        return UIColor(rgba: "#EAE5E0")!
    }
    
    open class var maverickBurntOrange: UIColor {
        return UIColor(rgba: "#E3540B")!
    }
    
    open class var maverickTeal: UIColor {
        return UIColor(rgba: "#00495A")!
    }
    
    open class var maverickLightTeal: UIColor {
        return UIColor(rgba: "#73BDB5")!
    }
    
    open class var maverickLightRed: UIColor {
        return UIColor(rgba: "#F5D6DA")!
    }
    
    open class var maverickLightSand: UIColor {
        return UIColor(rgba: "#C9C2BA")!
    }
    
    open class var maverickSand: UIColor {
        return UIColor(rgba: "#746F68")!
    }
    
    open class var maverickBackgroundLight: UIColor {
        return UIColor(rgba: "#F2EFEC")!
    }
    
    open class var maverickGold: UIColor {
        return UIColor(rgba: "#C7B821")!
    }
    
    // MARK: - Maverick Video Editor Color Options
    
    open class var maverickVideoColors: [UIColor] {
        return [ UIColor(rgba: "#bc3617")!,
                 UIColor(rgba: "#e06622")!,
                 UIColor(rgba: "#f7bc14")!,
                 UIColor(rgba: "#185b50")!,
                 UIColor(rgba: "#3e9b56")!,
                 UIColor(rgba: "#5bc1b6")!,
                 UIColor(rgba: "#186a88")!,
                 UIColor(rgba: "#a3006f")!,
                 UIColor(rgba: "#f1495a")!,
                 UIColor(rgba: "#f9c5ce")!,
                 UIColor(rgba: "#efefef")!,
                 UIColor(rgba: "#1e1e1e")! ]
    }

    open class var maverickChatBody: UIColor {
        return UIColor(rgba: "#746F68")!
    }

  
    
    // MARK: - Legacy
    
    // MARK: - Maverick Primary Colors
    
    open class var maverickGrey: UIColor {
        return UIColor(red: 216.0/255.0, green: 216.0/255.0, blue: 216.0/255.0, alpha: 1.0)
    }
    
    open class var maverickDarkGrey: UIColor {
        return UIColor(red: 74.0/255.0, green: 74.0/255.0, blue: 74.0/255.0, alpha: 1.0)
    }
    
    open class var maverickWhite: UIColor {
        return UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    }
    
    open class var maverickBrightTeal: UIColor {
        return UIColor(red: 33.0/255.0, green: 198.0/255.0, blue: 218.0/255.0, alpha: 1.0)
    }

    open class var maverickDarkPurple: UIColor {
        return UIColor(red: 63.0/255.0, green: 36.0/255.0, blue: 99.0/255.0, alpha: 1.0)
    }
    
    // MARK: - Navigation
    
    open class var maverickNavigationTitleDark: UIColor {
        return UIColor(red: 51.0/255.0, green: 51.0/255.0, blue: 51.0/255.0, alpha: 1.0)
    }
    
    open class var maverickTextBlue: UIColor {
              return UIColor(rgba: "#003A49")!
    }
    // MARK: - Gradients
    
    /// Bright Gradient
    
    open class var gradientBrightStart: UIColor {
        return UIColor(red: 204.0/255.0, green: 98.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    }
    
    open class var gradientBrightEnd: UIColor {
        return UIColor(red: 20.0/255.0, green: 179.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    }
    
    /// Muted Gradient
    
    open class var gradientMutedStart: UIColor {
        return UIColor.maverickPurple
    }
    
    open class var gradientMutedEnd: UIColor {
        return UIColor.maverickTeal
    }
    
    /// Purple Gradient
    
    open class var gradientPurpleStart: UIColor {
        return UIColor(red: 204.0/255.0, green: 98.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    }
    
    open class var gradientPurpleEnd: UIColor {
        return UIColor(red: 138.0/255.0, green: 145.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    }
    
    open var hexString: String? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        let multiplier = CGFloat(255.999999)
        
        guard self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }
        return String(
            format: "#%02lX%02lX%02lX%02lX",
            Int(red * multiplier),
            Int(green * multiplier),
            Int(blue * multiplier),
            Int(alpha * multiplier)
        )
        
    }
    
    open class func colorWithGradient(frame: CGRect, colors: [UIColor]) -> UIColor {
        
        // create the background layer that will hold the gradient
        let backgroundGradientLayer = CAGradientLayer()
        backgroundGradientLayer.frame = frame
        
        // we create an array of CG colors from out UIColor array
        let cgColors = colors.map({$0.cgColor})
        
        backgroundGradientLayer.colors = cgColors
        
        UIGraphicsBeginImageContext(backgroundGradientLayer.bounds.size)
        backgroundGradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let backgroundColorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return UIColor(patternImage: backgroundColorImage!)
    }
}
