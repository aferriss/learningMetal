//
//  renderer.swift
//  mtkTest
//
//  Created by Adam Ferriss on 8/1/18.
//  Copyright © 2018 Adam Ferriss. All rights reserved.
//

import MetalKit

class Renderer: NSObject {
    let device: MTLDevice!
    let commandQueue: MTLCommandQueue!
    
    var scene: Scene?
    
    var samplerState: MTLSamplerState?
    
//    var offScreenTexture: MTLTexture!
    
    init(device: MTLDevice) {
        self.device = device
        commandQueue = device.makeCommandQueue()
        super.init()
        buildSamplerState()
    }
    
    private func buildSamplerState(){
        let descriptor = MTLSamplerDescriptor()
        descriptor.minFilter = .linear
        descriptor.magFilter = .linear
        descriptor.sAddressMode = .mirrorRepeat
        descriptor.tAddressMode = .mirrorRepeat
        
        samplerState = device.makeSamplerState(descriptor: descriptor)
    }
    
    private func setupTexture(){
        
    }
    
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable,
            let descriptor = view.currentRenderPassDescriptor
            else { return }
        
        descriptor.colorAttachments[0].texture = drawable.texture
        descriptor.colorAttachments[0].loadAction = .clear
        descriptor.colorAttachments[0].clearColor = Colors.black
        descriptor.colorAttachments[0].storeAction = .store
        
//        descriptor.colorAttachments[1].texture = drawable.texture
//        descriptor.colorAttachments[1].loadAction = .clear
//        descriptor.colorAttachments[1].clearColor = Colors.black
//        descriptor.colorAttachments[1].storeAction = .store
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: descriptor)
        
        
        let deltaTime = 1 / Float(view.preferredFramesPerSecond)
        
        commandEncoder?.setFragmentSamplerState(samplerState, index: 0)
        
        scene?.render(commandEncoder: commandEncoder!, deltaTime: deltaTime, currentTexture: drawable.texture)

        
        commandEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
        
        
        
    }
}

