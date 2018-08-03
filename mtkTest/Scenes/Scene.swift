//
//  Scene.swift
//  mtkTest
//
//  Created by Adam Ferriss on 8/1/18.
//  Copyright © 2018 Adam Ferriss. All rights reserved.
//

import MetalKit

class Scene: Node{
    var device: MTLDevice
    var size: CGSize
    
    init(device: MTLDevice, size: CGSize){
        self.device = device;
        self.size = size;
        super.init()
    }
    
    func render(commandEncoder: MTLRenderCommandEncoder, deltaTime: Float){
        update(deltaTime: deltaTime)
        
        let viewMatrix = matrix_float4x4(translationX: 0, y: 0, z: -4) // camera position
        
        for child in children {
            child.render(commandEncoder: commandEncoder, parentModelViewMatrix: viewMatrix)
        }
    }
    
    func render(commandEncoder: MTLRenderCommandEncoder, deltaTime: Float, currentTexture: MTLTexture){
        update(deltaTime: deltaTime)
        
        let viewMatrix = matrix_float4x4(translationX: 0, y: 0, z: -4) // camera position
        
        for child in children {
            child.render(commandEncoder: commandEncoder, parentModelViewMatrix: viewMatrix, currentTexture: currentTexture)
        }
    }
    
    func update(deltaTime: Float){}
}
