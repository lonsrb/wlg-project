//
//  ListView.swift
//  WLG-Project-Ryan
//
//  Created by Ryan Lons on 10/29/22.
//

import Foundation
import SwiftUI

struct ListView: View {
    @StateObject var pointViewModel: PointsViewModel
    
    var body: some View {
        ScrollView {
            ScrollViewReader { scrollViewReader in
                LazyVStack {
                    ForEach(pointViewModel.points, id:\.id) { pointViewModel in
                        PointRowView(pointViewModel: pointViewModel)
                            .listRowInsets(EdgeInsets())
                            .id(pointViewModel.id)
                        //                                    .frame(height: 60)
                    }
                }
            }
        }
    }
}
  
