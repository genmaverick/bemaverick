//
//  BasicContentDelegate.swift
//  Maverick
//
//  Created by Garrett Fritz on 3/5/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

protocol AdvancedContentDelegate : class {
    
    func didTapAddCommentButton(forContentType contentType: Constants.ContentType, withId id: String, cell: UITableViewCell, contentStyle : Constants.Analytics.Main.Properties.CONTENT_STYLE)
    
    func didTapShowCommentButton(forContentType contentType: Constants.ContentType, withId id: String, contentStyle : Constants.Analytics.Main.Properties.CONTENT_STYLE)
    
    func didTapShowBadgesButton(forContentType contentType: Constants.ContentType, withId id: String, contentStyle : Constants.Analytics.Main.Properties.CONTENT_STYLE)
    
    func didTapOverflowButton(forContentType contentType: Constants.ContentType, withId id: String, contentStyle : Constants.Analytics.Main.Properties.CONTENT_STYLE)
    
    func didTapBackButton()
    
    func didTapChallengeTitleButton(forChallenge challengeId: String, fromContentType contentType: Constants.ContentType, withId id: String, contentStyle : Constants.Analytics.Main.Properties.CONTENT_STYLE)
    
    func didTapInviteChallengeButton(forChallenge challengeId: String, contentStyle : Constants.Analytics.Main.Properties.CONTENT_STYLE)
    
    func didTapChallengeResponsesButton(forChallenge challengeId: String, fromContentType contentType: Constants.ContentType, withId id: String, contentStyle : Constants.Analytics.Main.Properties.CONTENT_STYLE)
    
    func didTapShowProfileButton(forUserId userId: String, fromContentType contentType: Constants.ContentType, withId id: String, contentStyle : Constants.Analytics.Main.Properties.CONTENT_STYLE)
    
    func didTapBadgeButton(cell : Any?, forContentType contentType: Constants.ContentType, withId id: String, badge: MBadge, remove: Bool, contentStyle : Constants.Analytics.Main.Properties.CONTENT_STYLE)
    
    func didTapCTAButton(forChallenge challengeId: String, fromContentType contentType: Constants.ContentType, withId id: String, contentStyle : Constants.Analytics.Main.Properties.CONTENT_STYLE)
    
    func didTapShareButton(forContentType contentType: Constants.ContentType, withId id: String, contentStyle : Constants.Analytics.Main.Properties.CONTENT_STYLE)
    
    func didTapMainArea(cell : Any?, forContentType contentType: Constants.ContentType, withId id: String, contentStyle : Constants.Analytics.Main.Properties.CONTENT_STYLE)
    
    func didTapMuteButton(cell : Any?, forContentType contentType: Constants.ContentType, withId id: String, contentStyle : Constants.Analytics.Main.Properties.CONTENT_STYLE, isMuted : Bool )
    
    func didTapSaveButton(forContentType contentType: Constants.ContentType, withId id: String, isSaved : Bool, contentStyle : Constants.Analytics.Main.Properties.CONTENT_STYLE)
    
    func didTapLink(link: URL?, forContentType contentType: Constants.ContentType, withId id: String, contentStyle : Constants.Analytics.Main.Properties.CONTENT_STYLE)
    
    func didTapFavoriteResponseButton(forContentType contentType: Constants.ContentType, withId id: String, contentStyle : Constants.Analytics.Main.Properties.CONTENT_STYLE, isFavorited : Bool )
    
    func didTapThreeDotButton(forContentType contentType: Constants.ContentType, withId id: String, contentStyle : Constants.Analytics.Main.Properties.CONTENT_STYLE)
    
}
