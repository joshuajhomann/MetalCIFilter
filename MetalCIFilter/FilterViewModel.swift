//
//  FilterViewModel.swift
//  MetalCIFilter
//
//  Created by Joshua Homann on 3/12/23.
//

import Combine
import PhotosUI
import SwiftUI

final class FilterViewModel: ObservableObject {
    @Published private(set) var image: UIImage?
    @Published var imageSelection: PhotosPickerItem?
    @Published var unitRed = 0.5
    @Published var unitGreen = 0.0
    @Published var unitBlue = 0.0
    @Published var unitRotation = 0.2
    @Published var unitMagnitude = 0.25
    enum Constant {
        static let maxMagnitude = 0.04
    }
    init() {

        let context = CIContext()
        let filter = ChannelOffsetFilter()
        print(filter.inputKeys)
        let monoFilter = CIFilter(name: "CIColorMonochrome", parameters: ["inputColor": CIColor(cgColor: UIColor.white.cgColor), "inputIntensity": 1.0])

        let filterInputs = Publishers
            .CombineLatest4($unitRed, $unitGreen, $unitBlue, $unitMagnitude)
            .combineLatest($unitRotation)
            .throttle(for: .milliseconds(50), scheduler: DispatchQueue.main, latest: true)
            .map { scalars, unitRotation in
                let (unitRed, unitGreen, unitBlue, unitMagnitude) = scalars
                let τ = 2.0 * .pi
                let θr = (unitRed + unitRotation) * τ
                let θg = (unitGreen + unitRotation) * τ
                let θb = (unitBlue + unitRotation) * τ
                let r = Constant.maxMagnitude * unitMagnitude
                return (
                    red: CIVector(x: r * cos(θr), y: r * sin(θr)),
                    green: CIVector(x: r * cos(θg), y: r * sin(θg)),
                    blue: CIVector(x: r * cos(θb), y: r * sin(θb))
                )
            }
        let inputImage = $imageSelection
            .map { selection in
                selection.map { selection in
                    Future { promise in
                        selection.loadTransferable(type: Data.self, completionHandler: promise)
                    }
                    .replaceError(with: nil)
                    .eraseToAnyPublisher()
                } ?? Just(nil).eraseToAnyPublisher()
            }
            .switchToLatest()
            .map { data -> (image: CIImage, orientation: UIImage.Orientation)? in
                guard let data, let uiImage = UIImage(data: data), let ciImage = CIImage(image: uiImage) else { return nil }
                return(image: ciImage, orientation: uiImage.imageOrientation)
            }
            .receive(on: DispatchQueue.main)

        Publishers
            .CombineLatest(inputImage, filterInputs)
            .map { imageInfo, inputs in
                imageInfo.flatMap { image, orientation in
                    monoFilter?.setValue(image, forKey: kCIInputImageKey)
                    filter.inputImage = monoFilter?.outputImage
                    filter.redOffset = inputs.red
                    filter.greenOffset = inputs.green
                    filter.blueOffset = inputs.blue
                    return filter
                        .outputImage
                        .flatMap { outputImage in
                            context.createCGImage(outputImage, from: outputImage.extent)
                        }
                        .map { cgImage in
                            UIImage(cgImage: cgImage, scale: 1, orientation: orientation)
                        }
                }
            }
            .assign(to: &$image)
    }
}
