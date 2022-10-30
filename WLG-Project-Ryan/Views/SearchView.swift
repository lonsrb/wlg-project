//
//  SearchView.swift
//  WLG-Project-Ryan
//
//  Created by Ryan Lons on 10/28/22.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = PointsViewModel(pointsService: ApplicationConfiguration.shared.pointService)
    
    var body: some View {
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            Button {
                viewModel.fetch()
            } label: {
                Text("Trigger search")
            }
            NavigationView {
                ScrollView {
                    ScrollViewReader { scrollViewReader in
                        LazyVStack {
                            ForEach(viewModel.points, id:\.id) { pointViewModel in
                                PointRowView(pointViewModel: pointViewModel)
                                    .listRowInsets(EdgeInsets())
                                    .id(pointViewModel.id)
//                                    .frame(height: 60)
                            }
                        }
                        .onAppear{
                            viewModel.fetch()
                        }
                    }
                }
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
