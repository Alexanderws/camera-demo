//
//  ImageCarouselView.swift
//  CameraApp
//
//  Created by Alexander Wiig Sørensen on 25/01/2023.
//

import SwiftUI

struct ImageCarouselView: View {
    
    @StateObject var viewModel = ImageCarouselViewModel()
    
    var body: some View {
        HStack {
            ForEach(viewModel.images) { idImage in
                Image(uiImage: idImage.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 80)
            }
        }
        .frame(height: 100)
    }
}


