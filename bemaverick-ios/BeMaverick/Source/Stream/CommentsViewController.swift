//
//  CommentsViewController.swift
//  BeMaverick
//
//  Created by David McGraw on 11/28/17.
//  Copyright © 2017 BeMaverick. All rights reserved.
//

import UIKit
import Toast_Swift
import RealmSwift

class CommentsViewController: ViewController {
    
    // MARK: - IBOutlets
    
    /// The main collection view displaying saved content
    @IBOutlet weak var tableView: UITableView!
    /// The avatar at the bottom of the screen
    @IBOutlet weak var loggedInUserImaveView: UIImageView!
    /// The input field at the bottom of the screen
    @IBOutlet weak var commentInputField: UITextView!
    /// The bottom view container
    @IBOutlet weak var BottomContainer: UIView!
    /// An input button to send the content
    @IBOutlet weak var commentInputButton: UIButton!
    /// A container view containing the input field for commenting
    @IBOutlet weak var commentInputContainerView: UIView!
    /// The bottom constraint for `commentInputContainerView`
    @IBOutlet weak var commentInputContainerViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var autoCompleteView: MaverickAutoCompleteView!
    /// toggle to show empty view
    private var isEmpty = false
    /// Used for first item display
    private var contentDescription = ""
    /// Used for first item display
    private var contentUsername = ""
    /// Used for first item display
    private var contentHashtags = ""
    /// Used to determine if empty or just loading new data
    private var initialDataReceived = false
    private var notificationToken : NotificationToken?
    private var tempComment : Comment?
    var openKeyboard = false
    private var loggedInUsername = ""
    private var loggedInUserId = ""
    // MARK: - IBActions
    
    
    /**
     Bottom post button pressed
     */
    @IBAction func postButtonTapped(_ sender: Any) {
        AnalyticsManager.Comments.trackCommentSendPressed(contentType, contentId: contentId)
        attemptAddComment()
        
    }
    var messageList : List<Comment> = List()
    var messageArray : [Comment] = []
    /// The `GlobalServicesContainer` that maintains access to global services
    var services: GlobalServicesContainer?
    /// Response data
    fileprivate var response: Response?
    /// Type of content to show comments for
    fileprivate var contentType: Constants.ContentType = .response
    /// Id of content to show comments for
    fileprivate var contentId: String = ""
    /// challenge object
    fileprivate var challenge: Challenge?
    
    /// owner of channel
    fileprivate var user: User?
    
    // MARK: - Lifecycle
    
    deinit {
        
        notificationToken?.invalidate()
        
    }
    
    override func viewDidLoad() {
        
 
        hasNavBar = true
        super.viewDidLoad()
        
        configureView()
        configureSignals()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if openKeyboard {
            
            commentInputField.becomeFirstResponder()
            openKeyboard = false
            
        }
        
    }
    
    
    
    // MARK: - Public Methods
    
    /**
     Set up for response comments
     */
    open func configure(withResponse response: Response) {
        
        contentType = .response
        contentId = response.responseId
        self.response = response
        if let creator = response.creator.first {
            self.user = creator
            contentUsername = user?.username ?? ""
        }
        contentDescription = response.label ?? ""
        
        
    }
    
    /**
     Set up for challenge comments
     */
    open func configure(withChallenge challenge: Challenge) {
        contentType = .challenge
        contentId = challenge.challengeId
        self.challenge = challenge
        if let creator = challenge.getCreator() {
            self.user = creator
            contentUsername = user?.username ?? ""
        }
        contentDescription = challenge.label ?? ""
        
        
    }
    
    // MARK: - Private
    
