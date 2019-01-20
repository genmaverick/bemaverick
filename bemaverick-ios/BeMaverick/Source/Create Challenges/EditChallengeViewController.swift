//
//  EditChallengeViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 6/13/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import SwiftMessages

import RealmSwift
class EditChallengeViewController : ViewController {
    
    @IBOutlet weak var progressContainerView: UIView!
    @IBOutlet weak var successView: UIStackView!
    @IBOutlet weak var uploadingText: LoadingLabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var postContainer: UIView!
    
    @IBOutlet weak var postButton: UIButton!
    private var hasLink = false
    private var largeLinkContainer = false
    private var previewCell : EditChallengePreviewCollectionViewCell?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = R.segue.editChallengeViewController.inviteFriendsSegue(segue: segue)?.destination {
            
            vc.source = .editChallenge
            vc.challengeId = challenge?.challengeId
        }
        
    }
    
    
    
    func configureChallengeSettings(hasPhoto: Bool, themeName: String?, charCount : Int) {
        
        self.hasPhoto = hasPhoto
        self.themeName = themeName
        self.charCount = charCount
        
    }
    /// users list
    private var users : [User] = [] {
        
        didSet {
            
            collectionView.reloadData()
            
        }
        
    }
    
    var image : UIImage?
    var imageText : String?
    var challenge : Challenge?
    var selectedLink : URL?
    private var isCreateMode = true
    private var hasPhoto: Bool = false
    private var themeName: String?
    private var charCount : Int = 0
    private var selectedUserNames : [String] = []
    /// A reference to the `UIKeyboardWillShow` notification
    private var keyboardWillShowId: NSObjectProtocol?
    /// A reference to the `UIKeyboardWillHide` notification
    private var keyboardWillHideId: NSObjectProtocol?
    private var dismissPressed = false
    
    /// The `GlobalServicesContainer` that maintains access to global services
    var services: GlobalServicesContainer?
    
    override func viewDidLoad() {
        
        hasNavBar = true
        super.viewDidLoad()
        loadUpExistingMentions()
        configureSignal()
        configureView()
        configureData()
        configureCreateVsEdit()
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(keyboardWillShowId as Any)
        NotificationCenter.default.removeObserver(keyboardWillHideId as Any)
        
    }
    
    
    private func configureView() {
        
        postButton.backgroundColor = UIColor.MaverickBadgePrimaryColor
        
        uploadingText.start()
        collectionView.register(R.nib.editChallengeCollectionHeader, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader)
        collectionView.register(R.nib.horizontalUserView)
        
        collectionView.register(R.nib.linkViewCollectionViewCell)
        collectionView.register(R.nib.inviteFriendsCollectionViewCell)
        collectionView.register(R.nib.editChallengePreviewCollectionViewCell)
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            
            flowLayout.sectionHeadersPinToVisibleBounds = true
            flowLayout.scrollDirection = .vertical
            collectionView.showsVerticalScrollIndicator = false
            collectionView.showsHorizontalScrollIndicator = false
            
        }
        
        
        progressContainerView.isHidden = true
        
        progressContainerView.backgroundColor = UIColor.MaverickPrimaryColor
        
        uploadingText.textColor = .white
        progressBar.progressTintColor = UIColor.MaverickBadgePrimaryColor
        progressBar.trackTintColor = .white
        
        navigationItem.rightBarButtonItem = nil
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: R.image.back_purple(),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(backButtonTapped(_:)))
        
        navigationItem.leftBarButtonItem?.tintColor = UIColor.MaverickBadgePrimaryColor
    }
    
    private func configureCreateVsEdit() {
        
        guard image != nil else {
            
            if challenge != nil {
                
                showNavBar(withTitle: "Edit Challenge")
                isCreateMode = false
                postButton.setTitle("Save", for: .normal)
                if let urlString = challenge?.linkURL, let url = URL(string: urlString) {
                
                    selectedLink = url
                
                }
                
                hasLink = selectedLink != nil
                return
                
            }
            
            dismiss(animated: true, completion: nil)
            return
            
        }
        
        hasLink = selectedLink != nil
        postButton.setTitle("Post", for: .normal)
        isCreateMode = true
        showNavBar(withTitle: "CHALLENGE YOUR FRIENDS")
        
    }
    
    private func searchButtonTapped() {
        
        previewCell?.endEditting()
        
        AnalyticsManager.CreateChallenge.trackEditChallengeSearchPressed()
        if let vc = R.storyboard.inviteFriends.searchMaverickViewControllerId() {
            
            vc.delegate = self
            vc.showInviteButton = false
            vc.services = services
            self.navigationController?.pushViewController(vc, animated: true)
            return
            
        }
        
    }
    private func configureSignal() {
        
        services?.globalModelsCoordinator.onChallengeUploadCompletedSignal.subscribe(with: self) {[weak self] (error, challenge, localIdent, shareChannels) in
            
            if let error = error {
                
                DispatchQueue.main.async {
                    let message = "Could not upload Challenge : \(error)"
                    AnalyticsManager.CreateChallenge.trackCreateFail(apiFailure: true, reason: message)
                    self?.navigationController?.view.makeToast(message)
                    self?.navigationController?.popViewController(animated: true)
                }
                return
                
            }
            
            if let challenge = challenge {
                
                AnalyticsManager.CreateChallenge.trackCreateChallengeSuccess(challengeId: challenge.challengeId, hasPhoto: self?.hasPhoto ?? false, themeName: self?.themeName ?? "", charCount: self?.charCount ?? 0, mentions: self?.selectedUserNames.count ?? 0, hasTitle: self?.previewCell?.challengeTitleField.text?.count ?? 0 > 0, hasLink: self?.selectedLink != nil , hasDescription: self?.previewCell?.challengeDescriptionTextView.text.count ?? 0 > 0)
                
            }
            
            DispatchQueue.main.async {
                
                
                self?.challenge = challenge
                self?.progressBar.isHidden = true
                self?.successView.isHidden = false
                self?.uploadingText.isHidden = true
                self?.dismiss()
            }
            
        }
        services?.globalModelsCoordinator.onChallengeUploadProgressSignal.subscribe(with: self) { [weak self]  (progress) in
            
            DispatchQueue.main.async {
                
                self?.progressBar.setProgress(Float(progress / 100.0), animated: true)
                
            }
            
        }
        
    }
    
    private func configureData() {
        
        guard let loggedInUser = services?.globalModelsCoordinator.loggedInUser else { return }
        
        users = []
        
        
        for user in loggedInUser.suggestedUsers {
            
            if !users.contains(user) {
                
                users.append(user)
                
            }
            
        }
        
        
       
        
    }
    
    private func upload() {
        
        guard let image = image else { return }
        
        if let previewCell = previewCell, let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first, let data = UIImageJPEGRepresentation(image, 1.0) {
            
            let filename = documentsUrl.appendingPathComponent("createdChallenge.jpg")
            try? data.write(to: filename)
            progressContainerView.isHidden = false
            collectionView.scrollToTop(animated: true)
            
            services?.globalModelsCoordinator.uploadChallenge(withFileURL: filename, title: previewCell.challengeTitleField.text, description: previewCell.challengeDescriptionTextView.text, mentions: selectedUserNames, coverImage: nil, imageText: imageText,linkUrl: selectedLink?.absoluteString, type: .image, sessionId: "1234")
            
        }
        
    }
    
    private func updateChallenge() {
        
        guard let challenge = challenge else { return }
        fetchPreviewCell()
        services?.globalModelsCoordinator.editChallenge(challengeId: challenge.challengeId, title: previewCell?.challengeTitleField.text, mentions: selectedUserNames, description: previewCell?.challengeDescriptionTextView.text,
                                                        linkUrl: selectedLink?.absoluteString,
                                                        completionHandler: { (error) in
            self.isSaving = false
            if let error = error {
                
                self.view.makeToast("Could not save Challenge : \(error.localizedDescription)")
                return
                
            }
            if let challenge = self.challenge {
                
                AnalyticsManager.CreateChallenge.trackEditChallengeSave(challengeId: challenge.challengeId, mentions: self.selectedUserNames.count, hasTitle: self.previewCell?.challengeTitleField.text?.count ?? 0 > 0, hasLink: self.selectedLink != nil , hasDescription: self.previewCell?.challengeDescriptionTextView.text.count ?? 0 > 0)
                
            }
            
            self.dismiss()
            
        })
        
        
    }
    private func loadUpExistingMentions() {
        
        guard let challenge = challenge else { return }
        for userId in challenge.mentionUserIds {
            
            if let username = services?.globalModelsCoordinator.getUser(withId: userId).username {
                
                selectedUserNames.append(username)
                
            }
            
        }
        
    }
    
    private func dismiss() {
        
        if self.isCreateMode {
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25, execute: {
                
                self.dismiss(animated: true)
                
            })
            
            return
            
        }
        
        self.dismiss(animated: true)
        
        
    }
    
    private func fetchPreviewCell() {
        
        if previewCell == nil {
            
            if let preview =
                collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? EditChallengePreviewCollectionViewCell {
                
                previewCell = preview
                
            }
            
        }
        
    }
    
    private func validateFields() -> Bool {
        
        fetchPreviewCell()
        
        if let previewCell = previewCell  {
            
            if  previewCell.validate() {
                
                return true
                
            } else {
                
                collectionView.scrollToTop(animated: true)
                return false
                
            }
            
        }
        
        return false
        
    }
    
    override func backButtonTapped(_ sender: Any) {
        
        guard !isSaving else { return }
        
        if isCreateMode {
            
            navigationController?.popViewController(animated: true)
            return
            
        }
        
        AnalyticsManager.CreateChallenge.trackEditChallengeClose()
        dismiss()
        
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        guard validateFields() else {
            
            AnalyticsManager.CreateChallenge.trackCreateFail(apiFailure: false, reason: "Title Required")
            return
            
        }
        
        guard !isSaving else { return }
        
        
        isSaving = true
        if isCreateMode {
            
            upload()
            
        } else {
            
            updateChallenge()
            
        }
        
        
    }
    
    private var isSaving = false
    
    
}


