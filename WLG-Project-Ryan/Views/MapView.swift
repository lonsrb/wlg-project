//
//  MapView.swift
//  WLG-Project-Ryan
//
//  Created by Ryan Lons on 10/29/22.
//

import Foundation
import SwiftUI
import MapKit

struct MapView: View {
    @Binding var pointToShowViewModel: PointViewModel?
    @StateObject var pointsViewModel: PointsViewModel
    @State private var selectedPoint: PointViewModel? = nil
    @State private var pointImage: UIImage? = nil
    @State var displayedRegion: MKCoordinateRegion
    
    var body: some View {
        VStack {
            Map(coordinateRegion: $displayedRegion, annotationItems: pointsViewModel.points) {
                point in
                MapAnnotation(coordinate: point.coord) {
                    VStack {
                        Button {
                            pointImage = nil
                            selectedPoint = point
                        } label: {
                            Image(uiImage: point.icon)
                                .resizable()
                                .frame(width: 26, height: 30)
                                .offset(y: -15)
                        }//ends label
                    }
                    .frame(width: 40, height: 40)
                }
            }
            .onChange(of: displayedRegion ) { newRegion in
                pointsViewModel.reloadPointsIfNeeded(newRegion: newRegion)
            }
            
            if let selectedPoint = selectedPoint {
                detailsViewForPoint(point: selectedPoint)
            }
        }
        .onChange(of: pointToShowViewModel) { newValue in
            if let newValue = newValue {
                selectedPoint = newValue
                pointsViewModel.centerMapAtPoint(pointViewModel: newValue)
                displayedRegion.center = newValue.coord
            }
        }
    }
    
    fileprivate func detailsViewForPoint(point: PointViewModel) -> some View {
        return VStack(alignment: .leading) {
            HStack {
                Text(point.nameString)
                    .bold()
                Spacer()
                Button {
                    selectedPoint = nil
                } label: {
                    Text("Close")
                }
            }
            Text(point.latString)
            Text(point.lonString)
            Text(point.kindString).italic()
            Spacer().frame(height: 10)
            NavigationLink(destination: DetailsView(url: URL(string: point.siteUrl)!)) {
                Text("Show Details")
            }
            
            if let selectedPoint = selectedPoint, let pointImage = pointImage {
                NavigationLink(destination: DetailsView(url: URL(string: selectedPoint.siteUrl)!)) {
                    Image(uiImage: pointImage)
                        .resizable()
                        .scaledToFill()
                        .border(.black)
                }
            }
        }
        .padding(13)
        .frame(
            maxWidth: .infinity,
            alignment: .topLeading
        )
        .onChange(of: point.imageUrl) { newUrl in
            loadImage()
        }
        .onAppear {
            loadImage()
        }//ends onAppear
    }
    
    fileprivate func loadImage() {
        Task {
            if let selectedPoint = selectedPoint,
               let imageUrl = selectedPoint.imageUrl,
               let image = await selectedPoint.loadImage(url: imageUrl) {
                pointImage = image
            }
            else {
                pointImage = nil
            }
        }
    }
}

