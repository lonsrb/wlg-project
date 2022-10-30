//
//  DetailsView.swift
//  WLG-Project-Ryan
//
//  Created by Ryan Lons on 10/29/22.
//

import Foundation
import SwiftUI
import WebKit

struct DetailsView: View {
    var url: URL
    
    var body: some View {
        WebView(url: url)
    }
}
