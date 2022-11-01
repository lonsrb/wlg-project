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
    @State var selectedPoint: PointViewModel? = nil
    @State var pointImage: UIImage? = nil
    
    var body: some View {
        VStack {
            Map(coordinateRegion: $pointsViewModel.searchContext.region, annotationItems: pointsViewModel.points) {
                point in
                MapAnnotation(coordinate: point.coord) {
                    PointMapView(pointViewModel: point) {
                        self.selectedPoint = point
                    }
                }
            }
            .onChange(of: pointsViewModel.searchContext.region ) { newRegion in
                pointsViewModel.reloadPointsIfNeeded(newRegion: newRegion)
            }
          
            if selectedPoint != nil {
                detailsViewForPoint(point: selectedPoint!)
            }
        }
        .onChange(of: pointToShowViewModel) { newValue in
            print("got a new point to center on: \(newValue?.nameString ?? "Missing")")
            if let newValue = newValue {
                selectedPoint = newValue
                pointsViewModel.centerMapAtPoint(pointViewModel: newValue)
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
        .onAppear {
            //load an image if it exists
            Task {
                if let selectedPoint = selectedPoint,
                   let imageUrl = selectedPoint.imageUrl,
                   let image = await selectedPoint.loadImage(url: imageUrl) {
                    pointImage = image
                }
            }
        }//ends onAppear
    }
}

