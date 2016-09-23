//
//  ViewController.swift
//  WKWebView+postMessage
//
//  Created by Freek Zijlmans on 23-09-16.
//  Copyright © 2016 FrZi. All rights reserved.
//

import UIKit
import WebKit

final class ViewController: UIViewController {

    private var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create script message handlers.
        let contentController = WKUserContentController()
        
        // This will inject an `actionSheet` messageHanlder into the Javascript. Calling it will show a native
        // actionsheet, with Strings parsed by the Javascript.
        contentController.add(WKFormMessageHandler { message in
            // Get the Javascript parsed parameters.
            if let body = message.body as? [String : Any],
                let title = body["title"] as? String,
                let options = body["options"] as? [String]
            {
                let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
                
                // Dummy options.
                for option in options {
                    alert.addAction(UIAlertAction(title: option, style: .default, handler: nil))
                }
                
                self.present(alert, animated: true, completion: nil)
            }
            
        }, name: "actionSheet")
        
        // Config.
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        // WebView
        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(webView)
        
        // Load the HTML.
        if let htmlPath = Bundle.main.path(forResource: "index", ofType: "html"),
            let htmlString = try? String(contentsOfFile: htmlPath)
        {
            webView.loadHTMLString(htmlString, baseURL: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    
    // MARK: -
    /// A custom class that simply holds a function/handler.
    private final class WKFormMessageHandler: NSObject, WKScriptMessageHandler {
        
        private var handler: (WKScriptMessage) -> ()
        
        init(handler: @escaping (WKScriptMessage) -> ()) {
            self.handler = handler
            super.init()
        }
        
        @objc fileprivate func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            handler(message)
        }
        
    }
    
}