    /**
     Configure the default layout
     */
    fileprivate func configureView() {
        
        // iOS 10 fix to not have white spacing on top
        automaticallyAdjustsScrollViewInsets = false
        
        commentInputField.text = R.string.maverickStrings.commentPlaceholder()
        commentInputField.textColor = .lightGray
        
        // Configure Table View
        tableView.estimatedRowHeight = 68.0;
        tableView.rowHeight = UITableViewAutomaticDimension;
        BottomContainer.backgroundColor = UIColor.MaverickPrimaryColor
        commentInputField.delegate = self
        // Setup navigation
        commentInputButton.tintColor = UIColor.MaverickPrimaryColor
        commentInputContainerView.layer.borderColor = UIColor.maverickGrey.cgColor
        commentInputContainerView.layer.cornerRadius = commentInputContainerView.frame.height / 2
        commentInputContainerView.layer.borderWidth = 0.5
        commentInputContainerView.layer.borderColor = UIColor(rgba: "D3D3D3ff")?.cgColor
        
        commentInputContainerView.clipsToBounds = true
        
        commentInputContainerView.backgroundColor = .white
        
        
        showNavBar(withTitle: "Comments")
        
        
        // Observe Keyboard
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: .UIKeyboardWillShow,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidShow),
                                               name: .UIKeyboardDidShow,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: .UIKeyboardWillHide,
                                               object: nil)
        
        view.backgroundColor = .white
        tableView.backgroundColor = .white
        tableView.register(R.nib.userTableViewCell)
        tableView.register(R.nib.emptyTableViewCell)
        tableView.tableFooterView = UIView()
        tableView.separatorColor = .clear
        tableView.bounces = false
        tableView.showsVerticalScrollIndicator = false
        if let user = services?.globalModelsCoordinator.loggedInUser {
            loggedInUserId = user.userId
            loggedInUsername = user.username ?? "me"
            if let imagePath = user.profileImage?.getUrlForSize(size: loggedInUserImaveView.frame), let url = URL(string: imagePath) {
                
                loggedInUserImaveView.kf.setImage(with: url, placeholder: R.image.defaultMaverickAvatar(), options: [.transition(.fade(UIImage.fadeInTime))])
                
            } else {
                
                loggedInUserImaveView.image = R.image.defaultMaverickAvatar()
                
            }
            
        }
        
        loggedInUserImaveView.layer.cornerRadius = loggedInUserImaveView.frame.height / 2
        loggedInUserImaveView.clipsToBounds = true
        loggedInUserImaveView.layer.borderWidth = 0.5
        loggedInUserImaveView.layer.borderColor = UIColor.MaverickSecondaryTextColor.cgColor
        
        autoCompleteView.configureWith(textView : commentInputField, delegate: self, contentType: contentType, contentId: contentId, services: services)
        
    }
    
    
    /**
     Configure the default signals to listen for
     */
    fileprivate func configureSignals() {
        
        services?.globalModelsCoordinator.getComments(contentId: contentId, contentType: contentType, count: 100, offset: 0, completionHandler: { [weak self] in
            
            self?.activityIndicator.stopAnimating()
            if let contentType = self?.contentType {
                switch contentType {
                case .challenge:
                    
                    self?.messageList = self?.challenge?.comments ?? List<Comment>()
                    
                    
                    
                case .response:
                    
                    self?.messageList = self?.response?.comments ?? List<Comment>()
                    
                }
                
                self?.notificationToken = self?.messageList.observe({ [weak self] changes in
                    
                    if let messageList  = self?.messageList {
                        
                        self?.messageArray = Array(messageList)
                        
                    }
                    self?.initialDataReceived = true
                    
                    switch changes {
                        
                    case .initial:
                        // Results are now populated and can be accessed without blocking the UI
                        self?.tableView.reloadData()
                        self?.scrollToLastMessage()
                        
                    case .update(_, let deletions, let insertions, let modifications):
                        // Query results have changed, so apply them to the UITableView
                        if self?.tempComment != nil {
                            
                            self?.tempComment = nil
                            return
                            
                        }
                        
                        if deletions.count == insertions.count  || (self?.isEmpty ?? false) {
                            
                            self?.tableView.reloadData()
                            return
                            
                        }
                        
                        if deletions.count == 1 && self?.messageArray.count == 0 {
                            self?.tableView.reloadData()
                            return
                        }
                        self?.tableView.beginUpdates()
                        self?.tableView.insertRows(at: insertions.map({ IndexPath(row: $0 + 1, section: 0) }),
                                                   with: .automatic)
                        self?.tableView.deleteRows(at: deletions.map({ IndexPath(row: $0 + 1, section: 0)}),
                                                   with: .automatic)
                        self?.tableView.reloadRows(at: modifications.map({ IndexPath(row: $0 + 1, section: 0) }),
                                                   with: .automatic)
                        self?.tableView.endUpdates()
                    case .error(let error):
                        print(error)
                        
                    }
                    
                })
                
            }
            
        })
        
        
    }
    
    
    
    /**
     Scroll to the last message in `messages`
     */
    fileprivate func scrollToLastMessage() {
        
        if messageArray.count > 0 {
            
            tableView.scrollToRow(at: IndexPath(row: messageArray.count, section: 0),
                                  at: .bottom,
                                  animated: true)
            
        }
        
    }
    
    
    /**
     Move the input container along with the keyboard
     */
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            
            self.adjustToKeyboard(userInfo: userInfo)
            
        }
        
    }
    
    /**
     Util to adjust to keyboard
     */
    fileprivate func adjustToKeyboard(userInfo: [AnyHashable : Any]) {
        
        if let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let animCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
        {
            
            let convertedKeyboardEndFrame = self.view.convert(keyboardEndFrame, from: self.view.window)
            let rawAnimationCurve = animCurve.uint32Value << 16
            let animationCurve = UIViewAnimationOptions(rawValue: UInt(rawAnimationCurve))
            self.commentInputContainerViewBottomConstraint?.constant = self.view.bounds.maxY - convertedKeyboardEndFrame.minY 
            
            UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.beginFromCurrentState , animationCurve], animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
            
        }
        
    }
    
    /**
     Scroll to the last message
     */
    @objc func keyboardDidShow(notification: NSNotification) {
        self.scrollToLastMessage()
    }
    
    /**
     Return the input container to the bottom of the view
     */
    @objc func keyboardWillHide(notification: NSNotification) {
        
        view.setNeedsUpdateConstraints()
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            
            self.commentInputContainerViewBottomConstraint.constant = 0
            
            self.view.layoutIfNeeded()
            
        })
        
    }
    
    /**
     Validation check on input
     */
    fileprivate func attemptAddComment() {
        
        let input = commentInputField.text ?? ""
        if input.count >= 1 || input.containsEmoji   {
            
            tempComment = Comment(id: "temporary")
            tempComment?.body = input
            tempComment?.contentId = contentId
            tempComment?.userId = services?.globalModelsCoordinator.loggedInUser?.userId ?? ""
            tempComment?.created =  Date().toString(dateFormat: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
            tempComment?.userData = services?.globalModelsCoordinator.loggedInUser
            messageArray.append(tempComment!)
            if isEmpty {
                
                tableView.reloadData()
                
            } else {
                
                tableView.beginUpdates()
                tableView.insertRows(at: [IndexPath(row: messageArray.count, section: 0)], with: .automatic)
                tableView.endUpdates()
                
            }
            
            scrollToLastMessage()
            services?.globalModelsCoordinator.addComment(commentInputField.text, contentId: contentId, contentType: contentType)
            commentInputField.text = ""
            commentInputButton.isEnabled = false
            autoCompleteView.clear()
            
            
        } else {
            
            AnalyticsManager.Comments.trackCommentFail(contentType, contentId: contentId, apiFailure: false, reason: "< 2 chars")
            
        }
        
    }
    
    /**
     launch action sheet for report click
     */
    func launchActionSheet(message: Comment, block: Bool) {
        
        if block {
            
            let blockUserAction = { [unowned self] in
                
                if let authorId = message.creator.first?.userId  {
                    
                    self.services?.globalModelsCoordinator.blockUser(withId: authorId, isBlocked: true)
                    AnalyticsManager.Comments.trackBlockCommentAuthor(self.contentType, contentId: self.contentId, authorId : authorId)
                    
                }
                
                self.view.makeToast("User Blocked")
                
            }
            
            let actionSheetItem = BlockUserCustomActionSheetItem(blockUserAction: blockUserAction, blockUserText: "Block \(message.creator.first?.username ?? "user")")
            
            let maverickActionSheetViewModel = MaverickActionSheetViewModel(title: R.string.maverickStrings.profileHeaderActionSheetTitle(), maverickActionSheetItems: [actionSheetItem], alignment: .leading)
            let maverickActionSheetViewController = MaverickActionSheetVC(viewModel: maverickActionSheetViewModel)
            
            let maverickActionSheetTransitioningDelegate = MaverickActionSheetTransitioningDelegate()
            maverickActionSheetViewController.transitioningDelegate = maverickActionSheetTransitioningDelegate
            transitioningDelegate = maverickActionSheetTransitioningDelegate
            
            present(maverickActionSheetViewController, animated: true, completion: nil)
            
        } else {
            
            let reason1Action = MaverickActionSheetButton(text: Variables.Features.reportCommentReason1.stringValue(), font: R.font.openSansRegular(size: 18.0)!, action: { [unowned self] in
                
                
                self.services?.globalModelsCoordinator.flagComment(message._id, reason: Variables.Features.reportCommentReason1.stringValue(), contentType: self.contentType, contentId: self.contentId)
                self.view.makeToast(R.string.maverickStrings.reportConfirmation())
                AnalyticsManager.Comments.trackCommentReported(self.contentType, contentId: self.contentId, rationale: Variables.Features.reportCommentReason1.stringValue())
                
                }
                , textColor: UIColor.MaverickPrimaryColor)
            
            let reason2Action = MaverickActionSheetButton(text: Variables.Features.reportCommentReason2.stringValue(), font: R.font.openSansRegular(size: 18.0)!, action: { [unowned self] in
                
                self.services?.globalModelsCoordinator.flagComment(message._id, reason: Variables.Features.reportCommentReason2.stringValue(), contentType: self.contentType, contentId: self.contentId)
                self.view.makeToast(R.string.maverickStrings.reportConfirmation())
                AnalyticsManager.Comments.trackCommentReported(self.contentType, contentId: self.contentId, rationale: Variables.Features.reportCommentReason2.stringValue())
                
                }
                , textColor: UIColor.MaverickPrimaryColor)
            
            let reason3Action = MaverickActionSheetButton(text: Variables.Features.reportCommentReason3.stringValue(), font: R.font.openSansRegular(size: 18.0)!, action: { [unowned self] in
                
                self.services?.globalModelsCoordinator.flagComment(message._id, reason: Variables.Features.reportCommentReason3.stringValue(), contentType: self.contentType, contentId: self.contentId)
                self.view.makeToast(R.string.maverickStrings.reportConfirmation())
                AnalyticsManager.Comments.trackCommentReported(self.contentType, contentId: self.contentId, rationale: Variables.Features.reportCommentReason3.stringValue())
                
                }
                , textColor: UIColor.MaverickPrimaryColor)
            
            let actionSheetTitle = R.string.maverickStrings.commentsReportCommentActionSheetTitle()
            
            let maverickActionSheetViewModel = MaverickActionSheetViewModel(title: actionSheetTitle, maverickActionSheetItems: [reason1Action, reason2Action, reason3Action], alignment: .center)
            let maverickActionSheetViewController = MaverickActionSheetVC(viewModel: maverickActionSheetViewModel)
            
            let maverickActionSheetTransitioningDelegate = MaverickActionSheetTransitioningDelegate()
            maverickActionSheetViewController.transitioningDelegate = maverickActionSheetTransitioningDelegate
            transitioningDelegate = maverickActionSheetTransitioningDelegate
            
            present(maverickActionSheetViewController, animated: true, completion: nil)
            
        }
        
    }
    
}

