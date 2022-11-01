//
//  PointMapView.swift
//  WLG-Project-Ryan
//
//  Created by Ryan Lons on 10/30/22.
//

import Foundation
import SwiftUI
import MapKit

struct PointMapView: View {
    @StateObject var pointViewModel: PointViewModel
    @State var icon: UIImage?

    let onDetail: () -> Void
    
    var body: some View {
        VStack {
            if let icon = icon {
                Button {
                    onDetail()
                } label: {
                        Image(uiImage: icon)
                            .resizable()
                            .frame(width: 25, height: 30)
                            .offset(y: -15)
                }//ends label
            }//ends if
        }
        .frame(width: 40, height: 40)
        .onAppear {
            Task {
                if let _icon = await pointViewModel.loadImage(url: pointViewModel.iconUrl) {
                    icon = _icon
                }
            }
        }//ends onAppear
    }//ends body
}
