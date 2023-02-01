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
        case rotate
    }

    @StateObject var viewModel: CameraBottomBarViewModel

    // MARK: - Views

    var body: some View {
        HStack {
            photoLibraryButton
            Spacer()
            captureButton
            Spacer()
            rotateButton
        }
        .background(Color.black)
        .frame(height: 100)
    }

    private var photoLibraryButton: some View {
        Button(action: {
            fatalError("not implemented")
        }) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.title)
                .foregroundColor(.white)
                .padding(25)
        }
    }

    private var captureButton: some View {
        CaptureButton(
            showPlus: viewModel.showPlus,
            action: {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                viewModel.trigger(.capture)
            })
    }

    private var rotateButton: some View {
        RotateButton(action: { viewModel.trigger(.rotate) })
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

private struct RotateButton: View {
    let action: () -> Void

    // MARK: - Views

    var body: some View {
        Button(action: action) {
            Image(systemName: "camera.rotate")
                .font(.title)
                .foregroundColor(.white)
                .padding(25)
        }
    }
}

