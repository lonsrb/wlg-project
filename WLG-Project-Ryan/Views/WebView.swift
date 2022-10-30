//
//  WebView.swift
//  WLG-Project-Ryan
//
//  Created by Ryan Lons on 10/29/22.
//

import Foundation
import SwiftUI
import WebKit

//there is no SwiftUI Webview so we have to wrap the UIKit one to use it
struct WebView: UIViewRepresentable {
    var url: URL
 
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
 
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
