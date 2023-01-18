//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import AVFoundation
import UIKit

final class CaptureSession: AVCaptureSession {
    enum SessionError: Swift.Error {
        case deviceMissing(mediaType: AVMediaType)
        case audioInputMissing
        case videoInputMissing
        case photoOutputMissing
        case videoOutputMissing
        case sessionIsNotRunning
        case videoIsAlreadyRecording
    }

    var flashMode = AVCaptureDevice.FlashMode.off

    private var videoDeviceInput: AVCaptureDeviceInput?
    private lazy var photoOutput = AVCapturePhotoOutput()
    private var movieFileOutput: AVCaptureMovieFileOutput?
}

// MARK: - Setup
extension CaptureSession {
    func setup() throws {
        beginConfiguration()
        sessionPreset = .photo

        do {
            try addVideoInput()
            try addPhotoOutput()
            commitConfiguration()
        } catch {
            commitConfiguration()
            throw error
        }
    }

    // MARK: - Inputs
    private func addVideoInput() throws {
        let positions: [AVCaptureDevice.Position] = [.back, .front]

        guard let device = positions.compactMap({ AVCaptureDevice.device(for: $0) }).first else {
            throw SessionError.deviceMissing(mediaType: .video)
        }

        try device.lockForConfiguration()
        if device.isFocusModeSupported(.continuousAutoFocus) {
            device.focusMode = .continuousAutoFocus
        }
        device.unlockForConfiguration()

        let input = try AVCaptureDeviceInput(device: device)

        if canAddInput(input) {
            addInput(input)
            self.videoDeviceInput = input
        } else {
            throw SessionError.videoInputMissing
        }
    }

    // MARK: - Outputs
    private func addPhotoOutput() throws {
        photoOutput.setPreparedPhotoSettingsArray(
            [AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])],
            completionHandler: nil
        )

        if canAddOutput(photoOutput) {
            photoOutput.isHighResolutionCaptureEnabled = true
            photoOutput.maxPhotoQualityPrioritization = .quality
            addOutput(photoOutput)
        } else {
            throw SessionError.photoOutputMissing
        }
    }
}

// MARK: - Capture mode
extension CaptureSession {
    func toggleCameraPosition(to position: AVCaptureDevice.Position) throws {
        guard let currentInput = videoDeviceInput else {
            throw SessionError.videoInputMissing
        }

        guard currentInput.device.position != position else {
            return
        }

        guard let newDevice = AVCaptureDevice.device(for: position) else {
            return
        }

        let newInput = try AVCaptureDeviceInput(device: newDevice)

        beginConfiguration()
        removeInput(currentInput)

        if canAddInput(newInput) {
            addInput(newInput)
            self.videoDeviceInput = newInput
        } else {
            addInput(currentInput)
        }

        commitConfiguration()
    }
}

// MARK: - Recording
extension CaptureSession {
    func captureImage(delegate: AVCapturePhotoCaptureDelegate) throws {
        guard isRunning else {
            throw SessionError.sessionIsNotRunning
        }

        let deviceOrientation = UIDevice.current.orientation // retrieve current orientation from the device
        guard let photoOutputConnection = photoOutput.connection(with: AVMediaType.video) else {
            throw SessionError.photoOutputMissing
        }

        if let videoOrientation = deviceOrientation.videoOrientation {
            photoOutputConnection.videoOrientation = videoOrientation
        }

        let settings = AVCapturePhotoSettings()
        settings.flashMode = flashMode
        photoOutput.capturePhoto(with: settings, delegate: delegate)
        print("session.captureImage")
    }

    func startRecording(delegate: AVCaptureFileOutputRecordingDelegate) throws {
        guard isRunning else {
            throw SessionError.sessionIsNotRunning
        }

        guard movieFileOutput?.isRecording == false else {
            throw SessionError.videoIsAlreadyRecording
        }

        let tempUrl = FileManager.default.temporaryDirectory
        let fileName = NSUUID().uuidString
        let fileUrl = tempUrl.appendingPathComponent(fileName).appendingPathExtension("mov")

        movieFileOutput?.startRecording(to: fileUrl, recordingDelegate: delegate)
    }

    func stopRecording() {
        if movieFileOutput?.isRecording == true {
            movieFileOutput?.stopRecording()
        }
    }
}

// MARK: - Private extensions
private extension AVCaptureDevice {
    static func device(for position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let preferredDeviceType: AVCaptureDevice.DeviceType

        switch position {
        case .unspecified, .front:
            preferredDeviceType = .builtInDualCamera
        case .back:
            preferredDeviceType = .builtInTrueDepthCamera
        @unknown default:
            return nil
        }

        let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera],
            mediaType: .video,
            position: .unspecified
        )

        let devices = videoDeviceDiscoverySession.devices

        if let device = devices.first(where: { $0.position == position && $0.deviceType == preferredDeviceType }) {
            return device
        } else {
            return devices.first(where: { $0.position == position })
        }
    }
}

private extension UIDeviceOrientation {
    var videoOrientation: AVCaptureVideoOrientation? {
        switch self {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        case .unknown:
            return .portrait
        case .faceUp, .faceDown:
            return nil
        @unknown default:
            return nil
        }
    }
}
