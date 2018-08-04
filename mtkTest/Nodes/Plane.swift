//
//  Plane.swift
//  mtkTest
//
//  Created by Adam Ferriss on 8/1/18.
//  Copyright © 2018 Adam Ferriss. All rights reserved.
//

import MetalKit

class Plane: Node {
    

    var vertices: [Vertex] = [
        Vertex(position:float3(-1, 1, 0), color: float4(1, 0, 0, 1), texture: float2(0, 1)),
        Vertex(position:float3(-1, -1, 0), color: float4(0, 1, 0, 1), texture: float2(0, 0)),
        Vertex(position:float3(1, -1, 0), color: float4(0, 0, 1, 1), texture: float2(1, 0)),
        Vertex(position:float3(1, 1, 0), color: float4(1, 0, 1, 1), texture: float2(1, 1)),
    ]
    
    var indices: [UInt16] = [
        0,1,2,
        2,3,0
    ]
    
    var vertexBuffer: MTLBuffer?
    var indexBuffer: MTLBuffer?
    
    var modelConstants = ModelConstants()
    var fragUniforms = FragUniforms()
    
    var time : Float = 0 
    
    // Renderable
    var pipelineState: MTLRenderPipelineState!
    var fragmentFunctionName: String = "fragment_shader"
    var vertexFunctionName: String = "vertex_shader"
    
    var vertexDescriptor: MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].offset = MemoryLayout<float3>.stride
        vertexDescriptor.attributes[1].bufferIndex = 0
        
        vertexDescriptor.attributes[2].format = .float2
        vertexDescriptor.attributes[2].offset = MemoryLayout<float3>.stride + MemoryLayout<float4>.stride
        vertexDescriptor.attributes[2].bufferIndex = 0
        
        vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride
        return vertexDescriptor
    }
    
    // Texturable
    var texture: MTLTexture?
    var maskTexture: MTLTexture?
    
    
    init(device: MTLDevice){
        super.init()
        buildBuffers(device: device)
        pipelineState = buildPipelineState(device: device)
    }
    
    init(device: MTLDevice, imageName: String){
        super.init()
        if let texture = setTexture(device: device, imageName: imageName) {
            self.texture = texture
            fragmentFunctionName = "textured_fragment"
        }
        
        buildBuffers(device: device)
        pipelineState = buildPipelineState(device: device)
    }
    
    init(device: MTLDevice, width: Int, height: Int){
        super.init();
        if let texture = emptyTexture(device: device, width: width, height: height){
            self.texture = texture
            fragmentFunctionName = "redTexture"
            vertexFunctionName = "fullScreen"
        }
        
        buildBuffers(device: device)
        pipelineState = buildPipelineState(device: device)
    }
    
    init(device: MTLDevice, imageName: String, maskImageName: String){
        super.init()
        if let texture = setTexture(device: device, imageName: imageName) {
            self.texture = texture
            fragmentFunctionName = "textured_fragment"
        }
        
        if let maskTexture = setTexture(device: device, imageName: maskImageName) {
            self.maskTexture = maskTexture
            fragmentFunctionName = "textured_mask_fragment"
        }

        buildBuffers(device: device)
        pipelineState = buildPipelineState(device: device)
    }
    
    init(device: MTLDevice, imageName: String, shader: String){
        super.init()
        if let texture = setTexture(device: device, imageName: imageName) {
            self.texture = texture
            vertexFunctionName = shader
            fragmentFunctionName = "textured_fragment"
        }
        
        buildBuffers(device: device)
        pipelineState = buildPipelineState(device: device)
    }
    
    private func buildBuffers(device: MTLDevice) {
        vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Vertex>.stride, options: [])
        indexBuffer = device.makeBuffer(bytes: indices, length: indices.count * MemoryLayout<UInt16>.size, options: [])
    }
    
//    override func render(commandEncoder: MTLRenderCommandEncoder, deltaTime: Float) {
//        super.render(commandEncoder: commandEncoder, deltaTime: deltaTime)
//    }
    
    
    
}

extension Plane: Renderable {
    
    func doRender(commandEncoder: MTLRenderCommandEncoder, modelViewMatrix: matrix_float4x4) {
        
        guard let indexBuffer = indexBuffer else { return }
        
        let aspect = Float(9.0/16.0)
        
        let projectionMatrix = matrix_float4x4(projectionFov: radians(fromDegrees: 65), aspect: aspect, nearZ: 0.1, farZ: 100)
        
        modelConstants.modelViewMatrix = matrix_multiply(projectionMatrix, modelViewMatrix)
        
        commandEncoder.setRenderPipelineState(pipelineState)
        
        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder.setVertexBytes(&modelConstants, length: MemoryLayout<ModelConstants>.stride, index: 1) // sets a uniform
        
        commandEncoder.setFragmentTexture(texture, index: 0)
        commandEncoder.setFragmentTexture(maskTexture, index: 1)
        
        fragUniforms.time += 1
        commandEncoder.setFragmentBytes(&fragUniforms, length: MemoryLayout<FragUniforms>.stride, index: 2)
        
        
        
        commandEncoder.drawIndexedPrimitives(type: .triangle,
                                             indexCount: indices.count,
                                             indexType: .uint16,
                                             indexBuffer: indexBuffer,
                                             indexBufferOffset: 0)
    }
    
    func doRender(commandEncoder: MTLRenderCommandEncoder, modelViewMatrix: matrix_float4x4, currentTexture: MTLTexture) {
       
        guard let indexBuffer = indexBuffer else { return }
        
        let aspect = Float(9.0/16.0)
        
        let projectionMatrix = matrix_float4x4(projectionFov: radians(fromDegrees: 65), aspect: aspect, nearZ: 0.1, farZ: 100)
        
        modelConstants.modelViewMatrix = matrix_multiply(projectionMatrix, modelViewMatrix)
        
        commandEncoder.setRenderPipelineState(pipelineState)
        
        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder.setVertexBytes(&modelConstants, length: MemoryLayout<ModelConstants>.stride, index: 1) // sets a uniform
        
//        if(fragUniforms.time < 60 ){
//            commandEncoder.setFragmentTexture(texture, index: 0)
//        } else {
            commandEncoder.setFragmentTexture(currentTexture, index: 0)
//        }
        commandEncoder.setFragmentTexture(maskTexture, index: 1)
        
        fragUniforms.time += 1
        commandEncoder.setFragmentBytes(&fragUniforms, length: MemoryLayout<FragUniforms>.stride, index: 2)
        
        
        
        commandEncoder.drawIndexedPrimitives(type: .triangle,
                                             indexCount: indices.count,
                                             indexType: .uint16,
                                             indexBuffer: indexBuffer,
                                             indexBufferOffset: 0)
    }
}

extension Plane: Texturable {
    
}
