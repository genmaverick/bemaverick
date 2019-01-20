//
//  StickerGroups.swift
//  Maverick
//
//  Created by Chris Garvey on 7/30/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

protocol StickerGroup {
    
    /**
     The name of the sticker group, which is used as the section header for the stickers in the collection view.
     */
    func nameForGroup() -> String
    
    /**
     The name of the sticker that will be used as the icon to represent the group in sticker selector collection view.
     */
    func stickerIconForGroup() -> String
    
    /**
     The names of the stickers that are contained within the group.
     */
    func stickerNamesForGroup() -> [String]
    
    /**
     The reward needed to unlock
     */
    func requiredReward() -> Reward.RewardTypes?
    
}

struct Stickers {
    
    /// Array containing all of the available sticker groups.
    static let StickerGroups: [StickerGroup] = [
        
        SummerStickers(),
        NatureStickers(),
        AccessoriesStickers(),
        DoYourThingStickers(),
        DecorativeStickers(),
        PhraseStickers(),
        GoodVibesStickers(),
        FabStickers()
        
    ]
    
    struct GoodVibesStickers: StickerGroup {
        
        func requiredReward() -> Reward.RewardTypes? {
        
            return Reward.RewardTypes.stickerPack_1
        
        }
        
        
        func nameForGroup() -> String {
            return "Good Vibes"
        }
        
        func stickerIconForGroup() -> String {
            return "stickers_goodvibes_gem"
        }
        
        func stickerNamesForGroup() -> [String] {
            
            return [
                "stickers_goodvibes_lips",
                "stickers_goodvibes_icecream",
                "stickers_goodvibes_lipstick",
                "stickers_goodvibes_gem",
                "stickers_goodvibes_nobadvibes",
                "stickers_goodvibes_macarons"
            ]
            
        }
        
        
        
    }
    
    struct FabStickers: StickerGroup {
        
        
        func requiredReward() -> Reward.RewardTypes? {
            
            return Reward.RewardTypes.stickerPack_2
            
        }
        
        func nameForGroup() -> String {
            return "Fab"
        }
        
        func stickerIconForGroup() -> String {
            return "stickers_fab_rose"
        }
        
        func stickerNamesForGroup() -> [String] {
            
            return [
                "stickers_fab_rose",
                "stickers_fab_itsok",
                "stickers_fab_iheartme",
                "stickers_fab_2fab4you",
                "stickers_fab_killingit!",
                "stickers_fab_fab"
            ]
            
        }
       
    }
    
    struct SummerStickers: StickerGroup {
        
        func requiredReward() -> Reward.RewardTypes? {
            
            return nil
            
        }
        
        func nameForGroup() -> String {
            return "Summer"
        }
        
        func stickerIconForGroup() -> String {
            return "stickers_summer_rain_10"
        }
        
        func stickerNamesForGroup() -> [String] {
            
            return [
                "stickers_summer_rain_1",
                "stickers_summer_rain_2",
                "stickers_summer_rain_3",
                "stickers_summer_rain_4",
                "stickers_summer_rain_5",
                "stickers_summer_rain_6",
                "stickers_summer_rain_7",
                "stickers_summer_rain_8",
                "stickers_summer_rain_9",
                "stickers_summer_rain_10",
                "stickers_summer_rain_11"
            ]
            
        }
        
        
    }
    
    struct NatureStickers: StickerGroup {
        
        func requiredReward() -> Reward.RewardTypes? {
            
            return nil
            
        }
        
        func nameForGroup() -> String {
            return "Nature"
        }
        
        func stickerIconForGroup() -> String {
            return "sticker_bee_cropped"
        }
        
        func stickerNamesForGroup() -> [String] {
            
            return [
                "sticker_bee",
                "sticker_multicolor_umbrella",
                "sticker_orange_popcicle",
                "sticker_watermelon_popcicle",
                "sticker_potted_flower",
                "sticker_rain_cloud",
                "sticker_sun_with_sunglasses",
                "sticker_wave",
                "sticker_leaf",
                "sticker_lightning"
            ]
            
        }
        
        
    }
    
    struct AccessoriesStickers: StickerGroup {
        
        
        func requiredReward() -> Reward.RewardTypes? {
            
            return nil
            
        }
        
        func nameForGroup() -> String {
            return "Accessories"
        }
        
        func stickerIconForGroup() -> String {
            return "sticker_crown_unicorn"
        }
        
        func stickerNamesForGroup() -> [String] {
            
            return [
                "sticker_crown_bunny",
                "sticker_crown_unicorn",
                "sticker_crown_flower",
                "sticker_crown_gold",
                "sticker_sunglasses_wavy",
                "sticker_sunglasses_round",
                "sticker_sunglasses_red",
                "sticker_sunglasses_flower",
                "sticker_glasses",
                "sticker_snow_goggles",
                "sticker_necklace",
                "sticker_necklace_beyonce",
                "sticker_necklace_pearls",
                "sticker_rbg_collar",
                "sticker_gavel",
                "sticker_chemistry_flask",
                "sticker_hat_beyonce",
                "sticker_hat_chanel",
                "sticker_name_badge",
                "sticker_binoculars"
            ]
            
        }
        
        
    }
    
    struct DoYourThingStickers: StickerGroup {
        
        func requiredReward() -> Reward.RewardTypes? {
            
            return nil
            
        }
        
        func nameForGroup() -> String {
            return "Do Your Thing"
        }
        
        func stickerIconForGroup() -> String {
            return "sticker_doyourthing_red"
        }
        
        func stickerNamesForGroup() -> [String] {
            
            return [
                "sticker_doyourthing_red",
                "sticker_doyourthing_teal",
                "sticker_doyourthing_black",
                "sticker_doyourthing_block_red",
                "sticker_takeupspace_hashtag"
            ]
            
        }
        
        
    }
    
    struct DecorativeStickers: StickerGroup {
        
        func requiredReward() -> Reward.RewardTypes? {
            
            return nil
            
        }
        
        func nameForGroup() -> String {
            return "Decorative"
        }
        
        func stickerIconForGroup() -> String {
            return "sticker_skateboard"
        }
        
        func stickerNamesForGroup() -> [String] {
            
            return [
                "sticker_splatter_teal",
                "sticker_splatter_red",
                "sticker_splatter_purple",
                "sticker_three_stars",
                "sticker_sparkle",
                "sticker_frame",
                "sticker_ribbon_banner",
                "sticker_diamond",
                "sticker_music_notes",
                "sticker_arrow",
                "sticker_bent_arrow",
                "sticker_candy",
                "sticker_light_bulb",
                "sticker_pizza",
                "sticker_rocker",
                "sticker_skateboard",
                "sticker_muscle_1",
                "sticker_muscle_2",
                "sticker_muscle_3",
                "sticker_muscle_4"
            ]
            
        }
        
        
    }
    
    struct PhraseStickers: StickerGroup {
        
        func requiredReward() -> Reward.RewardTypes? {
            
            return nil
            
        }
        
        func nameForGroup() -> String {
            return "Phrase"
        }
        
        func stickerIconForGroup() -> String {
            return "sticker_yas"
        }
        
        func stickerNamesForGroup() -> [String] {
            
            return [
                "sticker_yas",
                "sticker_lit",
                "sticker_omg",
                "sticker_female_sign",
                "sticker_peace_sign",
                "sticker_flag_girl_gang",
                "sticker_flag_squad"
            ]
            
        }
        
     }
    
}


