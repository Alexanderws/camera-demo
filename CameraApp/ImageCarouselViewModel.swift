//
//  ImageCarouselViewModel.swift
//  CameraApp
//
//  Created by Alexander Wiig Sørensen on 25/01/2023.
//

import UIKit

final class ImageCarouselViewModel: ObservableObject {
    
    struct IdentifiableImage: Identifiable {
        let id: UUID
        var image: UIImage
        
        init(image: UIImage) {
            self.id = UUID()
            self.image = image
        }
    }
    
    @Published var images: [IdentifiableImage] = []
}
