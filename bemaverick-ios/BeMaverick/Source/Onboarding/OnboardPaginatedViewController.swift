//
//  OnboardPaginatedViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 4/26/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation

class OnboardPaginatedViewController : PagerViewController {
    
    
    private var vcs : [UIViewController]?
    override func orderedViewControllers() -> [UIViewController] {
        
        if vcs == nil {
            vcs = [self.newViewController(R.image.maverick_BrandMark_Stacked(), width: 200),
                   self.newViewController(R.image.onboard_screen1(), background: R.image.launch_portrait_background()),
                   self.newViewController(R.image.onboard_screen2(), background: R.image.launch_portrait_background()),
                   self.newViewController(R.image.onboard_screen3(), background: R.image.launch_portrait_background()),
                   self.newViewController(R.image.onboard_screen4(), background: R.image.launch_portrait_background())]
        }
        return vcs ?? []
    }
    
    private func newViewController(_ image: UIImage?, width : CGFloat? = nil, background : UIImage? = nil) -> UIViewController {
        
        if let vc = R.storyboard.onboarding.onboardPageId() {
            vc.configure(with : image, width : width, background : background)
            return vc
        }
        
        return UIViewController()
    }
    
}
