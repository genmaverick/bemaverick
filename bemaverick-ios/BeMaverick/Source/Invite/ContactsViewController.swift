//
//  ContactsViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 5/8/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import Contacts
import SwiftMessages
import RealmSwift
import MessageUI

class ContactsViewController : ViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var inviteAllButton: UIButton!
    
    @IBOutlet weak var inviteAllHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - IBActions
    
    @IBAction func inviteAllPressed(_ sender: Any) {
        
        rightButton?.isEnabled = true
        AnalyticsManager.Invite.trackContactInviteAll(mode: mode, source : source)
        guard mode == .email else { return }
        sendAllEmail()
        
    }
    
    /**
     Save button pressed - attempt to leave
     */
    @objc fileprivate func sendButtonPressed(_ sender: Any) {
        
        if mode == .phone {
            
            navigationController?.popToRootViewController(animated: true)
            return
            
        } else {
            
            performSegue(withIdentifier: R.segue.contactsViewController.customizeEmailSegue, sender: self)
            
        }
        
        
    }
    
    // MARK: - Public Properties
    
    /// The `GlobalServicesContainer` that maintains access to global services
    var services: GlobalServicesContainer?
    var rightButton : UIBarButtonItem?
    let store = CNContactStore()
    
    var contacts = [CNContact]()
    var messageController : MFMessageComposeViewController?

    var mode : Constants.ContactMode = .email
    var source = Constants.Analytics.Invite.Properties.SOURCE.profile
    // MARK: - Private Properties
    private var existingUsers : [User] = []
    private var isExistingEmpty = false
    private var isContactsEmpty = false
    private var emailAddresses : [String] = []
    private var phoneNumbers : [String] = []
    private var hasLoaded = false
    private var contactLookups : [String : CNContact] = [:]
    private var invitedUsers : [String] = []
    private var emailsToSend : [String] = []
    private var notificationToken : NotificationToken?
    
    var challengeId : String?
    deinit {
        
        notificationToken?.invalidate()
        
    }
    
    // MARK: - Public Methods
    
    override func viewDidLoad() {
        
        hasNavBar = true
        super.viewDidLoad()
        configureView()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = R.segue.contactsViewController.customizeEmailSegue(segue: segue)?.destination {
            AnalyticsManager.Invite.trackContactSendPressed(mode: mode, source: source)
            vc.services = services
            vc.source = source
            vc.emailsToSend = emailsToSend
            vc.contactsToSend = invitedUsers
            vc.challengeId = challengeId
        }
        
    }
    override func trackScreen() {
        
        AnalyticsManager.Invite.trackContactsScreen(viewController: self, mode: mode, source: source)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if !hasLoaded {
            
            if mode == .facebook {
                fetchFacebookContacts()
            } else {
                fetchLocalContacts()
            }
            tableView.reloadData()
            
            
        }
        
     
    }
    
    // MARK: - Public Methods
    
    /**
     Fetch contacts from the user's device
     */
    func fetchLocalContacts() {
        
        let key  = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey, CNContactOrganizationNameKey,CNContactPhoneNumbersKey, CNContactThumbnailImageDataKey, CNContactImageDataKey, CNContactImageDataAvailableKey] as [CNKeyDescriptor]
        
        let request = CNContactFetchRequest(keysToFetch: key)
        request.sortOrder = CNContactSortOrder.givenName
        
        try! store.enumerateContacts(with: request) { [weak self] contact, stoppingPoint in
            
            guard let weakSelf = self else { return }
            if contact.givenName == "" && contact.familyName == "" {
                return
            }
            
            if weakSelf.mode == .email  {
                
                if  contact.emailAddresses.count == 0 {
                    return
                }
                for email in contact.emailAddresses {
                    let emailTest = email.value.replacingOccurrences(of: " ", with: "")
                    if weakSelf.isValidEmail(testStr: emailTest) {
                        weakSelf.emailAddresses.append(emailTest)
                        weakSelf.contactLookups[emailTest as String] = contact
                    }
                }
                
            }
            
            if weakSelf.mode == .phone {
                
                if contact.phoneNumbers.count == 0  {
                    return
                }
                
                for phoneNumber in contact.phoneNumbers {
                    
                    var doctoredNumber = phoneNumber.value.stringValue
                    if !doctoredNumber.contains("+") {
                        doctoredNumber = "+1\(doctoredNumber)"
                    }
                    
                    doctoredNumber = doctoredNumber.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: " ", with: "").replacingOccurrences(of: " ", with: "")
                    
                    weakSelf.phoneNumbers.append(doctoredNumber)
                    
                    weakSelf.contactLookups[doctoredNumber] = contact
                    
                }
                
            }
            
            weakSelf.contacts.append(contact)
            
        }
        
        // Fetch contacts via e-mail addresses
        if mode == .email {
            
            services?.globalModelsCoordinator.getContacts(byEmails: emailAddresses, phone : [])
            { [weak self] (users) in
                
                self?.completeFetchContacts(users: users)
                
            }
            
        } else if mode == .phone {
            
            
        
            services?.globalModelsCoordinator.getContacts(byEmails: [], phone : phoneNumbers)
            { [weak self] (users) in
                
                self?.completeFetchContacts(users: users)
                
            }
            
        }
        
    }
    
    /**
     Fetch contacts who are on Maverick with a Facebook account
     */
    func fetchFacebookContacts() {
        
        /// Fetch a list of Facebook IDs from Facebook
        services?.shareService.friends(throughChannel: .facebook) { friends in
            
            /// Fetch a list of users of Facebook user's who are on our platform
            self.services?.globalModelsCoordinator.getContacts(byFacebookIds: friends)
            { [weak self] users in
                
                self?.completeFetchContacts(users: users)
                
            }
            
        }
        
    }
    
    /**
     Builds an array of `existingUsers` based on the User list fetched from
     the platform
     */
    fileprivate func completeFetchContacts(users: List<User>?) {
        
        hasLoaded = true
        
        guard let users = users else {
            
            DispatchQueue.main.async {
                self.tableView.isHidden = false
                self.tableView.reloadData()
            }
            return
            
        }
        
        for user in users {
            
            if let email = user.emailAddress {
                
                if mode == .facebook {
                    
                    existingUsers.append(user)
                
                } else {
                    
                    if let contactFound = contactLookups[email] {
                        
                        existingUsers.append(user)
                        
                        if let index = contacts.index(of: contactFound) {
                        
                            contacts.remove(at: index)
                        
                        }
                        
                    }
                    
                }
                
            }
            
            if let phone = user.phoneNumber {
                
                if let contactFound = contactLookups[phone] {
                    
                    existingUsers.append(user)
                    
                    if let index = contacts.index(of: contactFound) {
                        
                        contacts.remove(at: index)
                    
                    }
                    
                }
                
            }
            
        }
        
        DispatchQueue.main.async {
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
        
    }
    
    /**
     Follow the user with the provided id
     */
    func buttonPressedAction(forUserId id: String, isSelected: Bool) {
        
        AnalyticsManager.Profile.trackFollowTapped(userId: id, isFollowing: isSelected, location: self)
        services?.globalModelsCoordinator.toggleUserFollow(follow: isSelected, withId: id) { }
        
    }
    
    // MARK: - Private Methods
    
    /**
     Default view configuration
     */
    private func configureView() {
        
        // iOS 10 fix to not have white spacing on top
        automaticallyAdjustsScrollViewInsets = false
        
        view.backgroundColor = UIColor.white
        tableView.backgroundColor = .white
        tableView.register(R.nib.userTableViewCell)
        tableView.register(R.nib.emptyTableViewCell)
        tableView.register(R.nib.emailContactTableViewCell)
        tableView.tableFooterView = UIView()
        tableView.separatorColor = .clear
        tableView.bounces = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 49.0
        tableView.showsVerticalScrollIndicator = false
        tableView.isHidden = true
        
         navigationItem.leftBarButtonItem = UIBarButtonItem(image: R.image.back_purple(),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(backButtonTapped(_:)))
        navigationItem.leftBarButtonItem?.tintColor = UIColor.MaverickBadgePrimaryColor
        
        if mode == .email {
            
           rightButton = UIBarButtonItem(title: R.string.maverickStrings.invite(), style: .plain, target: self, action: #selector(sendButtonPressed(_:)))
            
            navigationItem.rightBarButtonItem = rightButton
            
        }
        
        rightButton?.isEnabled = false
        
        
        if mode == .phone || mode == .facebook  {
            
            inviteAllHeightConstraint.constant = 0
            
        } else if mode == .email {
            
            inviteAllHeightConstraint.constant = 75
            inviteAllButton.backgroundColor = UIColor.MaverickPrimaryColor
            inviteAllButton.setTitle("INVITE ALL OF MY FRIENDS", for: .normal)
            inviteAllButton.setTitleColor(.white, for: .normal)
            
        }
        
        if source == .editChallenge {
        
            showNavBar(withTitle: "Add by \(mode.rawValue)")
            
        } else {
        
            showNavBar(withTitle: mode.rawValue)
        
        }
        notificationToken = DBManager.sharedInstance.getConfiguration().invitedEmails.observe({ [weak self] (changes) in
            switch changes {
            case .update(_, _,  _, _):
                self?.tableView.reloadData()
            default:
                break
            }
            
        })
        
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
    
    /**
     Check if a valid email address
     */
    private func isValidEmail(testStr:String?) -> Bool {
        
        guard let testStr = testStr else { return false }
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
        
    }
    
    /**
     Invite all e-mail contacts
     */
    private func sendAllEmail() {
        
        let ids = contacts.map { $0.identifier }
        
        services?.globalModelsCoordinator.setInvited(id: ids, mode: .email)
        tableView.reloadData()
        
        emailsToSend.removeAll()
        invitedUsers.removeAll()
        for contact in contacts {
            
            for email in contact.emailAddresses {
                
                let emailTest = email.value.replacingOccurrences(of: " ", with: "")
                if isValidEmail(testStr: emailTest) {
                    
                    emailsToSend.append(emailTest)
                    
                }
                
            }
            
            invitedUsers.append(contact.identifier)
            
        }
        
        performSegue(withIdentifier: R.segue.contactsViewController.customizeEmailSegue, sender: self)
        
        
        
    }
    
    /**
     Invite the contact by e-mail
     */
    fileprivate func sendEmail(toContact contact : CNContact) {
        
        rightButton?.isEnabled = true
        for email in contact.emailAddresses {
            let emailTest = email.value.replacingOccurrences(of: " ", with: "")
            if !invitedUsers.contains(contact.identifier) {
                
                invitedUsers.append(contact.identifier)
                
            }
            
            if isValidEmail(testStr: emailTest) {
                
                    emailsToSend.append(emailTest)
                    
                
            }
        }
        
    }
    
    
    /**
     Invite the contact by e-mail
     */
    fileprivate func removeEmails(fromContact contact : CNContact) {
        
        var emailsToSend : [String] = []
        for email in contact.emailAddresses {
            let emailTest = email.value.replacingOccurrences(of: " ", with: "")
            if let index = invitedUsers.index(of: contact.identifier) {
                invitedUsers.remove(at: index)
            }
            
            if let index = emailsToSend.index(of: emailTest) {
                emailsToSend.remove(at: index)
            }
            
        }
        
        rightButton?.isEnabled = invitedUsers.count > 0
    }
    
    /**
     Invite via SMS
     */
    fileprivate func sendText(toContact contact : CNContact) {
        
        
        
        if (MFMessageComposeViewController.canSendText()) {
        
            messageController?.dismiss(animated: false, completion: nil)
            messageController = MFMessageComposeViewController()
            var recipients : [String] = []
            for phoneNumber in contact.phoneNumbers {
                
                recipients.append(phoneNumber.value.stringValue)
                
            }
            var link : String? = ""
            var userMessage : String? = ""
            if let loggedInUser = services?.globalModelsCoordinator.loggedInUser, let username = loggedInUser.username {
                
                link = services?.shareService.generateShareLink(forUser: loggedInUser)?.path
                userMessage = username
            }
            
            
            
            if source == .editChallenge {
                if let challengeId = challengeId , let challenge = services?.globalModelsCoordinator.challenge(forChallengeId: challengeId), let challengelink = services?.shareService.generateShareLink(forChallenge: challenge)?.path {
                 link = challengelink
                }
                messageController?.body = "\(R.string.maverickStrings.challengeFriendMessage(userMessage ?? "")) \(link ?? "")"
                
            } else {
                
                messageController?.body = "\(R.string.maverickStrings.inviteFriendMessage(userMessage ?? "")) \(link ?? "")"
                
            }
        
            messageController?.recipients = recipients
            messageController?.messageComposeDelegate = self
            AnalyticsManager.Invite.trackContactInviteSent(mode: mode, source: source)
            if let messageController = messageController {
            
                self.present(messageController, animated: true, completion: nil)
            
            }
            
        } else {
            
            view.makeToast("Sorry, your device is not set up to send SMS messages")
        }
        
    }
    
   
}



extension ContactsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if mode == .facebook || source == .editChallenge {
            return 1
        }
        return 2
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if source == .editChallenge {
            
            /// Friends who should be invited
            if contacts.count == 0 {
                
                isContactsEmpty = true
                return 1
                
            }
            
            isContactsEmpty = false
            return contacts.count
            
        }
        /// Friends who are already invited, follow them!
        if section == 0  {
            
            isExistingEmpty = false
            if hasLoaded && existingUsers.count == 0 {
                
                isExistingEmpty = true
                return 1
                
            }
            return existingUsers.count
            
        }
        
        /// Friends who should be invited
        if contacts.count == 0 {
            
            isContactsEmpty = true
            return 1
            
        }
        
        isContactsEmpty = false
        return contacts.count
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 {
            
            if let view =  R.nib.contactsHeaderView.firstView(owner: nil) {
                if source == .editChallenge {
                    
                    view.label.text = "INVITE THESE FRIENDS TO TAKE YOUR CHALLEGE:"
                    
                } else {
                    
                    view.label.text = "YOUR CONTACTS ON MAVERICK:"
                    
                }
                return view
                
            }
            
        }
        
        if section == 1 {
            
            if let view =  R.nib.contactsHeaderView.firstView(owner: nil) {
               
                view.label.text = "INVITE THESE FRIENDS TO BECOME A MAVERICK:"
                    
                
                return view
                
            }
            
        }
        
        return nil
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 1 {
            return 50.0
        }
        
        if !isContactsEmpty {
            return 50.0
        }
        return 0.0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let services = services else { return UITableViewCell() }
        
        if indexPath.section == 0 && source != .editChallenge {
            
            /// No contacts are on maverick
            if isExistingEmpty {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.emptyTableViewCellId, for: indexPath) else {
                    return UITableViewCell()
                }
                
                cell.emptyView.configure(title: "No One Yet",
                                         subtitle: "We didn't find any of your contacts already on Maverick, invite them now to let them in on the fun!",
                                         dark: false)
                
                return cell
                
            }
            
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.userTableViewCellId, for: indexPath),
                let user = existingUsers[safe : indexPath.row] else
            {
                return UITableViewCell()
            }
            
            let isFollowing = services.globalModelsCoordinator.isFollowingUser(userId: user.userId)
            
            var image : UIImage? = nil
            var name = user.getFullName()
            
            if let contact = contactLookups[user.emailAddress ?? user.phoneNumber ?? ""] {
                if let imageData = contact.thumbnailImageData {
                    image = UIImage(data: imageData)
                }
                if let imageData = contact.imageData {
                    image = UIImage(data: imageData)
                }
                name = "\(contact.givenName) \(contact.familyName)"
            }
            cell.overrideButtonTitles(selected: R.string.maverickStrings.following(), unselected: R.string.maverickStrings.follow())
            cell.configure(withUsername: user.username, userId: user.userId, sublabel: name, avatar: user.profileImage, avatarImage: image, isFollowing: isFollowing, showVerifiedBadge: user.isVerified)
            cell.delegate = self
            
            cell.oneWayButton = false
            return cell
            
        }
        
        if isContactsEmpty {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.emptyTableViewCellId, for: indexPath) else {
                return UITableViewCell()
            }
            
            cell.emptyView.configure(title: "No Contacts", subtitle: nil, dark: false)
            return cell
            
        }
        
        if mode == .email  {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.emailContactId, for: indexPath) else
            {
                return UITableViewCell()
            }
            
            if let message = contacts[safe: indexPath.row] {
                cell.delegate = self
                
                
                let authorUserId = "contact_\(message.identifier)"
                let name = "\(message.givenName) \(message.familyName)"
                let selected = invitedUsers.contains(message.identifier)
                
                cell.configure(userId: authorUserId, username: name, selected:selected, isInvited: source == .editChallenge ? false : services.globalModelsCoordinator.isInvited(id: message.identifier, mode: mode))
                
                return cell
                
            }
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.userTableViewCellId, for: indexPath) else {
            return UITableViewCell()
        }
        
        cell.overrideButtonTitles(selected : "INVITED", unselected : "+INVITE")
        if source == .editChallenge {
        
            cell.overrideButtonTitles(selected : "+INVITE", unselected : "+INVITE")
            cell.forceButtonAlwaysOn()
            
        }
        cell.delegate = self
        cell.oneWayButton = true
        if let message = contacts[safe: indexPath.row] {
            
            let authorUserId = "contact_\(message.identifier)"
            let name = "\(message.givenName) \(message.familyName)"
            var image : UIImage? = nil
            if let imageData = message.thumbnailImageData {
                image = UIImage(data: imageData)
            }
            if let imageData = message.imageData {
                image = UIImage(data: imageData)
            }
            
            
            cell.configure(withUsername: name, userId: authorUserId, sublabel : message.organizationName, avatarImage: image, isFollowing :  services.globalModelsCoordinator.isInvited(id: message.identifier, mode: mode))
            
        }
        
        return cell
        
    }
    
}

