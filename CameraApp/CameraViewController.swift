//
//  CameraViewController.swift
//  CameraApp
//
//  Created by Alexander Wiig Sørensen on 17/01/2023.
//

import UIKit
import SwiftUI

final class CameraViewController: UIViewController  {
    
    private var isExpanded = true
    
    private var imageCarouselModel = ImageCarouselViewModel()

    private lazy var captureViewController = CaptureViewController()
    private var captureView: UIView { captureViewController.view }
    
    
    private lazy var viewModel = CameraBottomBarViewModel(onAction: { [weak self] action in self?.onBottomBarAction(action) })
    
    private lazy var bottomBarViewController = UIHostingController(rootView: CameraBottomBar(viewModel: self.viewModel))
    private var bottomBarView: UIView { bottomBarViewController.view }
    
    private lazy var imageCarouselViewController = UIHostingController(rootView: ImageCarouselView(viewModel: self.imageCarouselModel))
    private var imageCarouselView: UIView { imageCarouselViewController.view }
    
    // MARK: - UI Components
    

    
    // MARK: - Actions
    
    private func onBottomBarAction(_ action: CameraBottomBar.Action) {
        switch action {
        case .capture:
            captureViewController.captureImage()
        }
    }

    @objc private func onCancel() {
        // delegate?.cameraViewController(self, didCancelWith: cameraRoll)
    }
    
    private func addImage(_ image: UIImage) {
        imageCarouselModel.images.append(.init(image: image))
    }
    
    // MARK: - Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        add(captureViewController)
        captureView.translatesAutoresizingMaskIntoConstraints = false
        captureViewController.delegate = self
        
        add(bottomBarViewController)
        bottomBarView.translatesAutoresizingMaskIntoConstraints = false
        
        add(imageCarouselViewController)
        imageCarouselView.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        NSLayoutConstraint.activate([
            captureView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            captureView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            captureView.topAnchor.constraint(equalTo: view.topAnchor),
            captureView.bottomAnchor.constraint(equalTo: bottomBarView.topAnchor),
            
            bottomBarView.heightAnchor.constraint(equalToConstant: 100),
            bottomBarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            imageCarouselView.bottomAnchor.constraint(equalTo: bottomBarView.topAnchor, constant: -20),
            imageCarouselView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageCarouselView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    

    
}

public extension UIViewController {
    func add(_ childViewController: UIViewController) {
        guard childViewController.parent == nil else { return }
        
        addChild(childViewController)
        view.addSubview(childViewController.view)
        childViewController.didMove(toParent: self)
    }
}

// MARK: - CaptureViewControllerDelegate

extension CameraViewController: CaptureViewControllerDelegate {
    func captureViewController(_ viewController: CaptureViewController, didCaptureImage image: UIImage) {
        addImage(image)
    }

    func captureViewController(_ viewController: CaptureViewController, didRecordVideo videoUrl: URL) {}
}

