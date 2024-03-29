//
//  ContentView.swift
//  CameraApp
//
//  Created by Alexander Wiig Sørensen on 17/01/2023.
//

import SwiftUI

struct ContentView: View {
    
    @State var isShowingCamera = false
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
            
            NavigationLink("Kamera") {
                CameraView()
            }
            
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
