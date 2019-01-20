//
//  MaverickActionSheetItem.swift
//  Maverick
//
//  Created by Chris Garvey on 4/6/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

public enum MaverickActionSheetItemType {
    
    case message
    case button
    case customView
    
}

protocol MaverickActionSheetItem {
    func myType() -> MaverickActionSheetItemType
}

protocol StandardMaverickActionSheetItem: MaverickActionSheetItem { }

protocol CustomMaverickActionSheetItem: MaverickActionSheetItem {
    func myHeight() -> Double
}


