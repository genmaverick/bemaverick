//
//  TutorialViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 7/12/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation


class TutorialViewController : ViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var container_0: UIView!
    @IBOutlet weak var titleLabel_0: UILabel!
    @IBOutlet weak var descriptionLabel_0: UILabel!
    @IBOutlet weak var titleImage_0: UIImageView!
    
    @IBOutlet weak var container_1: UIView!
    @IBOutlet weak var titleImage_1: UIImageView!
    @IBOutlet weak var titleLabel_1: UILabel!
    @IBOutlet weak var descriptionLabel_1: UILabel!
    
    
    @IBOutlet weak var container_2: UIView!
    @IBOutlet weak var titleImage_2: UIImageView!
    @IBOutlet weak var titleLabel_2: UILabel!
    @IBOutlet weak var descriptionLabel_2: UILabel!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    private var tutorialVersion : Constants.TutorialVersion = .myFeed
    
    private func dismiss() {
        
        UIView.animate(withDuration: 0.25, animations: {
            
            self.view.alpha = 0
            
        }) { (result) in
            
            self.dismiss(animated: false, completion: nil)
            
        }
        
    }
    
    @IBAction func areaTapped(_ sender: Any) {
        
        switch tutorialVersion {
        
        case .challenges:
            if pageControl.currentPage == 0 {
            
                pageControl.currentPage = 1
                scrollView.setContentOffset(container_1.frame.origin, animated: true)
            
            } else {
        
                dismiss()
            
            }
        
        case .featured:
            if pageControl.currentPage == 0 {
                
                pageControl.currentPage = 1
                scrollView.setContentOffset(container_1.frame.origin, animated: true)
                
            } else if pageControl.currentPage == 1 {
                
                pageControl.currentPage = 2
                scrollView.setContentOffset(container_2.frame.origin, animated: true)
                
            } else {
                
                dismiss()
                
            }
            
        default:
            dismiss()
        
        }
        
        
        
    }
    
    
    func configureFor(tutorialVersion : Constants.TutorialVersion) {
        
        self.tutorialVersion = tutorialVersion
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.alpha = 0
        pageControl.currentPageIndicatorTintColor = UIColor.MaverickPrimaryColor
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPage = 0
        titleImage_0.tintColor = UIColor.MaverickPrimaryColor
        titleImage_1.tintColor = UIColor.MaverickPrimaryColor
        titleImage_2.tintColor = UIColor.MaverickPrimaryColor
        container_0.isHidden = false
        scrollView.delegate = self
        
        switch tutorialVersion {
            
        case .myFeed:
            
            titleImage_0.image = R.image.nav_home()
            pageControl.isHidden = true
            titleImage_0.isHidden = false
            titleLabel_0.text = "This is your feed"
            descriptionLabel_0.text = "Here’s where you find the latest responses and Challenges from people you follow."
            
            container_1.isHidden = true
            container_2.isHidden = true
            
        case .challenges:
            pageControl.isHidden = false
            pageControl.numberOfPages = 2
            
            titleImage_0.image = R.image.nav_challenges()
            titleImage_0.isHidden = false
            titleLabel_0.text = "This is the Challenge feed"
            descriptionLabel_0.text = "Every Challenge on Maverick can be found here! Browse through them all and keep coming back to see the latest Challenges."
            
            container_1.isHidden = false
            titleImage_1.image = R.image.create_challenge_nav()
            titleImage_1.isHidden = false
            titleLabel_1.text = "Challenge Others"
            descriptionLabel_1.text = "Ready to challenge others? Press the spark icon to create YOUR own challenge and start the conversation."
            
            container_2.isHidden = true
            
        case .featured:
            pageControl.isHidden = false
            pageControl.numberOfPages = 3
            
            titleImage_0.image = R.image.nav_maverick()
            titleImage_0.isHidden = false
            titleLabel_0.text = "This is the Featured screen"
            descriptionLabel_0.text = "This is where you’ll see trending Challenges and content from your fellow Mavericks."
            
            container_1.isHidden = false
            titleImage_1.image = R.image.nav_challenges()
            titleImage_1.isHidden = false
            titleLabel_1.text = "Challenges"
            descriptionLabel_1.text = "This app is ALL about Challenges. Respond to challenges or post your own Challenge to start the conversation!"
            
            container_2.isHidden = false
            titleImage_2.image = R.image.nav_badge()
            titleImage_2.isHidden = false
            titleLabel_2.text = "Badge Responses"
            descriptionLabel_2.text = "Watch other responses to Challenges to get inspired. Like what you see? Give them a badge by tapping the heart icon."
            
        default:
            break
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 0.25) {
            
            self.view.alpha = 1
            
        }
        
    }
    
}

extension TutorialViewController : UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
        
    }
    
}
