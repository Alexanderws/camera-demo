//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import SwiftUI
import Photos
import PhotosUI

struct CameraBottomBar: View {
    struct ViewState {
        var showPlus = true
    }

    enum Action {
        case capture
    }

    @StateObject var viewModel: CameraBottomBarViewModel

    // MARK: - Views

    var body: some View {
        HStack {
            Spacer()
            captureButton
            Spacer()
        }
        .background(Color.black)
        .frame(height: 100)
    }

    private var captureButton: some View {
        CaptureButton(
            showPlus: viewModel.showPlus,
            action: {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                viewModel.trigger(.capture)
            })
    }
}

// MARK: - Subviews

private struct CaptureButton: View {
    var showPlus = true
    let action: () -> Void

    // MARK: - Views

    var body: some View {
        ZStack {
            Circle().fill(Color.white.opacity(0.3)).frame(width: 80, height: 80)
            Button(action: action) {
                ZStack {
                    Circle().fill(Color.white).frame(width: 64, height: 64)
                    if showPlus {
                        Image(systemName: "plus")
                            .foregroundColor(.black)
                            .font(Font.system(.largeTitle).weight(.medium))
                    }
                }
            }
            // .buttonStyle(ScaledButtonStyle())
        }.frame(height: 100)
    }
}
