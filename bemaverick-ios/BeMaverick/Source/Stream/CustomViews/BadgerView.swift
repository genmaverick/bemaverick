//
//  BadgerView.swift
//  Maverick
//
//  Created by Garrett Fritz on 2/22/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import Kingfisher

protocol BadgerViewDelegate : class {
    
    func badgeSelected(badge : MBadge, isSelected : Bool)

}
class BadgerView : UIView {
    // MARK: - IBOutlets
    
    @IBOutlet weak var rankHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var rankWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstant: NSLayoutConstraint!
    @IBOutlet weak var widthConstant: NSLayoutConstraint!
    /// Parent view
    @IBOutlet weak var view: UIView!
    /// creative button
    @IBOutlet weak var firstButton: UIButton!
    /// unique button
    @IBOutlet weak var thirdButton: UIButton!
    /// daring button
    @IBOutlet weak var secondButton: UIButton!
    /// unstoppable button
    @IBOutlet weak var fourthButton: UIButton!
    /// Percent holder for this badge
    @IBOutlet weak var firstRankView: UIView!
    /// Percent holder for this badge
    @IBOutlet weak var secondRankView: UIView!
    /// Percent holder for this badge
    @IBOutlet weak var thirdRankView: UIView!
    /// Percent holder for this badge
    @IBOutlet weak var fourthRankView: UIView!
    /// Bottom space to lower two badges
    @IBOutlet weak var bottomGroupConstraint: NSLayoutConstraint!
    /// Bottom space to upper two badges
    @IBOutlet weak var topButtonsBottomConstraint: NSLayoutConstraint!
    /// Horizontal Spacing between top two badges
    @IBOutlet weak var topCenterHorizontalSpacingConstraint: NSLayoutConstraint!
    /// Horizontal Spacing Top and bottom badges
    @IBOutlet weak var rightHorizontalSpacingContraint: NSLayoutConstraint!
    /// Horizontal Spacing Top and bottom badges
    @IBOutlet weak var leftHorizontalSpacingConstraint: NSLayoutConstraint!
    
    // MARK: - IB Actions
    
    
    /**
     Dismiss view on empty space tap
     */
    @IBAction func backgroundTapped(_ sender: Any) {
        
        collapsed = true
        
    }
    
   
    
    /**
     Badge Tapped
     */
    @IBAction func firstTapped(_ sender: Any) {
        
        toggleButton(button: firstButton)
        delegate?.badgeSelected(badge: MBadge.getFirstBadge(), isSelected: firstButton.isSelected)
        
    }
    
    /**
     Badge Tapped
     */
    @IBAction func secondTapped(_ sender: Any) {
        
        toggleButton(button: secondButton)
        delegate?.badgeSelected(badge: MBadge.getSecondBadge(), isSelected: secondButton.isSelected)
        
    }
    
    /**
     Badge Tapped
     */
    @IBAction func thirdTapped(_ sender: Any) {
        
        toggleButton(button: thirdButton)
        delegate?.badgeSelected(badge: MBadge.getThirdBadge(), isSelected: thirdButton.isSelected)
        
    }
    
    /**
     Badge Tapped
     */
    @IBAction func fourthTapped(_ sender: Any) {
        
        toggleButton(button: fourthButton)
        delegate?.badgeSelected(badge: MBadge.getFourthBadge(), isSelected: fourthButton.isSelected)
        
    }
    
    
    // MARK: - Private Properties
    
