//
//  kernels.metal
//  MetalCIFilter
//
//  Created by Joshua Homann on 3/12/23.
//

#include <metal_stdlib>
#include <CoreImage/CoreImage.h>
using namespace metal;

extern "C" {
    auto channelOffset(coreimage::sampler s, float2 redOffset, float2 greenOffset, float2 blueOffset) -> float4 {
        auto index = s.coord();
        return float4(
            s.sample(index - redOffset).r,
            s.sample(index - greenOffset).g,
            s.sample(index - blueOffset).b,
            s.sample(index).a
        );
    }
}