extension CommentsViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var items: [UITableViewRowAction] = []
        
        if let message = messageArray[safe: indexPath.row - 1] {
            
            if message.creator.first?.userId == services?.globalModelsCoordinator.loggedInUser?.userId {
                
                let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
                    
                    self.services?.globalModelsCoordinator.deleteComment(message._id, contentType: self.contentType, contentId: self.contentId)
                    
                    AnalyticsManager.Comments.trackCommentDeleted(self.contentType, contentId: self.contentId)
                    
                }
                
                delete.backgroundColor = UIColor.red
                items.append(delete)
                
            } else {
                
                let report = UITableViewRowAction(style: .normal, title: "Report") { action, index in
                    self.launchActionSheet(message: message, block: false)
                }
                report.backgroundColor = UIColor.orange
                items.append(report)
                
                let block = UITableViewRowAction(style: .normal, title: "Block") { action, index in
                    self.launchActionSheet(message: message, block: true)
                }
                block.backgroundColor = UIColor.red
                items.append(block)
                
            }
            
        }
        
        return items
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if initialDataReceived {
            
            if messageArray.count == 0 {
                
                isEmpty = true
                return 2
                
            }
            
        }
        isEmpty = false
        return messageArray.count + 1
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isEmpty {
            
            if indexPath.row == 1 {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.emptyTableViewCellId, for: indexPath) else {
                    return UITableViewCell()
                }
                
                cell.emptyView.configure(title: R.string.maverickStrings.commentEmptyTitle(), subtitle: nil, dark: false)
                return cell
                
            }
            
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.userTableViewCellId, for: indexPath) else {
            return UITableViewCell()
        }
        cell.labelDelegate = self
        cell.delegate = self
        if indexPath.row == 0 {
            
            if let owner = user {
                
                cell.configure(withUsername: contentUsername , userId: owner.userId, content: contentDescription, avatar: owner.profileImage, showVerifiedBadge: owner.isVerified)
                
                cell.contentView.backgroundColor = UIColor.MaverickProfilePowerBackgroundColor
                return cell
                
            }
            
        }
        
        if let message = messageArray[safe: indexPath.row - 1] {
            
            
            if let author = message.creator.first {
                
                cell.setMentionData(mentions: Array(message.mentions))
                cell.configure(withUsername: author.username, userId: author.userId, content: message.body, date: message.getTimeStamp(), avatar : author.profileImage, showVerifiedBadge: author.isVerified)
                
            } else if tempComment?.body == message.body && tempComment?.userId == loggedInUserId {
                
                cell.setMentionData(mentions: Array(message.mentions))
                cell.configure(withUsername: loggedInUsername, userId: loggedInUserId, content: message.body, date: message.getTimeStamp(), avatarImage : loggedInUserImaveView.image)
                
            }
            
            cell.contentView.backgroundColor = UIColor.white
            
        }
        
        return cell
        
    }
    
}

