//
//  MaverickAutoCompleteView.swift
//  Maverick
//
//  Created by Garrett Fritz on 5/7/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import RealmSwift

class MaverickAutoCompleteView : UIView {
    
    enum AutoCompleteType {
        
        case inactive
        case user
        case tag
        
    }
    /// Parent view
    @IBOutlet weak var view: UIView!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    private var users : List<User>?
    private var tags : [Hashtag]?
    
    private var testString = ""
    private weak var originalTextDelegate : UITextViewDelegate?
    private var textView : UITextView?
    
    private var previousRange : NSRange?
    /// The `GlobalServicesContainer` that maintains access to global services
    var services: GlobalServicesContainer?
   
    var contentType : Constants.ContentType?
    var contentId : String?
    private var task: DispatchWorkItem? = nil
    private var isActive : AutoCompleteType = .inactive
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        setup()
        
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        setup()
        
    }
    
    func instanceFromNib() -> UIView {
        
        return R.nib.maverickAutoCompleteView.firstView(owner: self)!
        
    }
    
    func setup() {
        
        view = instanceFromNib()
        addSubview(view)
        view.frame = self.bounds
        view.backgroundColor = UIColor.clear
        tableView.estimatedRowHeight = 55.0;
        tableView.register(R.nib.userTableViewCell)
        tableView.register(R.nib.emptyTableViewCell)
        tableView.register(R.nib.hashTagTableViewCell)
        tableView.tableFooterView = UIView()
        tableView.separatorColor = .clear
        tableView.bounces = false
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.MaverickProfilePowerBackgroundColor
        tableView.estimatedRowHeight = 55
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 4.0
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: -1)
        layer.masksToBounds = false
    }
    
    func configureWith(textView : UITextView, delegate : UITextViewDelegate?, contentType : Constants.ContentType? = nil, contentId : String? = nil, services : GlobalServicesContainer?) {
        
        textView.autocorrectionType = .no
        self.contentType = contentType
        self.contentId = contentId
        self.textView = textView
        self.services = services
        originalTextDelegate = delegate
        self.textView?.delegate = self
        clear()
        
    }
    
    public func isActivelyPresenting() -> Bool {
        return isActive != .inactive
    }
    
    private func update() {
        
        tableView.reloadData()
        heightConstraint.constant = tableView.contentSize.height
        layoutIfNeeded()
        
    }
    
    
    private func configureData(withString value : String? ) {
        
        testString = value ?? ""
        guard let value = value else {
            
            isActive = .inactive
            testString = ""
            users = nil
            tags = nil
            update()
            return
            
        }
        
        task?.cancel()
        
        task = DispatchWorkItem { [weak self] in
            
            if self?.isActive == .user {
             
                self?.services?.globalModelsCoordinator.getUsers(byUsername: value, contentType: self?.contentType, contentId: self?.contentId, completionHandler: { [weak self] results in
                    
                    guard let weakSelf = self , value == weakSelf.testString else { return }
                    weakSelf.users = results
                    weakSelf.update()
                    
                })
            
            } else if self?.isActive == .tag {
                
               
                self?.services?.globalModelsCoordinator.getTags(withQuery: value) { (results) in
                    
                    guard let weakSelf = self , value == weakSelf.testString else { return }
                    weakSelf.tags = results
                    weakSelf.update()
                    
                }
                
                
            }
            
        }
        // execute task in 2 seconds
        if let task = task {
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: task)
        
        }
    
    }
    
    func clear() {
        
        configureData(withString : nil)
        
    }
    
    private func userPicked(selectedUser : User ){
        
        if let range = textView?.text.range(of: "@\(testString)", options: .backwards), let username = selectedUser.username {
           
            textView?.text.replaceSubrange(range, with: "@\(username) ")
            configureData(withString: nil)
           
        }
        
        
    }
    
    private func tagPicked(selectedTag : Hashtag ){
        
        if let range = textView?.text.range(of: "#\(testString)", options: .backwards), let name = selectedTag.name {
            
            textView?.text.replaceSubrange(range, with: "#\(name) ")
            configureData(withString: nil)
            
        }
        
    }
    
}


extension MaverickAutoCompleteView : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isActive == .user, let selectedUser = users?[safe: indexPath.row] {
            
            userPicked(selectedUser: selectedUser)
            
        }
        
        if isActive == .tag, let selectedTag = tags?[safe: indexPath.row] {
            
            tagPicked(selectedTag: selectedTag)
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isActive == .user {
        
            return users?.count ?? 0
        
        } else {
        
            return tags?.count ?? 0
        
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 55
    
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isActive == .user, let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.userTableViewCellId, for: indexPath) {
            
            if let users = users, let user = users[safe: indexPath.row] {
                
                cell.labelDelegate = self
                cell.configure(withUsername: user.username, userId: user.userId, sublabel : user.getFullName(), avatar : user.profileImage, showVerifiedBadge: user.isVerified)
                
            }
            
            return cell
        
        } else if let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.hashTagTableViewCellId, for: indexPath) {
            
            if let tags = tags, let tag = tags[safe: indexPath.row] {
                
                cell.configure(with: tag)
                
            }
            
            return cell
            
        }
        
        return UITableViewCell()
    
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.0
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 0.0
        
    }
    
}

extension MaverickAutoCompleteView : UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print("GARRETT PRE: \(testString), range: \(range) with : \(text)")
        
        if text.count > 1  || text == " " || text.contains("\n") {
            
            configureData(withString: nil)
            
        }
        
        if (isActive != .inactive) && text.count == 0 && (range.location + range.length) == textView.text.count {
            
            if text.suffix(range.length).range(of:"@") != nil  {
                
                  isActive = .user
                
            } else if text.suffix(range.length).range(of:"#") != nil {
                
                isActive = .tag
            }
          
            if testString.count == 0 {
                
                isActive = .inactive
                
            }
            
            if testString.count >= range.length {
                
                testString.removeLast(range.length)
                
            }
            
        }
        
        if isActive != .inactive {
            
            testString.append(text)
            
        }
        if text == "@" {
            
            isActive = .user
            
        }
        if text == "#" {
            
            isActive = .tag
        }
        
        print("GARRETT POST: \(testString)")
        return originalTextDelegate?.textView?(textView, shouldChangeTextIn: range, replacementText : text) ?? true
        
    }
    
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        
        originalTextDelegate?.textViewDidChangeSelection?(textView)
        if let previousRange = previousRange {
            if abs( previousRange.location - textView.selectedRange.location ) > 1 {
                configureData(withString: nil)
            }
            
        }
        previousRange = textView.selectedRange
        
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        return originalTextDelegate?.textViewShouldBeginEditing?(textView) ?? true
    
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        originalTextDelegate?.textViewDidChange?(textView)
        configureData(withString: testString)
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        originalTextDelegate?.textViewDidEndEditing?(textView)
        
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        
        return originalTextDelegate?.textViewShouldEndEditing?(textView) ?? true
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        originalTextDelegate?.textViewDidBeginEditing?(textView)
        
    }
    
    
}

extension MaverickAutoCompleteView : MaverickActiveLabelDelegate {
    
    func userTapped(user: User) {
       
        userPicked(selectedUser: user)
    
    }
    
    func hashtagTapped(tag: Hashtag) {
        
        tagPicked(selectedTag: tag)
        
    }
    
    func linkTapped(url: URL) {
        
    }
    
    
    
}
