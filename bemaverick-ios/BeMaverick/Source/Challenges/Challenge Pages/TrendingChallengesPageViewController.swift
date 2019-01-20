//
//  TrendingChallengesPageViewController.swift
//  Maverick
//
//  Created by Chris Garvey on 8/3/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//


class TrendingChallengesPageViewController: ChallengesPageViewController {
    
    var versionNumber = 0
    
    override func viewDidLoad() {
        
        streamDelegate = self
        super.viewDidLoad()
        
    }
    
    override func trackScreen() {
        
        AnalyticsManager.trackScreen(location: self, withProperties: ["version":versionNumber])
        
    }
    
    override func getEmptyTitle() -> String {
        
        return "Check Back Soon!"
        
    }
    
    override func getEmptySubTitle() -> String {
        
        return "We're doing some number crunching to determine the trending challenges!"
        
    }
    
}

extension TrendingChallengesPageViewController: StreamRefreshControllerDelegate {
    
    func getMainSectionItemCount() -> Int {
        
        return getItemCount()
        
    }
    
    func refreshDataRequest() {
        
        services.globalModelsCoordinator.getTrendingChallenges(versionNumber: versionNumber, forceRefresh: true) {[weak self] (error) in
            self?.refreshCompleted()
        }
        
    }
    
    func configureData() {
        
        challenges = services.globalModelsCoordinator.getTrendingChallenges(versionNumber: versionNumber, forceRefresh: false)
        
        updateNotification = challenges.observe { [weak self] changes in
            
            guard self?.isVisible ?? false else { return }
            DispatchQueue.main.async {
                
                self?.collectionView.reloadData()
                self?.collectionView.layoutIfNeeded()
                
            }
            
            
        }
        
        refreshCompleted()
        
    }
    
    func loadNextPageRequest() {
        
        let _ = services.globalModelsCoordinator.getTrendingChallenges(versionNumber: versionNumber, forceRefresh: true, offset: challenges.count) {[weak self] (error) in
            
            self?.nextPageLoadCompleted()
            
        }
        
    }
    
}
