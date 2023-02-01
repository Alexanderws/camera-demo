//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import AVFoundation
import SwiftUI

// MARK: - Flash mode

extension AVCaptureDevice.FlashMode {
    mutating func next() {
        switch self {
        case .on:
            self = .auto
        case .auto:
            self = .off
        case .off:
            self = .on
        @unknown default:
            self = .on
        }
    }

    // Might not be right return type
    var symbol: UIImage? {
        switch self {
        case .on:
            return UIImage(systemName: "bolt.fill")
        case .auto:
            return UIImage(systemName: "bolt.badge.a.fill")
        case .off:
            return UIImage(systemName: "bolt.slash.fill")
        @unknown default:
            return AVCaptureDevice.FlashMode.on.symbol
        }
    }
}
