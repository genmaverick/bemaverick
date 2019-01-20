//
//  Theme.swift
//  Production
//
//  Created by Garrett Fritz on 2/1/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

@objcMembers
class Theme: Object, Mappable {
    
    dynamic var _id:                        String = ""
    dynamic var name:                       String?
    dynamic var backgroundImage:            String?
    dynamic var backgroundColor:            String?
    dynamic var fontColor :                 String?
    dynamic var textTransform :             String?
    dynamic var textJustification :         String?
    dynamic var fontName :                  String?
    dynamic var fontShadow :                Bool = false
    dynamic var maxCharacters :             Int = 150
    dynamic var maxFontSize :               Int = 38
    dynamic var padding_top :               Int = 12
    dynamic var padding_bottom :            Int = 12
    dynamic var padding_left :              Int = 12
    dynamic var padding_right :             Int = 12
    dynamic var allowAlpha :                Bool = true
    dynamic var rewardKey :                 String?
    
    override static func primaryKey() -> String? {
        return "_id"
    }
    
  
    func update(_ theme: Theme) {
        
        backgroundImage         = theme.backgroundImage
        backgroundColor         = theme.backgroundColor
        textJustification       = theme.textJustification
        fontColor               = theme.fontColor
        textTransform           = theme.textTransform
        fontName                = theme.fontName
        allowAlpha              = theme.allowAlpha
        name                    = theme.name
        fontShadow              = theme.fontShadow
        maxCharacters           = theme.maxCharacters
        padding_top             = theme.padding_top
        padding_bottom          = theme.padding_bottom
        padding_left            = theme.padding_left
        padding_right           = theme.padding_right
        maxFontSize             = theme.maxFontSize
        rewardKey               = theme.rewardKey
        
    }
    
    required convenience init?(map: Map) {
        
        self.init()
        
    }
    
    convenience init(id: String) {
        
        self.init()
        self._id = id
        
    }
    
    func mapping(map: Map) {
        
        _id                     <- map["_id"]
        backgroundImage         <- map["backgroundImage"]
        backgroundColor         <- map["backgroundColor"]
        fontColor               <- map["fontColor"]
        textTransform           <- map["textTransform"]
        textJustification       <- map["justification"]
        fontName                <- map["fontName"]
        allowAlpha              <- map["allowAlpha"]
        name                    <- map["name"]
        fontShadow              <- map["hasShadow"]
        padding_top             <- map["paddingTop"]
        padding_bottom          <- map["paddingBottom"]
        padding_left            <- map["paddingLeft"]
        padding_right           <- map["paddingRight"]
        maxFontSize             <- map["maxFontSize"]
      
        rewardKey               <- map["reward.key"]
          maxCharacters           <- map["maxCharacters"]
        
    }
    
    override var hashValue: Int {
        return _id.hashValue
    }
    
    static func ==(lhs: Theme, rhs: Theme) -> Bool {
        return lhs._id == rhs._id
    }
    
    func allCaps() -> Bool {
        
        guard let textTransform = textTransform else { return false }
        return textTransform == "uppercase"
        
    }
    
