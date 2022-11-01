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
    @State var showingList: Bool = false
    @State var searchInput: String = ""
    @State var showFilters: Bool = false
    @State var isSearching: Bool = false
    @State var selectedFiters: [PointType] = []
    @State var pointToShowViewModel: PointViewModel? = nil
    
    var body: some View {
        VStack {
            NavigationView {
                VStack(alignment:.leading) {
                    searchView()
                    if showFilters {
                        filtersView()
                    }
                    
                    ZStack(alignment:.bottomTrailing) {
                        MapView(pointToShowViewModel: $pointToShowViewModel, pointsViewModel: viewModel)
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
                }//ends vstack
            }//ends navigation link
        }//ends vstack
        .onAppear{
            viewModel.searchForPoints(coordinate: viewModel.searchContext.coordinate, queryString: "", selectedFilters: [])
        }
    }
    
    fileprivate func searchView() -> some View {
        return VStack {
            HStack {
                TextField( "Search for marinas", text: $searchInput)
                //                .overlay(
                //                    RoundedRectangle(cornerRadius: 15)
                //                        .stroke(.blue, lineWidth: 2)
                //                )
                //
                
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
    
    func regionForSearchContext(searchContext: SearchContext) -> MKCoordinateRegion {
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.334_900, longitude: -122.009_020),
            latitudinalMeters: 750,
            longitudinalMeters: 750
        )
    }
}
