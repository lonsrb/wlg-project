//
//  SearchView.swift
//  WLG-Project-Ryan
//
//  Created by Ryan Lons on 10/28/22.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = PointsViewModel(pointsService: ApplicationConfiguration.shared.pointService)
    @State private var resultsView: ResultsViewSection = .list
  
    enum ResultsViewSection : String, CaseIterable {
        case list = "List"
        case map = "Map"
    }
    
    var body: some View {
        VStack {
            Text("Hello, World!")
            
            Picker("Search results", selection: $resultsView) {
                ForEach(ResultsViewSection.allCases, id: \.self) { option in
                    Text(option.rawValue)
                }
            }
            .pickerStyle(.segmented)
            
            NavigationView {
                if resultsView == .map {
                    MapView(pointViewModel: viewModel)
                }
                else {
                    ListView(pointViewModel: viewModel)
                }
            }
        }
        .onAppear{
            viewModel.fetch()
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
