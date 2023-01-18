//
//  CameraBottomBarViewModel.swift
//  CameraApp
//
//  Created by Alexander Wiig Sørensen on 18/01/2023.
//

import SwiftUI

public final class CameraBottomBarViewModel: ObservableObject {
    
    @State var showPlus = false
    let onAction: (CameraBottomBar.Action) -> Void

    init(onAction: @escaping (CameraBottomBar.Action) -> Void) {
        self.onAction = onAction
    }
    
    func trigger (_ input: CameraBottomBar.Action) {
        onAction(input)
    }
}
