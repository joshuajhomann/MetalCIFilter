//
//  Filters.swift
//  MetalCIFilter
//
//  Created by Joshua Homann on 3/12/23.
//

import UIKit
import CoreImage

final class ChannelOffsetFilter: CIFilter {
    
    static let kernel: CIKernel? = {
        Bundle.main.url(forResource: "default", withExtension: "metallib")
            .flatMap { try? Data(contentsOf: $0) }
            .flatMap { try? CIKernel(functionName: "channelOffset", fromMetalLibraryData: $0) }
    }()

    @objc dynamic var inputImage: CIImage?
    @objc dynamic var redOffset = CIVector(x: 0.1, y: 0.03)
    @objc dynamic var greenOffset = CIVector(x: -0.03, y: 0.03)
    @objc dynamic var blueOffset = CIVector(x: 0.03, y: -0.03)

    override var outputImage: CIImage? {
        guard let inputImage, let kernel = Self.kernel else { return nil }
        return kernel.apply(
            extent: inputImage.extent,
            roiCallback: { $1 },
            arguments: [inputImage, redOffset, greenOffset, blueOffset]
        )
    }
}

