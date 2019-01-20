//
//  WebContentViewController.swift
//  Maverick
//
//  Created by Chris Garvey on 4/19/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import WebKit

class WebContentViewController: ViewController, WKNavigationDelegate {
    
    // MARK: - Private Properties
    
    private let webView: WKWebView
    private let request: URLRequest
    private let webViewTitle: String
    
    
    // MARK: - Life Cycle
    
    init(url: URL, webViewTitle: String) {
        
        request = URLRequest(url: url)
        webView = WKWebView(frame: .zero)
        self.webViewTitle = webViewTitle
        
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = webView
    }
    
    override func viewDidLoad() {
        
        hasNavBar = true
        super.viewDidLoad()

        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapDoneButton(sender:)))
        navigationItem.rightBarButtonItem = doneButton
        
        webView.navigationDelegate = self
        webView.isOpaque = false
        webView.backgroundColor = .white
     
        showNavBar(withTitle: "Loading...")
        webView.load(request)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: R.image.back_purple(),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(backButtonTapped(_:)))
        
        navigationItem.leftBarButtonItem?.tintColor = UIColor.MaverickBadgePrimaryColor
        
    }

    override func backButtonTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    
    }
    
    // MARK: - Private Functions
    
    @objc private func didTapDoneButton(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Delegate Function
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        DispatchQueue.main.async {
            
            self.showNavBar(withTitle: self.webViewTitle)
            
        }
        
    }

}
