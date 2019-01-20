//
//  SocialShareManager.swift
//  Maverick
//
//  Created by David McGraw on 4/18/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import Signals
import Branch
import Photos

import FBSDKLoginKit
import TwitterKit

/**
 An enum containing supported share channels for the app
 */
public enum SocialShareChannels: String {

    case generic    = "generic"
    case twitter    = "twitter"
    case instagram  = "instagram"
    case facebook   = "facebook"
    case sms        = "sms"
    case mail       = "mail"
    
}

/**
 A manager responsible for tracking pending share tasks requested by the user.
 */
class SocialShareManager {
    
    // MARK: - Static
    
    /// The FB APP ID for sharing
    static let FBApplicationId: String = {
        return (Bundle.main.infoDictionary?["FacebookAppID"] as? String) ?? ""
    }()
    
    /// The TWTR APP Key for sharing
    static let TWTRConsumerKey: String = {
        return (Bundle.main.infoDictionary?["TWTRAppKey"] as? String) ?? ""
    }()
    
    /// The TWTR APP Key for sharing
    static let TWTRConsumerSecret: String = {
        return (Bundle.main.infoDictionary?["TWTRAppSecret"] as? String) ?? ""
    }()
    
    // MARK: - Public Properties
    
    /// A reference to global model service
    open var globalModelsCoordinator: GlobalModelsCoordinator
    
    /// A dictionary of unhandled share requests
    open private(set) var unhandledShareTasks: [SocialShareTask] = []
    
    /// The operation queue containing active tasks to process
    open private(set) var operationQueue: OperationQueue = OperationQueue()
    
    /// A loading view
    open private(set) var loadingView: LoadingView?
    
    // MARK: - Signals

    /// Signal fired when a share operation was completed
    open var onSocialShareFinishedSignal = Signal<SocialShareTask>()
    
    // MARK: - Public Methods
    
    init(withGlobalModelsCoordinator globalModelsCoordinator: GlobalModelsCoordinator,
         application: UIApplication,
         launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        
        log.verbose("⚙ Initializing Social Share manager...")
        
        self.globalModelsCoordinator = globalModelsCoordinator
        
        /**
         Future proofing: Save and load `unhandledShareTasks` which may be useful
         to improve the UX when the user selects a variety of share options at once
        */
        
        operationQueue.name = "com.bemaverick.bemaverick-ios-share"
        operationQueue.maxConcurrentOperationCount = 1
        
        // Initialize 3rd party

        // Twitter
        TWTRTwitter.sharedInstance().start(withConsumerKey: SocialShareManager.TWTRConsumerKey,
                                           consumerSecret: SocialShareManager.TWTRConsumerSecret)

        // Facebook
        FBSDKApplicationDelegate.sharedInstance().application(application,
                                                              didFinishLaunchingWithOptions: launchOptions)
    
        configureNotifications()
        
    }
    
