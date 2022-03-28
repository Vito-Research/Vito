//
//  webView.swift
//  Vito
//
//  Created by Andreas Ink on 3/15/22.
//

import Foundation
import WebKit
import UIKit
import SwiftUI
struct WebView: UIViewRepresentable {
    typealias UIViewType = WKWebView

    let webView: WKWebView
    
    func makeUIView(context: Context) -> WKWebView {
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
       
    }
}

class WebViewModel: ObservableObject {
    let webView: WKWebView
    let url: URL
    
    init() {
        webView = WKWebView(frame: .zero)
        
        url = URL(string: "https://www.fitbit.com/oauth2/authorize?response_type=token&client_id=2389P9&redirect_uri=https%3A%2F%2Fandreasink.web.app&scope=heartrate%20sleep%20activity&expires_in=2592000")!

        loadUrl()
    }
    
    func loadUrl() {
        webView.load(URLRequest(url: url))
    }
    
}