extension EditChallengeViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if section == 0 || section == 2 {
            
            return CGSize.zero
            
        }
        
        return CGSize(width: collectionView.frame.width , height: 48)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
       
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if let header  = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: R.reuseIdentifier.editChallengeCollectionHeaderId, for: indexPath){
            
            header.delegate = self
            return header
            
        }
        
        
        
        return UICollectionReusableView()
        
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 3
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0 || section == 2 {
            
            if  section == 0 && hasLink {
                
                return 2
            
            }
            
            return 1
            
        }
        
        return users.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0.0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0.0
        
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        fetchPreviewCell()
        if let preview = previewCell {
            
            collectionView.bringSubview(toFront: preview)
            
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            
            if indexPath.row == 0, let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.editChallengePreviewCollectionViewCellId,
                                                             for: indexPath) {
                
                cell.delegate = self
                cell.configure(with: image, imageMedia: challenge?.mainImageMedia ?? challenge?.imageChallengeMedia, title: previewCell?.challengeTitleField.text ?? challenge?.title, description: previewCell?.challengeDescriptionTextView.text ?? challenge?.label, hasLink: hasLink, isVerified: services?.globalModelsCoordinator.loggedInUser?.isVerified ?? false)
                
                
                let linkAvailable = services?.globalModelsCoordinator.isRewardAvailable(rewardKey: .linkChallenge)?.completed ?? false
                
                if !linkAvailable {
                    
                    cell.setLinkVisibility(visible: false)
                    
                }
                
                return cell 
                
            }
            
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.linkViewCollectionViewCellId,
                                                             for: indexPath) {
                
                cell.configure(with: selectedLink, delegate : self)
                return cell
                
            }
            
        }
        
        if indexPath.section == 2 {
            
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.inviteFriendsCollectionViewCellId,
                                                             for: indexPath) {
                
                return cell
                
            }
            
        }
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.horizontalUserViewId,
                                                      for: indexPath)!
        
        if let user = users[safe : indexPath.row] {
            
            cell.configureView(with: user, selected: selectedUserNames.contains(user.username ?? ""))
            
        } else {
            
            cell.configureView(with: nil)
            
        }
        
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if let preview = cell as? EditChallengePreviewCollectionViewCell {
            
            preview.endEditting()
            previewCell = preview
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
            return CGSize(width: collectionView.frame.width, height : 172)
            } else {
                
                
                if !largeLinkContainer {
                    
                    return CGSize(width: collectionView.frame.width, height : 60)
                    
                } else {
                    
                     return CGSize(width: collectionView.frame.width, height : 150)
                    
                }
                
            }
            
            
        }
        
        if indexPath.section == 2 {
            
            return CGSize(width: collectionView.frame.width, height : 100)
            
        }
        
        return CGSize(width: collectionView.frame.width / 3, height: 100)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        previewCell?.endEditting()
        
        if let _ = collectionView.cellForItem(at: indexPath) as? InviteFriendsCollectionViewCell {
            
            AnalyticsManager.CreateChallenge.trackEditChallengeInvitePressed()
            performSegue(withIdentifier: R.segue.editChallengeViewController.inviteFriendsSegue, sender: self)
            return
            
        }
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? HorizontalUserView, let username = cell.user?.username else { return }
        
        cell.setSelected( selected: !cell.selectedButton.isSelected)
        if cell.selectedButton.isSelected {
            
            if !selectedUserNames.contains(username) {
                
                selectedUserNames.append(username)
                
            }
            
        } else {
            
            if let index = selectedUserNames.index(of: username) {
                
                selectedUserNames.remove(at: index)
                
            }
            
        }
        
    }
    
}