    /**
     Open a share resource identified by a URL
    */
    func application(_ application: UIApplication,
                     open url: URL,
                     options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool
    {
        
        let handled = FBSDKApplicationDelegate.sharedInstance().application(application,
                                                                            open: url,
                                                                            sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                                            annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        if handled {
            return false
        }
        
        return TWTRTwitter.sharedInstance().application(application,
                                                        open: url,
                                                        options: options)
        
    }
    
    
    /**
     Retrive the access token for the provided channel
    */
    open func accessTokens(forChannel channel: SocialShareChannels) -> (key: String?, secret: String?) {
        
        switch channel {
        case .twitter:
            
            if let session = TWTRTwitter.sharedInstance().sessionStore.session() {
                return (session.authToken, session.authTokenSecret)
            }
            return (nil, nil)
            
        case .instagram:
            return (nil, nil)
            
        case .facebook:
            return (FBSDKAccessToken.current()?.tokenString, nil)
            
        default:
            break
        }
        return (nil, nil)
        
    }
    
    /**
     Determine if the user is authorized to share through the provided channel
    */
    open func isShareAvailable(forChannel channel: SocialShareChannels) -> Bool {
        
        switch channel {
        case .twitter:
            return SocialShareOperationTwitter().isShareAvailable()
        case .instagram:
            return SocialShareOperationInstagram().isShareAvailable()
        case .facebook:
            return SocialShareOperationFacebook().isShareAvailable()
        case .sms:
            return SocialShareOperationSMS().isShareAvailable()
        case .mail:
            return SocialShareOperationMail().isShareAvailable()
        default:
            break
        }
        return false
        
    }
    
    /**
     Check that the provided permission was approved
    */
    open func hasGrantedFacebookPermission(permission: String) -> Bool {
        return FBSDKAccessToken.current().hasGranted(permission)
    }
  
    /**
     Fetch a list of friends with the provided channel
     
     Facebook only for now
    */
    open func friends(throughChannel channel: SocialShareChannels,
                      completionHandler: @escaping (_ friends: [String]) -> Void)
    {
        
        if channel != .facebook { return }
        
        log.verbose("👨‍👨‍👧‍👧 Fetching Facebook friends")
        
        if (FBSDKAccessToken.current().userID) == nil {
            log.verbose("👨‍👨‍👧‍👧 No authorized Facebook user")
            return
        }

        let userId = FBSDKAccessToken.current().userID ?? ""
        let request = FBSDKGraphRequest(graphPath: "\(userId)/friends?fields=id",
                                        parameters: [:],
                                        httpMethod: "GET")

        _ = request?.start { (connection, result, error) in

            guard error == nil else {
                completionHandler([])
                return
            }
            
            var friends: [String] = []
            
            if let obj = (result as? [String: Any]), let data = obj["data"] as? [[String: String]] {
                
                for item in data {
                    
                    if let id = item["id"] {
                        friends.append(id)
                    }
                    
                }
                
            }
            
            completionHandler(friends)
            
        }
        
    }
    
    /**
     Share content through a `SocialShareChannel` given the provided information
     
     At least one of the following is required: response, challenge, user
     
     - parameter response           A response to share
     - parameter challenge          A challenge to share
     - parameter user               A user profile to share
     - parameter channel            The channel to share through (twitter, instagram, etc)
     - parameter shareTitle         A title that can be used when sending mail (as a subject), for example
     - parameter shareText          The text to share along with the content. If nil text
                                    will be generated by using the response object
     - parameter localIdentifier    The `localIdentifier` of an AVAsset from the library
     - parameter vc                 A view controller used display a built-in visual flows
    */
    open func share(response: Response? = nil,
                    challenge: Challenge? = nil,
                    user: User? = nil,
                    throughChannel channel: SocialShareChannels,
                    shareTitle: String? = nil,
                    shareText: String? = nil,
                    localIdentifier: String? = nil,
                    fromViewController vc: UIViewController? = nil)
    {
    
        if hasPendingOperation(forChannel: channel) { return }
        
        log.verbose("👨‍👨‍👧‍👧 Sharing a response through channel \(channel.rawValue)")
        
        if isShareAvailable(forChannel: channel) == false {
            log.verbose("👨‍👨‍👧‍👧 The user is not authorized to share through \(channel.rawValue)")
            return
        }
        
        var sharePath: String = ""
        var id: String = ""
        var title: String = shareTitle ?? ""
        var message: String = shareText ?? ""
        var shareType: SocialShareType = .none
        var videoMedia: MaverickMedia? = nil
        var imageMedia: MaverickMedia? = nil
        
        if let response = response, let path = generateShareLink(forResponse: response, channel: channel)?.path {
            
            sharePath = path
            id = response.responseId
            shareType = .response
            videoMedia = response.videoMedia
            imageMedia = response.imageMedia
            
            let (shareTitle, shareMessage) = getShareStrings(forResponse: response, channel: channel)
            title = shareTitle
            message = shareMessage
            
        } else if let challenge = challenge, let path = generateShareLink(forChallenge: challenge, channel: channel)?.path {
            
            sharePath = path
            id = challenge.challengeId
            shareType = .challenge
            
            videoMedia = challenge.videoMedia
            if videoMedia == nil {
            
                imageMedia = challenge.imageChallengeMedia
                if imageMedia == nil {
                    imageMedia = challenge.mainImageMedia
                }
                
            }
            
            let (shareTitle, shareMessage) = getShareStrings(forChallenge: challenge, channel: channel)
            title = shareTitle
            message = shareMessage
            
        } else if let user = user, let path = generateShareLink(forUser: user, channel: channel)?.path {
            
            sharePath = path
            id = user.userId
            shareType = .user
            
            let (shareTitle, shareMessage) = getShareStrings(forUser: user, channel: channel)
            title = shareTitle
            message = shareMessage
            
            
        } else {
            log.warning("👨‍👨‍👧‍👧 Failed to generate an operation for the share request")
            return
        }
        
        completeShare(withId: id,
                      title: title,
                      message: message,
                      shareLink: sharePath,
                      localIdentifier: localIdentifier,
                      channel: channel,
                      type: shareType,
                      videoMedia: videoMedia,
                      imageMedia: imageMedia,
                      fromViewController: vc)
        
    }
    
    /**
     Begin the login flow for the channel
    */
    open func login(fromViewController vc: UIViewController,
                    channel: SocialShareChannels,
                    readOnly: Bool = false,
                    completionHandler: @escaping (_ error: MaverickError?) -> Void) {
        
        var operation: SocialShareOperation
        
        switch channel {
        case .twitter:
            operation = SocialShareOperationTwitter()
        case .instagram:
            operation = SocialShareOperationInstagram()
        case .facebook:
            operation = SocialShareOperationFacebook()
        case .sms:
            completionHandler(MaverickError.shareFailed(reason: .unknownError(message: "Login not available")))
            return
        case .mail:
            completionHandler(MaverickError.shareFailed(reason: .unknownError(message: "Login not available")))
            return
        default:
            completionHandler(MaverickError.shareFailed(reason: .unknownError(message: "Login not available")))
            return
            
        }
        
        operation.login(fromViewController: vc,
                        readOnly: readOnly,
                        completionHandler: completionHandler)
        
    }
    
    /**
     Flags the response as publically available and generates a share link via Branch
    */
    open func generateShareLink(forResponse response: Response, channel: SocialShareChannels? = nil) -> (path: String, branch: BranchUniversalObject, properties: BranchLinkProperties, env: String)? {
        
        // Make the response publically available
        globalModelsCoordinator.shareResponse(forResponseId: response.responseId)
        
        if let branchShareObject = ShareHelper.shareResponse(response: response),
            let (path, env, properties) = getShareUrlPath(forIdentifier: response.responseId, shareType: .response,
                                              withBranch: branchShareObject,
                                              channel: channel)
        {
            return (path, branchShareObject, properties, env)
        }
        return nil
        
    }
    
    /**
     Flags the response as publically available and generates a share link via Branch
     */
    open func generateShareLink(forChallenge challenge: Challenge, channel: SocialShareChannels? = nil) -> (path: String, branch: BranchUniversalObject, properties: BranchLinkProperties, env: String)? {
        
        if let branchShareObject = ShareHelper.shareChallenge(challenge: challenge),
            let (path, env, properties) = getShareUrlPath(forIdentifier: challenge.challengeId, shareType: .challenge,
                                                          withBranch: branchShareObject,
                                                          channel: channel)
        {
            return (path, branchShareObject, properties, env)
        }
        return nil
        
    }
    
    /**
     Flags the response as publically available and generates a share link via Branch
     */
    open func generateShareLink(forUser user: User, channel: SocialShareChannels? = nil) -> (path: String, branch: BranchUniversalObject, properties: BranchLinkProperties, env: String)? {
        
        if let branchShareObject = ShareHelper.shareUser(user: user),
            let (path, env, properties) = getShareUrlPath(forIdentifier: user.userId, shareType: .user,
                                                          withBranch: branchShareObject,
                                                          channel: channel)
        {
            return (path, branchShareObject, properties, env)
        }
        return nil
        
    }
    
    /**
     Download the video or image and prepare it for sharing
    */
    open func downloadFileContent(video: MaverickMedia?,
                                  image: MaverickMedia?,
                                  completionHandler: @escaping (_ assetUrl: String?, _ err: String?) -> Void)
    {
        
        var path: String = ""
        var responseType: Constants.UploadResponseType = .image
        if let videoPath = video?.URLOriginal {
            path = videoPath
            responseType = .video
        } else if let imagePath = image?.URLOriginal {
            path = imagePath
        }
        
        guard let videoURL = URL(string: path),
            let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory,
                                                                 in: .userDomainMask).first else
        {
            completionHandler(nil, "")
            return
        }
        
        URLSession.shared.downloadTask(with: videoURL) { location, response, error -> Void in

            guard let location = location else {
                completionHandler(nil, "\(error?.localizedDescription ?? "")")
                return
            }

            let destinationURL = documentsDirectoryURL.appendingPathComponent("temp-share-video").appendingPathExtension(videoURL.pathExtension)

            do {

                if FileManager.default.fileExists(atPath: destinationURL.path) {

                    do {
                        try FileManager.default.removeItem(at: destinationURL)
                    } catch { }

                }
                
                try FileManager.default.moveItem(at: location, to: destinationURL)
                self.globalModelsCoordinator.saveFileToAssetLibrary(withFileURL: destinationURL,
                                                                    responseType: responseType,
                                                                    completionHandler: completionHandler)

            } catch {
                log.error(error)
                completionHandler(nil, "\(error.localizedDescription)")
            }

        }.resume()
        
        
    }
    
    /**
     Generate a `BranchLinkProperties` object with the provided content id and environment
     */
    open func defaultLinkProperties(withId id: String, shareType: SocialShareType, environment: String) -> BranchLinkProperties {
        
        let shareURL = R.string.maverickStrings.shareUrl(environment,
                                                         shareType.rawValue,
                                                         id)
        
        let linkProperties: BranchLinkProperties = BranchLinkProperties()
        linkProperties.feature = "share"
        linkProperties.channel = "inapp"
        linkProperties.addControlParam("$fallback_url", withValue: shareURL)
        linkProperties.addControlParam("$ios_passive_deepview", withValue: "false")
        linkProperties.addControlParam("$uri_redirect_mode", withValue: "1")
        return linkProperties
        
    }
    
    /**
     Build share strings based on the provided challenge and the age of the creator
     */
    open func getShareStrings(forChallenge challenge: Challenge, channel: SocialShareChannels) -> (title: String, message: String)
    {
        
        var isLoggedInUser = false
        if let userId = globalModelsCoordinator.loggedInUser?.userId, let creatorId = challenge.userId {
            
            isLoggedInUser = creatorId == userId
        }
        
        switch channel {
        case .mail:
            return (R.string.maverickStrings.shareChallengeSubject(isLoggedInUser ? "my" : "this"), R.string.maverickStrings.shareChallengeBody(isLoggedInUser ? "my" : "this"))
            
        case .sms:
            return ("", R.string.maverickStrings.shareChallenge_sms(isLoggedInUser ? "my" : "this"))
            
        case .generic:
              return (R.string.maverickStrings.shareChallengeSubject(isLoggedInUser ? "my" : "this"), R.string.maverickStrings.shareChallengeBody(isLoggedInUser ? "my" : "this"))
            
        default:
               return (R.string.maverickStrings.shareChallengeSubject(isLoggedInUser ? "my" : "this"), R.string.maverickStrings.shareChallenge_twitter(isLoggedInUser ? "my" : "this"))
        }
     

    }
    
    /**
     Build share strings based on the provided response and the age of the creator
     */
    open func getShareStrings(forResponse response: Response, channel: SocialShareChannels) -> (title: String, message: String)
    {
        var isLoggedInUser = false
        if let userId = globalModelsCoordinator.loggedInUser?.userId, let creatorId = response.userId {
            
            isLoggedInUser = creatorId == userId
            
        }
        
        switch channel {
        case .mail:
            return (R.string.maverickStrings.shareResponseSubject(isLoggedInUser ? "my" : "this"), R.string.maverickStrings.shareResponseBody(isLoggedInUser ? "my" : "this"))
            
        case .sms:
            return ("", R.string.maverickStrings.shareResponse_sms(isLoggedInUser ? "my" : "this"))
        
        case .generic:
            return (R.string.maverickStrings.shareResponseSubject(isLoggedInUser ? "my" : "this"), R.string.maverickStrings.shareResponseBody(isLoggedInUser ? "my" : "this"))
            
        default:
            return (R.string.maverickStrings.shareChallengeSubject(isLoggedInUser ? "my" : "this"), R.string.maverickStrings.shareResponse_twitter(isLoggedInUser ? "my" : "this"))
            
        }
        
    }
    
  
    open func getShareStrings(forUser user: User, channel: SocialShareChannels) -> (title: String, message: String)
    {
    
        var userTitle = String()
        var userMessage = String()
        
        if channel == .mail && user == globalModelsCoordinator.loggedInUser {
            
            userTitle = R.string.maverickStrings.shareMyProfileByEmailSubjectLine()
            userMessage = R.string.maverickStrings.shareMyProfileByEmailBody()
            
        } else {
            
            userTitle = user.username ?? ""
            userMessage = R.string.maverickStrings.shareOtherUser(userTitle)
            
        }
        
        return (userTitle, userMessage)
        
    }
    
    /**
     Scan the pending operation list to see if an operation exsits for the provided
     channel
     */
    open func hasPendingOperation(forChannel channel: SocialShareChannels) -> Bool {
        
        for op in operationQueue.operations {
            
            if let shareOp = op as? SocialShareOperation {
                
                if shareOp.channel == channel {
                    return true
                }
                
            }
            
        }
        return false
        
    }
    
    /**
     Display a generic alert controller
    */
    open func displayAlert(withMessage message: String, vc: UIViewController?) {
        
        if vc == nil { return }
        let alert = UIAlertController(title: "Whoops!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        vc?.present(alert, animated: true, completion: nil)
        
    }
    
    /**
     Display an activity indicator
    */
    open func showLoadingIndicator(fromViewController vc: UIViewController?) {
        
        if loadingView == nil && vc != nil {
            loadingView = LoadingView.instanceFromNib()
            vc?.view.addSubview(loadingView!)
            
            loadingView?.autoAlignAxis(toSuperviewAxis: .vertical)
            loadingView?.autoAlignAxis(.horizontal, toSameAxisOf: vc!.view, withOffset: -50)
            loadingView?.autoSetDimension(.width, toSize: 240)
            loadingView?.autoSetDimension(.height, toSize: 128)
            
        }
        
        vc?.view.isUserInteractionEnabled = false
        
        loadingView?.titleLabel.text = "Preparing for Share"
        loadingView?.startAnimating()
        
    }
    
    /**
     Hide an activity indicator
     */
    open func hideLoadingIndicator() {
        
        loadingView?.superview?.isUserInteractionEnabled = true
        loadingView?.stopAnimating()
        loadingView?.removeFromSuperview()
        loadingView = nil
        
    }
    
    // MARK: - Private Methods
    
    /**
     Check if content needs to be downloaded before creating the operation that
     will be responsibile for sharing
     */
    private func completeShare(withId id: String,
                               title: String,
                               message: String,
                               shareLink: String,
                               localIdentifier: String?,
                               channel: SocialShareChannels,
                               type: SocialShareType,
                               videoMedia: MaverickMedia?,
                               imageMedia: MaverickMedia?,
                               fromViewController vc: UIViewController? = nil)
    {
        
        var localLibraryAssetId = localIdentifier
        
        // Attempt to get an existing saved local asset identifier
        if localLibraryAssetId == nil {
            
            if type == .response {
                localLibraryAssetId = globalModelsCoordinator.responseLocalIdentifier(forResponseId: id)
            } else if type == .challenge {
                localLibraryAssetId = globalModelsCoordinator.challengeLocalIdentifier(forChallengeId: id)
            }
            
        }
        
        // Do we need to download the content?
        if localLibraryAssetId == nil && channel == .instagram {
            
            showLoadingIndicator(fromViewController: vc)
            downloadFileContent(video: videoMedia, image: imageMedia) { newId, err in
                
                self.hideLoadingIndicator()
                if newId == nil {
                    log.verbose("👨‍👨‍👧‍👧 Failed to download content for sharing")
                    self.displayAlert(withMessage: "Failed to prepare content for sharing. \(err ?? "")", vc: vc)
                    return
                }
                
                if type == .response {
                    self.globalModelsCoordinator.saveLocalIdentifier(forResponseId: id, identifier: newId)
                } else if type == .challenge {
                    self.globalModelsCoordinator.saveLocalIdentifier(forChallengeId: id, identifier: newId)
                }
                
                self.createAndExecuteShareOperation(withSharePath: shareLink,
                                                    shareTitle: title,
                                                    shareText: message,
                                                    id: id,
                                                    channel: channel,
                                                    type: type,
                                                    localIdentifier: newId,
                                                    fromViewController: vc)
                
            }
            return
            
        }
        
        createAndExecuteShareOperation(withSharePath: shareLink,
                                       shareTitle: title,
                                       shareText: message,
                                       id: id,
                                       channel: channel,
                                       type: type,
                                       localIdentifier: localLibraryAssetId,
                                       fromViewController: vc)
        
    }
    
    /**
     Create a share operation that is responsible for processing the request.
     
     This operation is added to the `operationQueue` and begins immediately unless
     a view controller is provided. If provided, the built-in share flow for the
     3rd party will begin.
    */
    private func createAndExecuteShareOperation(withSharePath path: String,
                                                shareTitle: String,
                                                shareText: String,
                                                id: String,
                                                channel: SocialShareChannels,
                                                type: SocialShareType,
                                                localIdentifier: String? = nil,
                                                fromViewController vc: UIViewController? = nil)
    {
        
        var operation: SocialShareOperation
        
        switch channel {
        case .twitter:
            operation = SocialShareOperationTwitter()
        case .instagram:
            operation = SocialShareOperationInstagram()
        case .facebook:
            operation = SocialShareOperationFacebook()
        case .sms:
            operation = SocialShareOperationSMS()
        case .mail:
            operation = SocialShareOperationMail()
        default:
            return
        }
        
        operation.shareUrlPath = path
        operation.localIdentifier = localIdentifier
        operation.shareTitle = shareTitle
        operation.shareText = shareText
        operation.identifier = id
        operation.type = type
        
        if vc == nil {
            
            operation.completionBlock = {

                log.verbose("👨‍👨‍👧‍👧 Share operation with \(operation.channel.rawValue) finished")
                DispatchQueue.main.async {
                    self.onSocialShareFinishedSignal.fire(operation)
                }

            }
            operationQueue.addOperation(operation)
            
        } else {
            
            // Channels need to keep the operation alive otherwise it'll
            // be destroyed and will fail to dismiss
            if channel == .sms || channel == .mail || channel == .instagram {
                operationQueue.addOperation(operation)
            }
            operation.share(fromViewController: vc!)
            
        }
        
    }
    
    /**
     Generate a Branch share path with the provided object and content identifier
    */
    private func getShareUrlPath(forIdentifier identifier: String, shareType: SocialShareType,
                                 withBranch branch: BranchUniversalObject,
                                 channel: SocialShareChannels? = nil) -> (path: String, env: String, properties: BranchLinkProperties)?
    {
        
        let env = globalModelsCoordinator.authorizationManager.environment.webUrlStringValue
        let properties = defaultLinkProperties(withId: identifier, shareType: shareType, environment: env)
        
        if channel != nil {
            properties.channel = channel?.rawValue ?? "inapp"
        }
        
        if (UIApplication.shared.delegate as! AppDelegate).branchInitialized, let path = branch.getShortUrl(with: properties) {
            return (path, env, properties)
        } else {
            log.warning("👨‍👨‍👧‍👧 Failed to generate a Branch share URL")
            return nil
        }
        
    }
    
    /**
     Observe 3rd party notifications
    */
    fileprivate func configureNotifications() {
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.FBSDKAccessTokenDidChange,
                                               object: nil,
                                               queue: OperationQueue.main)
        { notification in
            
            if let _ = notification.userInfo?[FBSDKAccessTokenDidChangeUserID] {
                log.verbose("👨‍👨‍👧‍👧 Facebook token changed")
            }
            
        }
        
    }
    
}