extension CommentsViewController : UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if let input = textView.text {
            
            let testString = (input as NSString).replacingCharacters(in: range, with: text)
            let charCount = testString.count
            
            commentInputButton.isEnabled = testString.containsEmoji || !( charCount < 2)
            
        }
        
        return true
        
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        AnalyticsManager.Comments.trackCommentEntryStarted(contentType, contentId: contentId)
        if textView.text == R.string.maverickStrings.commentPlaceholder() {
            
            textView.text = ""
            textView.textColor = .black
            
        }
        
        textView.becomeFirstResponder()
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if (textView.text == "") {
            
            textView.text = R.string.maverickStrings.commentPlaceholder()
            textView.textColor = .lightGray
            
        }
        
        textView.resignFirstResponder()
        
    }
    /**
     Navigates the user to the selected user profile
     */
    fileprivate func loadProfile(forUserId id: String) {
        
        guard let vc = R.storyboard.profile.profileViewControllerId() else { return }
        
        vc.services = services
        vc.userId =  id
        
        
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
}

extension CommentsViewController : MaverickActiveLabelDelegate {
    
    func userTapped(user: User) {
        
        AnalyticsManager.Profile.trackMentionPressed(userId: user.userId, source: .comment, contentType: contentType, contentId: contentId)
        loadProfile(forUserId: user.userId)
        
    }
    
    func hashtagTapped(tag: Hashtag) {
        
        
        guard let name = tag.name else { return }
        AnalyticsManager.Profile.trackHashtagPressed(tagName: name, source: .comment, contentType: contentType, contentId: contentId)
        guard let vc = R.storyboard.general.hashtagGroupViewControllerId() else { return }
        
        vc.services = services
        vc.tagName =  name
        
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func linkTapped(url: URL) {
        
        UIApplication.shared.open(url, options: [:], completionHandler: { _ in
            
            
        })
        
    }
    
}


extension CommentsViewController : UserTableViewCellDelegate {
    
    func didSelectFollowToggleButton(forUserId id: String, follow : Bool) {
        
    }
    
    func didSelectProfileButton(forUserId id: String) {
        
        AnalyticsManager.Comments.trackCommentItemTapped(contentType, contentId: contentId, authorId: id)
        loadProfile(forUserId: id)
        
    }
    
}