extension EditChallengeViewController : SearchMaverickViewControllerDelegate {
    
    func isUserSelected(users: User) -> Bool {
        
        return selectedUserNames.index(of: users.username ?? "") != nil
        
    }
    
    
    func didSelectFollowToggleButton(forUserId id: String, follow: Bool) {
        
        if let userToUpdate = services?.globalModelsCoordinator.getUser(withId: id), let username = userToUpdate.username {
            
            if follow {
                
                if !selectedUserNames.contains(username) {
                    
                    selectedUserNames.insert(username, at: 0)
                    
                }
                if let index = users.index(of: userToUpdate) {
                    
                    users.remove(at: index)
                    
                }
                
                users.insert(userToUpdate, at: 0)
                
            } else {
                
                if let index = selectedUserNames.index(of: username){
                    
                    selectedUserNames.remove(at: index)
                    
                }
                
            }
            
        }
        
    }
    
    func didSelectProfileButton(forUserId id: String) {
        
        return
        
    }
    
}

class LoadingLabel: UILabel {
    
    var timer: Timer?
    var states = ["Uploading.", "Uploading..", "Uploading..."]
    var currentState = 0
    
    func start() {
        stop(withText: "")
        
        timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        timer?.fire()
    }
    
    func stop(withText text: String) {
        timer?.invalidate()
        timer = nil
        
        self.text = text
    }
    
    @objc func update() {
        text = states[currentState]
        currentState = (currentState + 1) % states.count
    }
    
}

extension EditChallengeViewController : EditChallengeCollectionHeaderDelegate {
    
    func searchTapped() {
        
        searchButtonTapped()
        
    }
    
}

extension EditChallengeViewController : EditChallengePreviewDelegate {
    
    func addLinkTapped() {
    
        AnalyticsManager.CreateChallenge.trackEditChallengeCreateLinkPressed()
        hasLink = true
        collectionView.reloadData()
        
    }
    
    
}

extension EditChallengeViewController : LinkViewDelegate {
    
    func commitToLink() {
     
    }
    
    
    func linkUpdated(url : URL?, bottomExpanded : Bool ) {
     
        if url == nil {
     
            AnalyticsManager.CreateChallenge.trackEditChallengeClearLinkPressed()
        
        }
        largeLinkContainer = bottomExpanded
        selectedLink = url
        collectionView.reloadData()
        
    }
    
}
