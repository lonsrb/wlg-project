//
//  SearchView.swift
//  WLG-Project-Ryan
//
//  Created by Ryan Lons on 10/28/22.
//

import SwiftUI
import CoreLocation
import MapKit

struct SearchView: View {
    @StateObject private var viewModel = PointsViewModel(pointsService: ApplicationConfiguration.shared.pointService)
    @State private var resultsView: ResultsViewSection = .list
    @State var searchInput: String = ""
    @State var showFilters: Bool = false
    @State var isSearching: Bool = false
    @State var selectedFiters: [PointType] = []
    
    enum ResultsViewSection : String, CaseIterable {
        case list = "List"
        case map = "Map"
    }
    
    var body: some View {
        VStack {
            NavigationView {
                VStack(alignment: .leading) {
                    searchView()
                    if showFilters {
                        filtersView()
                    }
                    Divider()
                    segmentedControlView()
                    
                    if resultsView == .map {
                        MapView(pointsViewModel: viewModel)//, region: regionForSearchContext(searchContext: viewModel.searchContext))
                    }
                    else {
                        ListView(pointsViewModel: viewModel)
                    }
                }//ends vstack
            }//ends navigation link
        }//ends vstack
        .onAppear{
            viewModel.searchForPoints(coordinate: viewModel.searchContext.coordinate, queryString: "", selectedFilters: [])
        }
    }
    
    fileprivate func searchView() -> some View {
        return VStack {
            Text("Search Marinas:")
            TextField( "Enter Marina Name", text: $searchInput)
            
            HStack {
                Button {
                    showFilters.toggle()
                } label: {
                    showFilters ? Text("Hide Filter") : Text("Filters")
                }
                Spacer()
                if isSearching {
                    Text("Searching..")
                        .italic()
                }
                else {
                    Button {
                        showFilters = false
                        isSearching = viewModel.isSearching
                        //call search on VM
                        viewModel.searchForPoints(coordinate: nil,//would use this once we add a locaiton button
                                                  queryString: searchInput,
                                                  selectedFilters: selectedFiters)
                    } label: {
                        Text("Search")
                            .padding([.leading, .trailing], 18)
                            .padding([.top, .bottom], 8)
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }//ends search button
                }
            }//ends hstack
        }.padding()
    }
    
    fileprivate func filtersView() -> some View{
        return VStack(alignment: .leading, spacing: 10) {
            Text("Filter by location type").bold()
                
            HStack(spacing: 10) {
                Button {
                    selectedFiters.removeAll()
                    selectedFiters.append(contentsOf: PointType.allCases)
                } label: {
                    Text("Select All")
                }
                Divider().frame(height: 25)
                Button {
                    selectedFiters.removeAll()
                } label: {
                    Text("Unselect All")
                }
            }//ends hstack
            
            ForEach(PointType.allCases, id: \.self) { option in
                HStack {
                    Image(systemName: selectedFiters.contains(option) ? "checkmark.square" : "square")
                    Text(option.rawValue.capitalized)
                }
                .padding(.bottom, 5)
                .onTapGesture {
                    if let index = selectedFiters.firstIndex(of: option) {
                        selectedFiters.remove(at: index)
                    }
                    else {
                        selectedFiters.append(option)
                    }
                }
            }//ends foreach
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Color(UIColor.secondarySystemBackground))
    }
    
    fileprivate func segmentedControlView() -> some View {
        return Picker("", selection: $resultsView) {
            ForEach(ResultsViewSection.allCases, id: \.self) { option in
                Text(option.rawValue)
            }
        }
        .pickerStyle(.segmented)
        .padding(.leading, 10)
        .padding(.trailing, 10)
        .padding(.bottom, 0)
    }
    
    func regionForSearchContext(searchContext: SearchContext) -> MKCoordinateRegion {
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.334_900, longitude: -122.009_020),
            latitudinalMeters: 750,
            longitudinalMeters: 750
        )
    }
}