extension ContactsViewController : UserTableViewCellDelegate {
    
    func didSelectFollowToggleButton(forUserId id: String, follow : Bool) {
        
        guard !id.contains("contact_")else {
            
            let identifier = id.replacingOccurrences(of: "contact_", with: "")
            for contact in contacts {
                if contact.identifier ==  identifier {
                    
                    
                    if mode == .phone {
                        
                        sendText(toContact: contact)
                        services?.globalModelsCoordinator.setInvited(id: [contact.identifier], mode: mode)
                        
                    }
                    
                    break
                }
            }
            
            return
            
        }
        
        buttonPressedAction(forUserId: id, isSelected: follow)
        
    }
    
    func didSelectProfileButton(forUserId id: String) {
        
        guard !id.contains("contact_") else { return }
        
        loadProfile(forUserId: id)
        
    }
    
}

extension ContactsViewController : MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        messageController?.dismiss(animated: true, completion: nil)
        
    }
    
}

extension ContactsViewController : EmailContactTableViewCellDelegate {
    
    func didSelect(forUserId  id: String, selected : Bool) {
        
        guard !id.contains("contact_")else {
            
            let identifier = id.replacingOccurrences(of: "contact_", with: "")
            for contact in contacts {
                
                if contact.identifier ==  identifier {
                    
                    if selected {
                        
                        sendEmail(toContact: contact)
                        
                    } else {
                        
                       removeEmails(fromContact: contact)
                        
                    }
                    
                }
                
            }
            
            return
            
        }
        
        buttonPressedAction(forUserId: id, isSelected: selected)
        
    }
    
}