    func setFont(forLabel label: UILabel, textView : UITextView) {
        
        guard let fontName = fontName?.lowercased() else { return }
        
        switch fontName {
            
        case "alfaslaboneregular" :
            label.font = R.font.alfaSlabOneRegular(size: label.font.pointSize)
            textView.font = R.font.alfaSlabOneRegular(size: textView.font?.pointSize ?? label.font.pointSize)
        case "amaticscbold" :
            label.font = R.font.amaticSCBold(size: label.font.pointSize)
            textView.font = R.font.amaticSCBold(size: textView.font?.pointSize ?? label.font.pointSize)
        case "amaticscregular" :
            label.font = R.font.amaticSCRegular(size: label.font.pointSize)
            textView.font = R.font.amaticSCRegular(size: textView.font?.pointSize ?? label.font.pointSize)
        case "antonregular" :
            label.font = R.font.antonRegular(size: label.font.pointSize)
            textView.font = R.font.antonRegular(size: textView.font?.pointSize ?? label.font.pointSize)
        case "arvobolditalic" :
            label.font = R.font.arvoBoldItalic(size: label.font.pointSize)
            textView.font = R.font.arvoBoldItalic(size: textView.font?.pointSize ?? label.font.pointSize)
        case "arvobold" :
            label.font = R.font.arvoBold(size: label.font.pointSize)
            textView.font = R.font.arvoBold(size: textView.font?.pointSize ?? label.font.pointSize)
        case "arvoitalic" :
            label.font = R.font.arvoItalic(size: label.font.pointSize)
            textView.font = R.font.arvoItalic(size: textView.font?.pointSize ?? label.font.pointSize)
        case "arvo" :
            label.font = R.font.arvo(size: label.font.pointSize)
            textView.font = R.font.arvo(size: textView.font?.pointSize ?? label.font.pointSize)
        case "bahianaregular" :
            label.font = R.font.bahianaRegular(size: label.font.pointSize)
            textView.font = R.font.bahianaRegular(size: textView.font?.pointSize ?? label.font.pointSize)
        case "barlowblackitalic" :
            label.font = R.font.barlowBlackItalic(size: label.font.pointSize)
            textView.font = R.font.barlowBlackItalic(size: textView.font?.pointSize ?? label.font.pointSize)
        case "barlowblack" :
            label.font = R.font.barlowBlack(size: label.font.pointSize)
            textView.font = R.font.barlowBlack(size: textView.font?.pointSize ?? label.font.pointSize)
        case "barlowbolditalic" :
            label.font = R.font.barlowBoldItalic(size: label.font.pointSize)
            textView.font = R.font.barlowBoldItalic(size: textView.font?.pointSize ?? label.font.pointSize)
        case "barlowbold" :
            label.font = R.font.barlowBold(size: label.font.pointSize)
            textView.font = R.font.barlowBold(size: textView.font?.pointSize ?? label.font.pointSize)
        case "barlowextrabolditalic" :
            label.font = R.font.barlowExtraBoldItalic(size: label.font.pointSize)
            textView.font = R.font.barlowExtraBoldItalic(size: textView.font?.pointSize ?? label.font.pointSize)
        case "barlowextrabold" :
            label.font = R.font.barlowExtraBold(size: label.font.pointSize)
            textView.font = R.font.barlowExtraBold(size: textView.font?.pointSize ?? label.font.pointSize)
        case "barlowextralightitalic" :
            label.font = R.font.barlowExtraLightItalic(size: label.font.pointSize)
            textView.font = R.font.barlowExtraLightItalic(size: textView.font?.pointSize ?? label.font.pointSize)
        case "barlowextralight" :
            label.font = R.font.barlowExtraLight(size: label.font.pointSize)
            textView.font = R.font.barlowExtraLight(size: textView.font?.pointSize ?? label.font.pointSize)
        case "barlowitalic" :
            label.font = R.font.barlowItalic(size: label.font.pointSize)
            textView.font = R.font.barlowItalic(size: textView.font?.pointSize ?? label.font.pointSize)
        case "barlowlightitalic" :
            label.font = R.font.barlowLightItalic(size: label.font.pointSize)
            textView.font = R.font.barlowLightItalic(size: textView.font?.pointSize ?? label.font.pointSize)
        case "barlowlight" :
            label.font = R.font.barlowLight(size: label.font.pointSize)
            textView.font = R.font.barlowLight(size: textView.font?.pointSize ?? label.font.pointSize)
        case "barlowmediumitalic" :
            label.font = R.font.barlowMediumItalic(size: label.font.pointSize)
            textView.font = R.font.barlowMediumItalic(size: textView.font?.pointSize ?? label.font.pointSize)
        case "barlowmedium" :
            label.font = R.font.barlowMedium(size: label.font.pointSize)
            textView.font = R.font.barlowMedium(size: textView.font?.pointSize ?? label.font.pointSize)
        case "barlowregular" :
            label.font = R.font.barlowRegular(size: label.font.pointSize)
            textView.font = R.font.barlowRegular(size: textView.font?.pointSize ?? label.font.pointSize)
        case "barlowsemibolditalic" :
            label.font = R.font.barlowSemiBoldItalic(size: label.font.pointSize)
            textView.font = R.font.barlowSemiBoldItalic(size: textView.font?.pointSize ?? label.font.pointSize)
        case "barlowsemibold" :
            label.font = R.font.barlowSemiBold(size: label.font.pointSize)
            textView.font = R.font.barlowSemiBold(size: textView.font?.pointSize ?? label.font.pointSize)
        case "barlowthinitalic" :
            label.font = R.font.barlowThinItalic(size: label.font.pointSize)
            textView.font = R.font.barlowThinItalic(size: textView.font?.pointSize ?? label.font.pointSize)
        case "barlowthin" :
            label.font = R.font.barlowThin(size: label.font.pointSize)
            textView.font = R.font.barlowThin(size: textView.font?.pointSize ?? label.font.pointSize)
        case "barrioregular" :
            label.font = R.font.barrioRegular(size: label.font.pointSize)
            textView.font = R.font.barrioRegular(size: textView.font?.pointSize ?? label.font.pointSize)
        case "bebasneuethin" :
            label.font = R.font.bebasNeueThin(size: label.font.pointSize)
            textView.font = R.font.bebasNeueThin(size: textView.font?.pointSize ?? label.font.pointSize)
        case "bebasneuebold" :
            label.font = R.font.bebasNeueBold(size: label.font.pointSize)
            textView.font = R.font.bebasNeueBold(size: textView.font?.pointSize ?? label.font.pointSize)
        case "bebasneuebook" :
            label.font = R.font.bebasNeueBook(size: label.font.pointSize)
            textView.font = R.font.bebasNeueBook(size: textView.font?.pointSize ?? label.font.pointSize)
        case "bebasneuelight" :
            label.font = R.font.bebasNeueLight(size: label.font.pointSize)
            textView.font = R.font.bebasNeueLight(size: textView.font?.pointSize ?? label.font.pointSize)
        case "bebasneueregular" :
            label.font = R.font.bebasNeueRegular(size: label.font.pointSize)
            textView.font = R.font.bebasNeueRegular(size: textView.font?.pointSize ?? label.font.pointSize)
        case "bevanregular" :
            label.font = R.font.bevanRegular(size: label.font.pointSize)
            textView.font = R.font.bevanRegular(size: textView.font?.pointSize ?? label.font.pointSize)
        case "bungeeinlineregular" :
            label.font = R.font.bungeeInlineRegular(size: label.font.pointSize)
            textView.font = R.font.bungeeInlineRegular(size: textView.font?.pointSize ?? label.font.pointSize)
        case "butlerblack" :
            label.font = R.font.butlerBlack(size: label.font.pointSize)
            textView.font = R.font.butlerBlack(size: textView.font?.pointSize ?? label.font.pointSize)
        case "butlerbold" :
            label.font = R.font.butlerBold(size: label.font.pointSize)
            textView.font = R.font.butlerBold(size: textView.font?.pointSize ?? label.font.pointSize)
        case "butlerextrabold" :
            label.font = R.font.butlerExtraBold(size: label.font.pointSize)
            textView.font = R.font.butlerExtraBold(size: textView.font?.pointSize ?? label.font.pointSize)
        case "butlerlight" :
            label.font = R.font.butlerLight(size: label.font.pointSize)
            textView.font = R.font.butlerLight(size: textView.font?.pointSize ?? label.font.pointSize)
        case "butlermedium" :
            label.font = R.font.butlerMedium(size: label.font.pointSize)
            textView.font = R.font.butlerMedium(size: textView.font?.pointSize ?? label.font.pointSize)
        case "butlerultralight" :
            label.font = R.font.butlerUltraLight(size: label.font.pointSize)
            textView.font = R.font.butlerUltraLight(size: textView.font?.pointSize ?? label.font.pointSize)
        case "butler" :
            label.font = R.font.butler(size: label.font.pointSize)
            textView.font = R.font.butler(size: textView.font?.pointSize ?? label.font.pointSize)
        case "cabinsketchregular" :
            label.font = R.font.cabinSketchRegular(size: label.font.pointSize)
            textView.font = R.font.cabinSketchRegular(size: textView.font?.pointSize ?? label.font.pointSize)
        case "chelseamarketregular" :
            label.font = R.font.chelseaMarketRegular(size: label.font.pointSize)
            textView.font = R.font.chelseaMarketRegular(size: textView.font?.pointSize ?? label.font.pointSize)
        case "comfortaabold" :
            label.font = R.font.comfortaaBold(size: label.font.pointSize)
            textView.font = R.font.comfortaaBold(size: textView.font?.pointSize ?? label.font.pointSize)
        case "comfortaalight" :
            label.font = R.font.comfortaaLight(size: label.font.pointSize)
            textView.font = R.font.comfortaaLight(size: textView.font?.pointSize ?? label.font.pointSize)
        case "comfortaaregular" :
            label.font = R.font.comfortaaRegular(size: label.font.pointSize)
            textView.font = R.font.comfortaaRegular(size: textView.font?.pointSize ?? label.font.pointSize)
        case "copse" :
            label.font = R.font.copse(size: label.font.pointSize)
            textView.font = R.font.copse(size: textView.font?.pointSize ?? label.font.pointSize)
        case "courgetteregular" :
            label.font = R.font.courgetteRegular(size: label.font.pointSize)
            textView.font = R.font.courgetteRegular(size: textView.font?.pointSize ?? label.font.pointSize)
        case "dock11heavy" :
            label.font = R.font.dock11Heavy(size: label.font.pointSize)
            textView.font = R.font.dock11Heavy(size: textView.font?.pointSize ?? label.font.pointSize)
        case "dominebold" :
            label.font = R.font.domineBold(size: label.font.pointSize)
            textView.font = R.font.domineBold(size: textView.font?.pointSize ?? label.font.pointSize)
        case "domineregular" :
            label.font = R.font.domineRegular(size: label.font.pointSize)
            textView.font = R.font.domineRegular(size: textView.font?.pointSize ?? label.font.pointSize)
        case "frederickathegreat" :
            label.font = R.font.frederickatheGreat(size: label.font.pointSize)
            textView.font = R.font.frederickatheGreat(size: textView.font?.pointSize ?? label.font.pointSize)
        case "gaegubold" :
            label.font = R.font.gaeguBold(size: label.font.pointSize)
            textView.font = R.font.gaeguBold(size: textView.font?.pointSize ?? label.font.pointSize)
        case "gaegulight" :
            label.font = R.font.gaeguLight(size: label.font.pointSize)
            textView.font = R.font.gaeguLight(size: textView.font?.pointSize ?? label.font.pointSize)
        case "gaeguregular" :
            label.font = R.font.gaeguRegular(size: label.font.pointSize)
            textView.font = R.font.gaeguRegular(size: textView.font?.pointSize ?? label.font.pointSize)
        case "graduateregular" :
            label.font = R.font.graduateRegular(size: label.font.pointSize)
            textView.font = R.font.graduateRegular(size: textView.font?.pointSize ?? label.font.pointSize)
        case "lifesaversregular" :
            label.font = R.font.lifeSaversRegular(size: label.font.pointSize)
            textView.font = R.font.lifeSaversRegular(size: textView.font?.pointSize ?? label.font.pointSize)
        case "londrinaoutlineregular" :
            label.font = R.font.londrinaOutlineRegular(size: label.font.pointSize)
            textView.font = R.font.londrinaOutlineRegular(size: textView.font?.pointSize ?? label.font.pointSize)
        case "loveyalikeasisterregular" :
            label.font = R.font.loveYaLikeASisterRegular(size: label.font.pointSize)
            textView.font = R.font.loveYaLikeASisterRegular(size: textView.font?.pointSize ?? label.font.pointSize)
        case "monotonregular" :
            label.font = R.font.monotonRegular(size: label.font.pointSize)
            textView.font = R.font.monotonRegular(size: textView.font?.pointSize ?? label.font.pointSize)
        case "montserratblackitalic" :
            label.font = R.font.montserratBlackItalic(size: label.font.pointSize)
            textView.font = R.font.montserratBlackItalic(size: textView.font?.pointSize ?? label.font.pointSize)
        case "montserratblack" :
            label.font = R.font.montserratBlack(size: label.font.pointSize)
            textView.font = R.font.montserratBlack(size: textView.font?.pointSize ?? label.font.pointSize)
        case "montserratbolditalic" :
            label.font = R.font.montserratBoldItalic(size: label.font.pointSize)
            textView.font = R.font.montserratBoldItalic(size: textView.font?.pointSize ?? label.font.pointSize)
        case "montserratbold" :
            label.font = R.font.montserratBold(size: label.font.pointSize)
            textView.font = R.font.montserratBold(size: textView.font?.pointSize ?? label.font.pointSize)
        case "montserratextrabolditalic" :
            label.font = R.font.montserratExtraBoldItalic(size: label.font.pointSize)
            textView.font = R.font.montserratExtraBoldItalic(size: textView.font?.pointSize ?? label.font.pointSize)
        case "montserratextrabold" :
            label.font = R.font.montserratExtraBold(size: label.font.pointSize)
            textView.font = R.font.montserratExtraBold(size: textView.font?.pointSize ?? label.font.pointSize)
        case "montserratextralightitalic" :
            label.font = R.font.montserratExtraLightItalic(size: label.font.pointSize)
            textView.font = R.font.montserratExtraLightItalic(size: textView.font?.pointSize ?? label.font.pointSize)
        case "montserratextralight" :
            label.font = R.font.montserratExtraLight(size: label.font.pointSize)
            textView.font = R.font.montserratExtraLight(size: textView.font?.pointSize ?? label.font.pointSize)
        case "montserratitalic" :
            label.font = R.font.montserratItalic(size: label.font.pointSize)
            textView.font = R.font.montserratItalic(size: textView.font?.pointSize ?? label.font.pointSize)
        case "montserratlightitalic" :
            label.font = R.font.montserratLightItalic(size: label.font.pointSize)
            textView.font = R.font.montserratLightItalic(size: textView.font?.pointSize ?? label.font.pointSize)
        case "montserratlight" :
            label.font = R.font.montserratLight(size: label.font.pointSize)
            textView.font = R.font.montserratLight(size: textView.font?.pointSize ?? label.font.pointSize)
        case "montserratmediumitalic" :
            label.font = R.font.montserratMediumItalic(size: label.font.pointSize)
            textView.font = R.font.montserratMediumItalic(size: textView.font?.pointSize ?? label.font.pointSize)
        case "montserratmedium" :
            label.font = R.font.montserratMedium(size: label.font.pointSize)
            textView.font = R.font.montserratMedium(size: textView.font?.pointSize ?? label.font.pointSize)
        case "montserratregular" :
            label.font = R.font.montserratRegular(size: label.font.pointSize)
            textView.font = R.font.montserratRegular(size: textView.font?.pointSize ?? label.font.pointSize)
        case "montserratsemibolditalic" :
            label.font = R.font.montserratSemiBoldItalic(size: label.font.pointSize)
            textView.font = R.font.montserratSemiBoldItalic(size: textView.font?.pointSize ?? label.font.pointSize)
        case "montserratsemibold" :
            label.font = R.font.montserratSemiBold(size: label.font.pointSize)
            textView.font = R.font.montserratSemiBold(size: textView.font?.pointSize ?? label.font.pointSize)
        case "montserratthinitalic" :
            label.font = R.font.montserratThinItalic(size: label.font.pointSize)
            textView.font = R.font.montserratThinItalic(size: textView.font?.pointSize ?? label.font.pointSize)
        case "montserratthin" :
            label.font = R.font.montserratThin(size: label.font.pointSize)
            textView.font = R.font.montserratThin(size: textView.font?.pointSize ?? label.font.pointSize)
        case "nanumpen" :
            label.font = R.font.nanumPen(size: label.font.pointSize)
            textView.font = R.font.nanumPen(size: textView.font?.pointSize ?? label.font.pointSize)
        case "opensansbolditalic" :
            label.font = R.font.openSansBoldItalic(size: label.font.pointSize)
            textView.font = R.font.openSansBoldItalic(size: textView.font?.pointSize ?? label.font.pointSize)
        case "opensansbold" :
            label.font = R.font.openSansBold(size: label.font.pointSize)
            textView.font = R.font.openSansBold(size: textView.font?.pointSize ?? label.font.pointSize)
        case "opensansextrabolditalic" :
            label.font = R.font.openSansExtraBoldItalic(size: label.font.pointSize)
            textView.font = R.font.openSansExtraBoldItalic(size: textView.font?.pointSize ?? label.font.pointSize)
        case "opensansextrabold" :
            label.font = R.font.openSansExtraBold(size: label.font.pointSize)
            textView.font = R.font.openSansExtraBold(size: textView.font?.pointSize ?? label.font.pointSize)
        case "opensansitalic" :
            label.font = R.font.openSansItalic(size: label.font.pointSize)
            textView.font = R.font.openSansItalic(size: textView.font?.pointSize ?? label.font.pointSize)
        case "opensanslightitalic" :
            label.font = R.font.openSansLightItalic(size: label.font.pointSize)
            textView.font = R.font.openSansLightItalic(size: textView.font?.pointSize ?? label.font.pointSize)
        case "opensanslight" :
            label.font = R.font.openSansLight(size: label.font.pointSize)
            textView.font = R.font.openSansLight(size: textView.font?.pointSize ?? label.font.pointSize)
        case "opensansregular" :
            label.font = R.font.openSansRegular(size: label.font.pointSize)
            textView.font = R.font.openSansRegular(size: textView.font?.pointSize ?? label.font.pointSize)
        case "opensanssemibolditalic" :
            label.font = R.font.openSansSemiBoldItalic(size: label.font.pointSize)
            textView.font = R.font.openSansSemiBoldItalic(size: textView.font?.pointSize ?? label.font.pointSize)
        case "opensanssemibold" :
            label.font = R.font.openSansSemiBold(size: label.font.pointSize)
            textView.font = R.font.openSansSemiBold(size: textView.font?.pointSize ?? label.font.pointSize)
        case "oscineappbold" :
            label.font = R.font.oscineAppBold(size: label.font.pointSize)
            textView.font = R.font.oscineAppBold(size: textView.font?.pointSize ?? label.font.pointSize)
        case "oscineappregular" :
            label.font = R.font.oscineAppRegular(size: label.font.pointSize)
            textView.font = R.font.oscineAppRegular(size: textView.font?.pointSize ?? label.font.pointSize)
        case "oswaldbold" :
            label.font = R.font.oswaldBold(size: label.font.pointSize)
            textView.font = R.font.oswaldBold(size: textView.font?.pointSize ?? label.font.pointSize)
        case "oswaldextralight" :
            label.font = R.font.oswaldExtraLight(size: label.font.pointSize)
            textView.font = R.font.oswaldExtraLight(size: textView.font?.pointSize ?? label.font.pointSize)
        case "oswaldlight" :
            label.font = R.font.oswaldLight(size: label.font.pointSize)
            textView.font = R.font.oswaldLight(size: textView.font?.pointSize ?? label.font.pointSize)
        case "oswaldmedium" :
            label.font = R.font.oswaldMedium(size: label.font.pointSize)
            textView.font = R.font.oswaldMedium(size: textView.font?.pointSize ?? label.font.pointSize)
        case "oswaldregular" :
            label.font = R.font.oswaldRegular(size: label.font.pointSize)
            textView.font = R.font.oswaldRegular(size: textView.font?.pointSize ?? label.font.pointSize)
        case "oswaldsemibold" :
            label.font = R.font.oswaldSemiBold(size: label.font.pointSize)
            textView.font = R.font.oswaldSemiBold(size: textView.font?.pointSize ?? label.font.pointSize)
        case "ptsansbolditalic" :
            label.font = R.font.ptSansBoldItalic(size: label.font.pointSize)
            textView.font = R.font.ptSansBoldItalic(size: textView.font?.pointSize ?? label.font.pointSize)
        case "ptsansbold" :
            label.font = R.font.ptSansBold(size: label.font.pointSize)
            textView.font = R.font.ptSansBold(size: textView.font?.pointSize ?? label.font.pointSize)
        case "ptsansitalic" :
            label.font = R.font.ptSansItalic(size: label.font.pointSize)
            textView.font = R.font.ptSansItalic(size: textView.font?.pointSize ?? label.font.pointSize)
        case "ptsansregular" :
            label.font = R.font.ptSansRegular(size: label.font.pointSize)
            textView.font = R.font.ptSansRegular(size: textView.font?.pointSize ?? label.font.pointSize)
        case "pacificoregular" :
            label.font = R.font.pacificoRegular(size: label.font.pointSize)
            textView.font = R.font.pacificoRegular(size: textView.font?.pointSize ?? label.font.pointSize)
        case "playfairdisplayregular" :
            label.font = R.font.playfairDisplayRegular(size: label.font.pointSize)
            textView.font = R.font.playfairDisplayRegular(size: textView.font?.pointSize ?? label.font.pointSize)
        case "pompiereregular" :
            label.font = R.font.pompiereRegular(size: label.font.pointSize)
            textView.font = R.font.pompiereRegular(size: textView.font?.pointSize ?? label.font.pointSize)
        case "pressstart2pregular" :
            label.font = R.font.pressStart2PRegular(size: label.font.pointSize)
            textView.font = R.font.pressStart2PRegular(size: textView.font?.pointSize ?? label.font.pointSize)
        case "quicksandregular" :
            label.font = R.font.quicksandRegular(size: label.font.pointSize)
            textView.font = R.font.quicksandRegular(size: textView.font?.pointSize ?? label.font.pointSize)
        case "robotoslabregular" :
            label.font = R.font.robotoSlabRegular(size: label.font.pointSize)
            textView.font = R.font.robotoSlabRegular(size: textView.font?.pointSize ?? label.font.pointSize)
        case "sacramentoregular" :
            label.font = R.font.sacramentoRegular(size: label.font.pointSize)
            textView.font = R.font.sacramentoRegular(size: textView.font?.pointSize ?? label.font.pointSize)
        case "shrikhandregular" :
            label.font = R.font.shrikhandRegular(size: label.font.pointSize)
            textView.font = R.font.shrikhandRegular(size: textView.font?.pointSize ?? label.font.pointSize)
        case "specialeliteregular" :
            label.font = R.font.specialEliteRegular(size: label.font.pointSize)
            textView.font = R.font.specialEliteRegular(size: textView.font?.pointSize ?? label.font.pointSize)
        case "stardosstencilregular" :
            label.font = R.font.stardosStencilRegular(size: label.font.pointSize)
            textView.font = R.font.stardosStencilRegular(size: textView.font?.pointSize ?? label.font.pointSize)
            
        default:
            label.font = R.font.ptSansRegular(size: label.font.pointSize)
            textView.font = R.font.ptSansRegular(size: textView.font?.pointSize ?? label.font.pointSize)
            
        }
        
    }
  
}
