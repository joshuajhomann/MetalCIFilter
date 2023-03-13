//
//  ContentView.swift
//  MetalCIFilter
//
//  Created by Joshua Homann on 3/12/23.
//

import PhotosUI
import SwiftUI

struct FilterView: View {
    @StateObject private var viewModel = FilterViewModel()
    @State private var showFilterControls = false
    var body: some View {
        NavigationStack {
            Group {
                if let image = viewModel.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Text("No image selected")
                }
            }
            .aspectRatio(contentMode: .fit)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { viewModel.imageSelection = nil } label: { Image(systemName: "xmark") }
                }
                ToolbarItem(placement: .principal) {
                    Button {  showFilterControls = true } label: { Image(systemName: "camera.filters") }
                        .popover(isPresented: $showFilterControls) {
                            NavigationStack {
                                ScrollView {
                                    VStack(alignment: .leading) {
                                        Text("Red")
                                        Slider(value: $viewModel.unitRed)
                                        Text("Green")
                                        Slider(value: $viewModel.unitGreen)
                                        Text("Blue")
                                        Slider(value: $viewModel.unitBlue)
                                        Text("Rotation")
                                        Slider(value: $viewModel.unitRotation)
                                        Text("Magnitude")
                                        Slider(value: $viewModel.unitMagnitude)
                                    }
                                }
                                .navigationTitle("Filter")
                                .navigationBarTitleDisplayMode(.inline)
                                .padding()
                            }
                            .frame(idealWidth: 300, idealHeight: 450)
                            .presentationDetents([.fraction(0.5), .fraction(0.25)])
                        }
                }
                ToolbarItem(placement: .primaryAction) {
                    PhotosPicker(selection: $viewModel.imageSelection, matching: .images, photoLibrary: .shared()) {
                        Image(systemName: "photo")
                    }
                }
            }
        }
    }
}

struct FilterView_Preview: PreviewProvider {
    static var previews: some View {
        FilterView()
    }

}
