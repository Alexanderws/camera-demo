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
    var symbol: Image {
        switch self {
        case .on:
            return Image(systemName: "boltFill")
        case .auto:
            return Image(systemName: "boltBadgeAFill")
        case .off:
            return Image(systemName: "boltSlashFill")
        @unknown default:
            return AVCaptureDevice.FlashMode.on.symbol
        }
    }
}
