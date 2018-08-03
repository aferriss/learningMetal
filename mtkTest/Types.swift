//
//  Types.swift
//  mtkTest
//
//  Created by Adam Ferriss on 8/1/18.
//  Copyright © 2018 Adam Ferriss. All rights reserved.
//

import Foundation
import simd

struct Vertex {
    var position: float3
    var color: float4
    var texture: float2
}

struct ModelConstants {
    var modelViewMatrix = matrix_identity_float4x4
}

struct FragUniforms {
    var time: Float = 0.0
}
