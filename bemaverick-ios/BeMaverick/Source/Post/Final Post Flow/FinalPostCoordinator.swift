//
//  FinalPostCoordinator.swift
//  Maverick
//
//  Created by Chris Garvey on 8/8/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//


protocol FinalPostCoordinatorDelegate: class {
    func finalPostCoordinatorDidPressBackButton()
    func finalPostFlowHasClosed()
}

class FinalPostCoordinator: PostCoordinator {
    
    // MARK: - Public Properties
    /// The delegate for the Final Post Coordinator.
    weak var finalPostCoordinatorDelegate: FinalPostCoordinatorDelegate?
    
    
    // MARK: - Private Properties
    /// The navigation controller that acts as the root view controller for the final post flow.
    private weak var rootViewController: UINavigationController!
    /// The camera manager object for the final post flow.
    private var cameraManager: CameraManager!
    /// The challenge id for the final post flow.
    private var challengeId: String?
    /// The challenge title for the final post flow.
    private var challengeTitle: String?
    /// The MaverickComposition object for the final post flow.
    private var maverickComposition: MaverickComposition!
    /// The production state for the final post flow.
    private var productionState: Constants.UploadResponseType!
    /// The final post view controller for the final post flow.
    private var finalPostViewController: FinalPostViewController?
    /// The final post view model that is used by the final post view controller for the final post flow.
    private var finalPostViewModel: FinalPostViewModel?
    /// The final post change cover view controller for the final post flow.
    private var finalPostChangeCoverViewController: FinalPostChangeCoverViewController?
    
    
    // MARK: - Lifecycle
    
    init(navigationController: UINavigationController, cameraManager: CameraManager, challengeId: String?, challengeTitle: String?, maverickComposition: MaverickComposition, productionState: Constants.UploadResponseType) {
        
        self.rootViewController = navigationController
        self.cameraManager = cameraManager
        self.challengeId = challengeId
        self.challengeTitle = challengeTitle
        self.maverickComposition = maverickComposition
        self.productionState = productionState
        
    }
    
    deinit {
        log.verbose("💥")
    }
    
    
    // MARK: - Public Methods
    
    /**
     Start the final post flow.
     */
    public func start() {
        
        finalPostViewModel = FinalPostViewModel(coordinator: self, cameraManager: cameraManager, challengeId: challengeId, challengeTitle: challengeTitle, maverickComposition: maverickComposition, productionState: productionState)
        finalPostViewController = FinalPostViewController(viewModel: finalPostViewModel!)
        finalPostViewModel!.finalPostViewModelVideoDelegate = finalPostViewController!
        
        rootViewController.pushViewController(finalPostViewController!, animated: true)
        
    }
    
    /**
     Inform other objects that the user has changed the cover image.
     */
    public func didUpdateCoverImage() {
        finalPostViewModel?.updateCoverImage()
    }
    
    /**
     Return to the edit flow.
     */
    public func backButtonTapped() {
        
        rootViewController?.popViewController(animated: true)
        finalPostCoordinatorDelegate?.finalPostCoordinatorDidPressBackButton()
        
    }
    
    /**
     Return to the flow prior to starting the final post flow.
     */
    public func finalPostFlowHasClosed() {
        
        rootViewController?.popViewController(animated: true)
        finalPostCoordinatorDelegate?.finalPostFlowHasClosed()
        
    }
    
    /**
     Launch the view controller to change the cover image.
     */
    public func changeCoverButtonTapped() {
        
        finalPostChangeCoverViewController = FinalPostChangeCoverViewController(coordinator: self, cameraManager: cameraManager, challengeId: challengeId, maverickComposition: maverickComposition, productionState: productionState)
        launchModal(forViewController: finalPostChangeCoverViewController!)
        
    }
    
    
    // MARK: - Private Methods
    
    /**
     Launch a model from the final post flow root view controller.
     */
    private func launchModal(forViewController viewController: UIViewController) {
        rootViewController.present(viewController, animated: true, completion: nil)
    }
    
}
