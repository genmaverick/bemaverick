//
//  WebViewController.swift
//  Maverick
//
//  Created by Garrett Fritz on 9/12/18.
//  Copyright © 2018 BeMaverick. All rights reserved.
//

import Foundation
import WebKit

class WebViewController : ViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mainView: UIView!
    private var webView: WKWebView?
    
    var linkUrl : URL? = nil
    var webBackButton : UIBarButtonItem?
    var webForwardButton : UIBarButtonItem?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         tabBarController?.setTabBarVisible(visible: false, duration: 0.0, animated: false)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: false)
         tabBarController?.setTabBarVisible(visible: true, duration: 0.0, animated: false)
        
    }
    @objc func toolbarBack() {
        
        if  webView?.canGoBack ?? false {
            webView?.goBack()
        }
    }
    @objc func toolbarForward() {
        
        if  webView?.canGoForward ?? false {
            webView?.goForward()
        }
    }
    override func viewDidLoad() {
        hasNavBar = true
         tabBarController?.setTabBarVisible(visible: false, duration: 0.0, animated: false)
        
        navigationController?.setToolbarHidden(false, animated: false)
        
        var items = [UIBarButtonItem]()
        
        webBackButton = UIBarButtonItem(image: R.image.back_purple(), style: .plain, target: self, action: #selector(toolbarBack))
        items.append(webBackButton!)
        webForwardButton = UIBarButtonItem(image: R.image.forward_purple(), style: .plain, target: self, action: #selector(toolbarForward))
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        items.append(webForwardButton!)
        
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        toolbarItems = items
        webForwardButton?.isEnabled = false
        webBackButton?.isEnabled = false
        hidesBottomBarWhenPushed = true
        
        super.viewDidLoad()
        webView = WKWebView(frame: CGRect.zero)
        guard let webView = webView else { return }
        mainView.addSubview(webView)
        webView.autoPinEdgesToSuperviewEdges()
        webView.navigationDelegate = self
        
        if let linkUrl = linkUrl {
        
            webView.load(URLRequest(url: linkUrl))
        
        }
        webView.allowsBackForwardNavigationGestures = true
    }
}

extension WebViewController : WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        
        webForwardButton?.isEnabled = webView.canGoForward
        webBackButton?.isEnabled = webView.canGoBack
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("🎥 did finnish")
        activityIndicator.stopAnimating()
    }
  
}
