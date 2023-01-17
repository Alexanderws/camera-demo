//
//  CaptureViewController.swift
//  CameraApp
//
//  Created by Alexander Wiig Sørensen on 17/01/2023.
//

import UIKit
import AVFoundation

// MARK: - Delegate
protocol CaptureViewControllerDelegate: AnyObject {
    func captureViewController(_ viewController: CaptureViewController, didCaptureImage image: UIImage)
    func captureViewController(_ viewController: CaptureViewController, didRecordVideo videoUrl: URL)
}

// MARK: - View Controller
final class CaptureViewController: UIViewController {
    weak var delegate: CaptureViewControllerDelegate?
    var flashMode: AVCaptureDevice.FlashMode { session.flashMode }

    private let sessionQueue = DispatchQueue(label: "AdInputCameraViewController.SessionQueue")
    private lazy var session = CaptureSession()
    private var position: AVCaptureDevice.Position = .back

    private lazy var previewView: PreviewView = {
        let view = PreviewView()
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.videoPreviewLayer?.videoGravity = .resizeAspectFill
        view.videoPreviewLayer?.connection?.videoOrientation = .portrait
        return view
    }()

    private lazy var flashView: UIView = {
        let view = UIView()
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.alpha = 0
        return view
    }()

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .darkGray
        view.addSubview(previewView)
        view.addSubview(flashView)

        flashView.frame = view.frame
        previewView.frame = view.frame
        previewView.session = session

        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        execute { $0.startRunning() }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        execute { $0.stopRecording() }
        execute { $0.stopRunning() }
    }

    deinit {
        stopCaptureSession()
    }

    private func stopCaptureSession() {
        previewView.session = nil
        previewView.removeFromSuperview()
        previewView.videoPreviewLayer?.removeFromSuperlayer()
        session.stopRunning()

        for input in session.inputs {
            session.removeInput(input)
        }

        for output in session.outputs {
            session.removeOutput(output)
        }
    }

    // MARK: - API

    func toggleCameraPosition() {
        let newPosition: AVCaptureDevice.Position = position == .back ? .front : .back
        position = newPosition
        execute { try $0.toggleCameraPosition(to: newPosition) }
    }

    func toggleFlashMode() {
        session.flashMode.next()
    }

    func captureImage() {
        execute { [weak self] session in
            if let self = self {
                try session.captureImage(delegate: self)
            }
        }

        if session.flashMode == .off {
            UIView.animate(withDuration: 0.05, delay: 0.0, options: [.curveEaseOut], animations: {
                self.flashView.alpha = 1.0
            }, completion: { _ in
                UIView.animate(withDuration: 0.05) {
                    self.flashView.alpha = 0.0
                }
            })
        }
    }

    func startRecording() {
        execute { [weak self] session in
            if let self = self {
                try session.startRecording(delegate: self)
            }
        }
    }

    func stopRecording() {
        execute { $0.stopRecording() }
    }

    func downsample(image: UIImage, completion: @escaping (UIImage) -> Void) {
        let image = image.downsampled(to: UIScreen.main.bounds.size, scale: UIScreen.main.scale) ?? image
        DispatchQueue.main.async {
            completion(image)
        }
    }

    // MARK: - Private

    private func setup() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            execute { try $0.setup() }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.execute { try $0.setup() }
                }
            }
        default:
            break
        }
    }

    private func execute(_ closure: @escaping (CaptureSession) throws -> Void) {
        sessionQueue.async { [weak self] in
            guard let session = self?.session else {
                return
            }

            do {
                try closure(session)
            } catch {
                print(error)
            }
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CaptureViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            print("Fail to capture photo: \(String(describing: error))")
            return
        }

        guard
            let cgImageRepresentation = photo.cgImageRepresentation(),
            let orientationInt = photo.metadata[String(kCGImagePropertyOrientation)] as? UInt32,
            let imageOrientation = UIImage.Orientation.orientation(fromCGOrientationRaw: orientationInt)
        else {
            print("Fail to map image orientation")
            return
        }

        let image = UIImage(cgImage: cgImageRepresentation, scale: 1, orientation: imageOrientation)

        guard let capturedImage = image.downsampled(to: CGSize(width: 1600, height: 1600), scale: 1) else {
            print("Fail to convert image data to UIImage")
            return
        }

        let croppedImage = self.crop(image: capturedImage, imageOrientation: imageOrientation)

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.delegate?.captureViewController(self, didCaptureImage: croppedImage)
        }
    }

    private func crop(image: UIImage, imageOrientation: UIImage.Orientation) -> UIImage {
        guard let previewLayer = previewView.videoPreviewLayer else {
            return image
        }

        guard let cgImage = image.cgImage else {
            return image
        }

        let metadataOutputRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let outputRect = previewLayer.layerRectConverted(fromMetadataOutputRect: metadataOutputRect)
        var cropRect: CGRect

        // Handle pictures taken in landscape left and right
        if imageOrientation == .up || imageOrientation == .down {
            let factorX = image.size.width / outputRect.height
            let factorY = image.size.height / outputRect.width
            cropRect = CGRect(
                x: -outputRect.origin.y * factorX,
                y: outputRect.origin.x * factorY,
                width: view.frame.size.height * factorX,
                height: view.frame.size.width * factorY
            )
        // Portrait orientation
        } else {
            let factorX = image.size.width / outputRect.width
            let factorY = image.size.height / outputRect.height
            cropRect = CGRect(
                x: outputRect.origin.x * factorX,
                y: -outputRect.origin.y * factorY,
                width: view.frame.size.width * factorX,
                height: view.frame.size.height * factorY
            )
        }

        guard let cropped = cgImage.cropping(to: cropRect) else {
            return image
        }

        return UIImage(cgImage: cropped, scale: image.scale, orientation: image.imageOrientation)
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate
extension CaptureViewController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(
        _ output: AVCaptureFileOutput,
        didFinishRecordingTo outputFileURL: URL,
        from connections: [AVCaptureConnection],
        error: Error?
    ) {
        delegate?.captureViewController(self, didRecordVideo: outputFileURL)
    }
}

// MARK: - Private types
private final class PreviewView: UIView {
    var videoPreviewLayer: AVCaptureVideoPreviewLayer? {
        return layer as? AVCaptureVideoPreviewLayer
    }

    var session: AVCaptureSession? {
        get {
            return videoPreviewLayer?.session
        }
        set {
            videoPreviewLayer?.session = newValue
        }
    }

    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}
