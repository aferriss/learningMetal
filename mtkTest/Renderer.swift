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
    
    var scene: Scene? // this one will do our feedback shader stuff
    var rttScene: Scene? // this is just a pass through
    
    var samplerState: MTLSamplerState?
    
    var loopTex: MTLTexture!
    var time: Float
    
    init(device: MTLDevice) {
        self.device = device
        commandQueue = device.makeCommandQueue()
        time = 0
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
        
        
        let deltaTime = 1 / Float(view.preferredFramesPerSecond)
        time += deltaTime
        
        
        // the view descriptor
        descriptor.colorAttachments[0].texture = drawable.texture
        descriptor.colorAttachments[0].loadAction = .clear
        descriptor.colorAttachments[0].clearColor = Colors.black
        descriptor.colorAttachments[0].storeAction = .store
        
        // texture template
        let textureDescriptor = MTLTextureDescriptor()
        textureDescriptor.textureType = MTLTextureType.type2D
        textureDescriptor.width = drawable.texture.width
        textureDescriptor.height = drawable.texture.height
        textureDescriptor.pixelFormat = .bgra8Unorm
        textureDescriptor.storageMode = .shared
        textureDescriptor.usage = [.renderTarget, .shaderRead]
        
        // make textures from the descriptor
        let sampleTexture = device.makeTexture(descriptor: textureDescriptor)
        let tex2 = device.makeTexture(descriptor: textureDescriptor)

        // create renderpasses
        // the texture here is what the pass renders on to
        let renderPass = makeRenderPass(texture: sampleTexture!)
        let renderPass2 = makeRenderPass(texture: tex2!)
    
        
        // make commandbuffer only once
        let commandBuffer = commandQueue.makeCommandBuffer()
        
        // command encoder will be reused for each render pass
        // we use the first one here
        var commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPass)
        commandEncoder?.setFragmentSamplerState(samplerState, index: 0) // should move this into plane render or shader i think
        // render the scene
        if(time < 1){
            scene?.render(commandEncoder: commandEncoder!, deltaTime: deltaTime)
        } else {
            scene?.render(commandEncoder: commandEncoder!, deltaTime: deltaTime, currentTexture: loopTex)
        }
        // stop encoding
        commandEncoder?.endEncoding()
        
        
        // remake the encoder with 2nd render pass this render will vFlip back the right way
        commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPass2)
        commandEncoder?.setFragmentSamplerState(samplerState, index: 0)
        // this one will just render to a texture for use later
        // currentTexture is a texture that we send back to a shader
        rttScene?.render(commandEncoder: commandEncoder!, deltaTime: deltaTime, currentTexture: sampleTexture!)
        commandEncoder?.endEncoding()
        
        
        // remake the encoder with a different renderpass descriptor
        commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: descriptor)
        commandEncoder?.setFragmentSamplerState(samplerState, index: 0)
        rttScene?.render(commandEncoder: commandEncoder!, deltaTime: deltaTime, currentTexture: sampleTexture!)
        commandEncoder?.endEncoding()
        
        
        // finish up
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
        
        
        // copy tex2 to our longlived texture object
        loopTex = tex2
        
    }
    
    func makeRenderPass(texture: MTLTexture) -> MTLRenderPassDescriptor {
        let renderPass = MTLRenderPassDescriptor()
        renderPass.colorAttachments[0].texture = texture
        renderPass.colorAttachments[0].loadAction = .clear
        renderPass.colorAttachments[0].clearColor = MTLClearColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        renderPass.colorAttachments[0].storeAction = .store
        
        return renderPass
    }
}

