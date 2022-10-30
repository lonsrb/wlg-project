//
//  WLG_Project_RyanApp.swift
//  WLG-Project-Ryan
//
//  Created by Ryan Lons on 10/28/22.
//

import SwiftUI

@main
struct WLG_Project_RyanApp: App {
    
    init() {
        ApplicationConfiguration.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            SearchView()
        }
    }
}
