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
    @State var image: UIImage = UIImage(systemName: "ellipsis", withConfiguration: UIImage.SymbolConfiguration(pointSize: 55, weight: .black))!
    @State var loadedIcon = false
    
    var body: some View {
        ZStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Text(pointViewModel.nameString)
                Text(pointViewModel.kindString)
                Text(pointViewModel.latString)
                Text(pointViewModel.lonString)
                HStack {
                    if loadedIcon {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 50, height: 50)
                    }
                    Spacer()
                    NavigationLink(destination: DetailsView(url: URL(string: pointViewModel.siteUrl)!)) {
                        Text("Show Details")
                    }
                    .navigationTitle("Search Results")
                }
                .padding(20)
                
                Divider()
            }
            .onAppear {
                Task {
                    image = await pointViewModel.loadImage()
                    loadedIcon = true
                }
            }
        }//ends zstack
        .padding(10)
    }
}