    /// is collapsed
    private var _collapsed = true
    /// Current selected button
    private var selectedButton : UIButton?
    /// Initial state for constraint
     var topCenterHorizontalSpacingConstraint_initial: CGFloat = 15
    /// Initial state for constraint
     var bottomGroupConstraint_initial: CGFloat = 20
    /// Initial state for constraint
     var topButtonsBottomConstraint_initial: CGFloat = -10
    /// Initial state for constraint
     var leftHorizontalSpacingConstraint_initial: CGFloat  = -5
    /// Initial state for constraint
     var rightHorizontalSpacingContraint_initial: CGFloat  = -5
    /// local count of badges, helpful for tweak values
    private var secondCount = 0
    /// local count of badges, helpful for tweak values
    private var thirdCount = 0
    /// local count of badges, helpful for tweak values
    private var firstCount = 0
    /// local count of badges, helpful for tweak values
    private var fourthCount = 0
    /// percentage to show in rank view
    private var secondPercent: CGFloat = 0.25
    /// percentage to show in rank view
    private var firstPercent: CGFloat = 0.25
    /// percentage to show in rank view
    private var thirdPercent: CGFloat = 0.25
    /// percentage to show in rank view
    private var fourthPercent: CGFloat = 0.25
    /// doubly linked list to help cascade through reveal animation of ranks
    private let badgeRevealList = LinkedList<UIView>()
    /// selected state
    private var selectedBadge : MBadge? = nil
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        setup()
        
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        setup()
        
    }
    
    func setSize(small : Bool) {
        
        widthConstant.constant = small ? 70 : 80
        heightConstant.constant = small ? 70 : 80
   
        rankHeightConstraint.constant = small ? 30 : 36
        rankWidthConstraint.constant = small ? 30 : 36
        
        styleButton(button: firstButton)
        styleButton(button: secondButton)
        styleButton(button: thirdButton)
        styleButton(button: fourthButton)
        
    }
    
    func setup() {
        
        view = instanceFromNib()
        addSubview(view)
        view.frame = self.bounds
        view.backgroundColor = UIColor.clear
        
        styleButton(button: firstButton)
        styleButton(button: secondButton)
        styleButton(button: thirdButton)
        styleButton(button: fourthButton)
        
        firstButton.tag = 0
        secondButton.tag = 1
        thirdButton.tag = 2
        fourthButton.tag = 3
        
        firstButton.imageView?.contentMode = .scaleAspectFit
        secondButton.imageView?.contentMode = .scaleAspectFit
        thirdButton.imageView?.contentMode = .scaleAspectFit
        fourthButton.imageView?.contentMode = .scaleAspectFit
        
        topCenterHorizontalSpacingConstraint_initial = topCenterHorizontalSpacingConstraint.constant
        bottomGroupConstraint_initial = bottomGroupConstraint.constant
        topButtonsBottomConstraint_initial = topButtonsBottomConstraint.constant
        leftHorizontalSpacingConstraint_initial = leftHorizontalSpacingConstraint.constant
        rightHorizontalSpacingContraint_initial = rightHorizontalSpacingContraint.constant
        
        badgeRevealList.append(value: firstRankView)
        badgeRevealList.append(value: secondRankView)
        badgeRevealList.append(value: thirdRankView)
        badgeRevealList.append(value: fourthRankView)
        
        BadgerView.setBadgeImage(badge: MBadge.getFirstBadge(), primary: true, button: firstButton, for: .normal)
        BadgerView.setBadgeImage(badge: MBadge.getSecondBadge(), primary: true, button: secondButton, for: .normal)
        BadgerView.setBadgeImage(badge: MBadge.getThirdBadge(), primary: true, button: thirdButton, for: .normal)
        BadgerView.setBadgeImage(badge: MBadge.getFourthBadge(), primary: true, button: fourthButton, for: .normal)
        
        collapse(skipAnimation: true)
        _collapsed = true
        
    }
    
    func instanceFromNib() -> UIView {
        
        return R.nib.badgerView.firstView(owner: self)!
        
    }
    
    
    
    // MARK: - Public Properties
    
    /// tap delgate
    weak var delegate: BadgerViewDelegate?
    
    var collapsed: Bool {
        get {
            return _collapsed
        }
        set {
            if newValue {
                collapse()
            } else {
                explode()
                
            }
            _collapsed = newValue
        }
    }
    
    // MARK: - Public Methods
    
    func getSelectedColor() -> UIColor {
     
        guard let color = selectedBadge?.color else { return UIColor.MaverickUnselectedBadgeButton }
       
        return UIColor(rgba: color) ?? UIColor.MaverickUnselectedBadgeButton
        
    }
    /**
     Seed this view with selected / deselected state
     */
    func setSelected(badge: MBadge?) {
        
        selectedBadge = badge
        selectedButton?.backgroundColor = UIColor.MaverickUnselectedBadgeButton
        selectedButton?.isSelected = false
        
        
        guard let selectedBadge = selectedBadge, let selectedOrder = MBadge.getIndex(ofBadge: selectedBadge) else {
            
            selectedButton = nil
            return
            
        }
        
        switch selectedOrder {
            
        case 0:
            selectedButton = firstButton
            
        case 1:
            selectedButton = secondButton
        case 2:
            selectedButton = thirdButton
        case 3:
            selectedButton = fourthButton
        default:
            return
            
        }
        
        selectedButton?.isSelected = true
        selectedButton?.backgroundColor = getSelectedColor()
        
    }
    
    /**
     Returns the badge that is selected or nil if none
     */
    func isItemSelected() -> MBadge? {
        
        guard let selectedButton = selectedButton else { return nil }
        
        return MBadge.getBadge(byIndex: selectedButton.tag)
        
    }
    
    // MARK: - Private Methods
    
    /**
     Remove 1 count for previously selected badge
     */
    private func decrementSelectedBadge() {
        
        if let tag = selectedButton?.tag {
            
            let badge = MBadge.getBadge(byIndex:  tag)
            tweakValue(forBadge: badge, withValue: -1)
        
        }
        
    }
    
    /**
     Add 1 count for new selected badge
     */
    private func incrementNewBadge(badge : MBadge) {
       
        tweakValue(forBadge: badge, withValue: 1)
        
    }
    
    /**
     Utility function called by all tap events
     */
    private func toggleButton(button : UIButton) {
        decrementSelectedBadge()
        let badge = MBadge.getBadge(byIndex: button.tag)
        
        selectedBadge = badge
        incrementNewBadge(badge: badge)
        UIView.animate(withDuration: 0.1, animations: {
            
            self.selectedButton?.backgroundColor = .MaverickUnselectedBadgeButton
            self.hideRanks()
            
        }) { (finished) in
            
            self.calculateResults()
            
        }
        
        if selectedButton != button {
            
            selectedButton?.isSelected = false
            selectedButton = button
            
        }
        
        button.isSelected = !button.isSelected
        if button.isSelected {
            
            UIView.animate(withDuration: 0.15, animations: {
                
                button.backgroundColor = self.getSelectedColor()
                button.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                
            }) { (finished) in
                
                UIView.animate(withDuration: 0.25, animations: {
                    
                    button.transform = CGAffineTransform.identity
                    
                    self.revealRanks()
                })
                
            }
            
        } else {
            
            button.backgroundColor = .MaverickUnselectedBadgeButton
            
        }
        
    }
    
    /**
     Expand badges from hidden state
     */
    private func explode () {
        
        setOriginalPositions()
        UIView.animate(withDuration: 0.1) {
            self.alpha = 1
        }
        
        UIView.animate(withDuration: 0.2) {
            self.showButtons()
            if self.isItemSelected() != nil {
                self.showRanks()
            }
        }
        
        UIView.animate(withDuration: 0.35) {
            self.layoutIfNeeded()
            
        }
        
    }
    
    /**
     Collapse badges to hidden state
     */
    private func collapse(skipAnimation : Bool = false) {
        
        guard !skipAnimation else {
            
            hideRanks()
            hideButtons()
            alpha = 0
            setNeedsUpdateConstraints()
            layoutIfNeeded()
            layoutSubviews()
       
            return
       
        }
        
        setCollapsedPositions()
        UIView.animate(withDuration: 0.4) {
            
            self.hideRanks()
            self.hideButtons()
        
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.layoutIfNeeded()
            self.alpha = 0
        
        }) { (finished) in
            
        }
        
    }
    
    /**
     Recursive to show all the ranks as a waterfall sourced from tapped badge
     */
    private func cascadeReveal(node : Node<UIView>?) {
        
        guard let node = node, node.value.alpha == 0 else { return }
        UIView.animate(withDuration: 0.1, animations: {
            
            node.value.alpha = 1
        
        }) { (finished) in
        
            self.cascadeReveal(node: node.next)
            self.cascadeReveal(node: node.previous)
        
        }
    
    }
    
    /**
     Start the waterfall
     */
    private func revealRanks() {
        
        guard let tag = selectedButton?.tag else { return }
        let initialNode = badgeRevealList.nodeAt(index: tag)
        cascadeReveal(node: initialNode)
        
    }
    
    
    /**
     Style up the rank views with calculated values
     */
    private func styleRankViews() {
        
        let firstWins = firstPercent >= secondPercent && firstPercent >= thirdPercent && firstPercent >= fourthPercent
        let secondWins = secondPercent >= firstPercent && secondPercent >= thirdPercent && secondPercent >= fourthPercent
        let thirdWins = thirdPercent >= secondPercent && thirdPercent >= firstPercent && thirdPercent >= fourthPercent
        let fourthWins = fourthPercent >= thirdPercent && fourthPercent >= firstPercent && fourthPercent >= secondPercent
        styleRank(rankView: firstRankView, isWinner: firstWins)
        styleRank(rankView: secondRankView, isWinner: secondWins)
        styleRank(rankView: thirdRankView, isWinner: thirdWins)
        styleRank(rankView: fourthRankView, isWinner: fourthWins)
    
    }
    
    /**
     Style the badge buttons
     */
    private func styleButton(button: UIButton) {
        
        button.backgroundColor = UIColor.MaverickUnselectedBadgeButton
        button.layer.cornerRadius = heightConstant.constant / 2
        button.addShadow()
        
    }
    
    /**
     Initialize rank styles
     */
    private func styleRank(rankView: UIView, isWinner : Bool) {
        
         rankView.backgroundColor = isWinner ? UIColor.MaverickPrimaryColor : UIColor.white
        rankView.layer.borderColor = isWinner ? UIColor.white.cgColor : UIColor.black.cgColor
        if let label = rankView.subviews[0] as? UILabel {
          
            label.textColor = isWinner ? UIColor.white : UIColor.black
       
        }
       
        rankView.layer.cornerRadius = rankWidthConstraint.constant / 2
        rankView.layer.borderWidth = 2
        rankView.addShadow()
        
    }
    
    
    /**
     Set specific values
     */
    func setValues(first: Int = 1, second: Int = 1, third: Int = 1, fourth: Int = 1) {
        
        firstCount =         first < 0        ? 0 : first
        secondCount =       second < 0      ? 0 : second
        thirdCount =         third < 0        ? 0 : third
        fourthCount =    fourth < 0   ? 0 : fourth
        
        calculateResults()
        
    }
    
    /**
     Increment / decrement values based on new selection
     */
    func tweakValue(forBadge badge: MBadge?, withValue value: Int) {
        
        guard let badge = badge, let sortPosition = MBadge.getIndex(ofBadge: badge) else { return }
        switch sortPosition {
            
        case 0:
            firstCount += value
        case 1:
            secondCount += value
        case 2:
            thirdCount += value
        case 3:
            fourthCount += value
        default:
            break
            
        }
        
        firstCount =         firstCount < 0        ? 0 : firstCount
        secondCount =        secondCount < 0      ? 0 : secondCount
        thirdCount =         thirdCount < 0        ? 0 : thirdCount
        fourthCount =        fourthCount < 0   ? 0 : fourthCount
    }
    
    /**
     Calcultate rankings based on badge counts
     */
    private func calculateResults() {
        
        let total = CGFloat(firstCount + secondCount + thirdCount + fourthCount)
        
        if total == 0 {
            
            firstPercent = 0.25
            secondPercent = 0.25
            thirdPercent = 0.25
            fourthPercent = 0.25
        
        } else {
            
            firstPercent = CGFloat(firstCount) / total
            secondPercent = CGFloat(secondCount) / total
            thirdPercent = CGFloat(thirdCount) / total
            fourthPercent = CGFloat(fourthCount) / total
            
        }
        
        if let label = firstRankView.subviews[0] as? UILabel {
      
            let percent = (firstPercent * 100).roundTo(decimalPlaces: 0)
            label.text = ("\(percent)%")
      
        }
        if let label = secondRankView.subviews[0] as? UILabel {
       
            let percent = (secondPercent * 100).roundTo(decimalPlaces: 0)
            label.text = ("\(percent)%")
      
        }
        if let label = thirdRankView.subviews[0] as? UILabel {
       
            let percent = (thirdPercent * 100).roundTo(decimalPlaces: 0)
            label.text = ("\(percent)%")
       
        }
        if let label = fourthRankView.subviews[0] as? UILabel {
       
            let percent = (fourthPercent * 100).roundTo(decimalPlaces: 0)
            label.text = ("\(percent)%")
       
        }
       
        styleRankViews()
   
    }
    
    /**
     Simple hide all rank views
    */
    private func hideRanks() {
        
        firstRankView.alpha = 0
        secondRankView.alpha = 0
        thirdRankView.alpha = 0
        fourthRankView.alpha = 0
    
    }
    
    /**
     Simple show all rank views
    */
    private func showRanks() {
     
        firstRankView.alpha = 1
        secondRankView.alpha = 1
        thirdRankView.alpha = 1
        fourthRankView.alpha = 1
    
    }
    
    /**
     Simple hide all badge buttons
    */
    private func hideButtons() {
        
        firstButton.alpha = 0
        secondButton.alpha = 0
        thirdButton.alpha = 0
        fourthButton.alpha = 0
    
    }
    
    /**
     Simple show all badge buttons
    */
    private func showButtons() {
        firstButton.alpha = 1
        secondButton.alpha = 1
        thirdButton.alpha = 1
        fourthButton.alpha = 1
    }
    
    /**
     Set constraints to expanded positions
    */
    private func setOriginalPositions() {
        
        bottomGroupConstraint.constant = bottomGroupConstraint_initial
        topButtonsBottomConstraint.constant = topButtonsBottomConstraint_initial
        topCenterHorizontalSpacingConstraint.constant = topCenterHorizontalSpacingConstraint_initial
        rightHorizontalSpacingContraint.constant = rightHorizontalSpacingContraint_initial
        leftHorizontalSpacingConstraint.constant = leftHorizontalSpacingConstraint_initial
        
    }
    
    /**
     set all constraints to collapsed positions
    */
    private func setCollapsedPositions() {
        bottomGroupConstraint.constant = -40
        topButtonsBottomConstraint.constant = -80
        topCenterHorizontalSpacingConstraint.constant = -80
        rightHorizontalSpacingContraint.constant = -80
        leftHorizontalSpacingConstraint.constant = -80
    }
    
    static func setBadgeImage(badge : MBadge?, primary : Bool = true, imageView : UIImageView)  {
        
        guard let badge = badge, let path = primary ? badge.primaryImageUrl : badge.secondaryImageUrl , let imageUrl = URL(string: path)  else { return }
        imageView.contentMode = .scaleAspectFit
        imageView.kf.setImage(with: imageUrl)
        
    }
    
    static let badgeOffset : CGFloat = 5.0
    
    static func setBadgeImage(badge : MBadge?, primary : Bool = true, button : UIButton, for state: UIControlState)  {
        
        guard let badge = badge, let path = primary ? badge.primaryImageUrl : badge.secondaryImageUrl , let imageUrl = URL(string: path)  else { return }
        button.imageView?.contentMode = .scaleAspectFit
        if primary {
        
            button.imageEdgeInsets = UIEdgeInsetsMake(
                
                badgeOffset + CGFloat(badge.offsetX) - CGFloat(badge.offsetY),
                badgeOffset + CGFloat(badge.offsetX),
                badgeOffset + CGFloat(badge.offsetX) + CGFloat(badge.offsetY ),
                badgeOffset + CGFloat(badge.offsetX)
            
            )
        
        }
        
        button.kf.setImage(with: imageUrl, for: state)
        
    }
    
}

extension CGFloat {
    
    func roundTo(decimalPlaces: Int) -> String {
    
        return String(format: "%.\(decimalPlaces)f", self)
    
    }

}
