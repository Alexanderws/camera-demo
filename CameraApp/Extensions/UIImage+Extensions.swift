//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public extension UIImage {
    func downsampled(to pointSize: CGSize, scale: CGFloat) -> UIImage? {
        guard let data = self.jpegData(compressionQuality: 1) else {
            return nil
        }
        return UIImage.downsample(imageData: data, to: pointSize, scale: scale)
    }

    static func downsample(imageData: Data, to pointSize: CGSize, scale: CGFloat) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, imageSourceOptions) else {
            return nil
        }
        let maxDimentionInPixels = max(pointSize.width, pointSize.height) * scale
        let downsampledOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimentionInPixels
        ] as CFDictionary

        return CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampledOptions).map({ UIImage(cgImage: $0) })
    }
}
