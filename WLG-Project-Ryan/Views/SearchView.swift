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
    @State private var showingList: Bool = false
    @State private var searchInput: String = ""
    @State private var showFilters: Bool = false
    @State private var isSearching: Bool = false
    @State private var selectedFiters: [PointType] = []
    @State private var pointToShowViewModel: PointViewModel? = nil
    @State private var resultsView: ResultsViewSelection = .list
    
    enum ResultsViewSelection : String, CaseIterable {
        case list = "List"
        case map = "Map"
    }
    
    var body: some View {
        VStack {
            NavigationView {
                VStack(alignment:.leading) {
                    searchView()
                    if showFilters {
                        filtersView()
                    }
                    segmentedControlView()
                    
                    if resultsView == .list {
                        ListView(pointsViewModel: viewModel, showPointOnMapTapped: { selectedPoint in
                            pointToShowViewModel = selectedPoint
                            resultsView = .map
                        })
                    }
                    else {// resultsView == .map
                        mapView()
                    }
                }//ends vstack
            }//ends navigation link
        }//ends vstack
    }
    
    fileprivate func mapView() -> some View {
        ZStack(alignment:.bottomTrailing) {
            MapView(pointToShowViewModel: $pointToShowViewModel,
                    pointsViewModel: viewModel,
                    displayedRegion: regionForMap())
                .zIndex(0)
            
            if showingList {
                ListView(pointsViewModel: viewModel, showPointOnMapTapped: { selectedPoint in
                    withAnimation {
                        showingList = false
                        pointToShowViewModel = selectedPoint
                    }
                })
                .background(Color.white)
                .transition(.move(edge: .bottom))
                .zIndex(1)
            }
            
            Button {
                withAnimation {
                    showingList.toggle()
                }
            } label: {
                Text(showingList ? "Show Map" : "Show List")
                    .padding([.leading, .trailing], 18)
                    .padding([.top, .bottom], 8)
                    .foregroundColor(.blue)
                    .background(Color.white)
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(.blue, lineWidth: 2)
                    )
            }
            .offset(x: -15, y: -15)
            .zIndex(2)
        }//ends zstack
    }
    
    fileprivate func searchView() -> some View {
        UITextField.appearance().clearButtonMode = .whileEditing
        return VStack {
            HStack {
                TextField( "Search for marinas", text: $searchInput)
                Spacer()
                Button {
                    showFilters.toggle()
                } label: {
                    if showFilters {
                        Text("Hide Filter")
                    }
                    else {
                        Image(systemName: "line.3.horizontal.decrease")
                    }
                }
                .padding(.trailing, 5)
                
                if isSearching {
                    Text("Searching..").italic()
                }
                else {
                    Button {
                        showFilters = false
                        isSearching = viewModel.isSearching
                        viewModel.searchForPoints(region: resultsView == .list ? nil : viewModel.searchContext.region,
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
                }//ends else eg: not actively searching
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
        }//ends vstack
        .padding()
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Color(UIColor.secondarySystemBackground))
    }
    
    fileprivate func segmentedControlView() -> some View {
        return Picker("", selection: $resultsView) {
            ForEach(ResultsViewSelection.allCases, id: \.self) { option in
                Text(option.rawValue)
            }
        }
        .pickerStyle(.segmented)
        .padding(.leading, 10)
        .padding(.trailing, 10)
        .padding(.bottom, 0)
    }
    
    
    fileprivate func regionForMap() -> MKCoordinateRegion {
        if let pointToShowViewModel = pointToShowViewModel {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: pointToShowViewModel.coord.latitude,
                                               longitude: pointToShowViewModel.coord.longitude),
                latitudinalMeters: 2000,
                longitudinalMeters: 2000
            )
        }
        else { //just us a default location for the map
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 39.28783449044417, longitude: -76.39857580839772),
                latitudinalMeters: 2000,
                longitudinalMeters: 2000
            )
        }
    }
}
