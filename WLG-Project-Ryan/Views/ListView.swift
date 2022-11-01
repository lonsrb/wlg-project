//
//  ListView.swift
//  WLG-Project-Ryan
//
//  Created by Ryan Lons on 10/29/22.
//

import Foundation
import SwiftUI

struct ListView: View {
    @StateObject var pointsViewModel: PointsViewModel
    let showPointOnMapTapped: (PointViewModel) -> Void
    
    var body: some View {
        ScrollView {
            ScrollViewReader { scrollViewReader in
                VStack(alignment: .leading) {
                    Text(pointsViewModel.resultCountString)
                        .italic()
                    LazyVStack {
                        ForEach(pointsViewModel.points, id:\.id) { pointViewModel in
                            PointRowView(pointViewModel: pointViewModel, showOnMapTapped: {
                                showPointOnMapTapped(pointViewModel)
                            })
                            .listRowInsets(EdgeInsets())
                            .id(pointViewModel.id)
                        }
                    }
                }.padding(10)
            }//ends scrollview reader
        }//ends scrollview
    }//ends body
}

