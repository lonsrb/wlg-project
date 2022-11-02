//
//  PointRowView.swift
//  WLG-Project-Ryan
//
//  Created by Ryan Lons on 10/28/22.
//

import Foundation
import SwiftUI

struct PointRowView: View {
    var pointViewModel: PointViewModel
    @State private var icon: UIImage? = nil
    @State private var pointImage: UIImage? = nil
    let showOnMapTapped: () -> Void
    
    var body: some View {
        ZStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    if let icon = icon {
                        Image(uiImage: icon)
                            .resizable()
                            .frame(width: 20, height: 23)
                    }
                    Text(pointViewModel.nameString)
                    Spacer()
                    Button {
                        showOnMapTapped()
                    } label: {
                        Text("Show on map")
                    }
                }
                
                Text(pointViewModel.latString)
                Text(pointViewModel.lonString)
                Text(pointViewModel.kindString).italic()
                 
                NavigationLink(destination: DetailsView(url: URL(string: pointViewModel.siteUrl)!)) {
                    Text("More Info")
                }
                
                if let pointImage = pointImage {
                    NavigationLink(destination: DetailsView(url: URL(string: pointViewModel.siteUrl)!)) {
                        Image(uiImage: pointImage)
                            .resizable()
                            .scaledToFill()
                            .border(.black)
                    }
                }
                
                Divider()
                    .frame(height: 2)
                    .overlay(Color(white: 0.9))
            }
            .onAppear {
                //load the icon
                Task {
                    if let image = await pointViewModel.loadImage(url: pointViewModel.iconUrl)  {
                        icon = image
                    }
                }
                
                //load an image if it exists
                Task {
                    if let imageUrl = pointViewModel.imageUrl,
                       let image = await pointViewModel.loadImage(url: imageUrl) {
                        pointImage = image
                    }
                }
            }//ends onAppear
        }//ends zstack
    }
}
