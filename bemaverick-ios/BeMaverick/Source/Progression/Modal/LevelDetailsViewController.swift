//
//  LevelDetailsViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 9/19/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation


class LevelDetailsViewController : DismissableViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var levelTitleLabel: UILabel!
    @IBOutlet weak var levelImageView: UIImageView!
    @IBOutlet weak var levelCountLabel: UILabel!
    @IBOutlet weak var levelSummaryLabel: UILabel!
    @IBOutlet weak var levelSuggestions: UILabel!
    @IBOutlet weak var levelRewards: UILabel!
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    private var level : Level?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        configureView()
       
    }
    
    private func configureView() {
        
        guard let level = level else { return }
        view.backgroundColor = UIColor(rgba: "F5F5F5")
        backgroundImage.isHidden = true
        closeButton.tintColor  = UIColor.MaverickBadgePrimaryColor
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.spellOut
        let num = NSNumber(value: level.levelNumber)
        levelTitleLabel.text =  "Level \(formatter.string(from: num) ?? "0")".uppercased()
        levelCountLabel.text = "\(level.levelNumber)"
        levelSummaryLabel.text = level.levelSummary
        levelSuggestions.text = level.levelProgressionSuggestion
        levelRewards.text = level.levelRewards
        
    }
    
    func configure(with level : Level) {
        
        self.level = level
        
    }
    
}
