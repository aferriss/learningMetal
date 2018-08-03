//
//  Texturable.swift
//  mtkTest
//
//  Created by Adam Ferriss on 8/1/18.
//  Copyright © 2018 Adam Ferriss. All rights reserved.
//

import MetalKit

protocol Texturable {
    var texture: MTLTexture? { get set }
}

extension Texturable {
    func setTexture(device: MTLDevice, imageName: String) -> MTLTexture? {
        let textureLoader = MTKTextureLoader(device: device)
        var texture: MTLTexture? = nil;
        let textureLoaderOptions: [MTKTextureLoader.Option: Any]
        
        if #available( iOS 10.0, *){
            textureLoaderOptions = [ .origin : MTKTextureLoader.Origin.bottomLeft ]
        } else {
            textureLoaderOptions = [:]
        }
        
        
        if let textureURL = Bundle.main.url(forResource: imageName, withExtension: nil) {
            do {
                texture = try textureLoader.newTexture(URL: textureURL, options: textureLoaderOptions)
            } catch {
                print("error making texture")
            }
        }
        
        return texture
    }
    
    func emptyTexture(device: MTLDevice, width: Int, height: Int) -> MTLTexture? {
        
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: width, height: height, mipmapped: false)
        textureDescriptor.usage = MTLTextureUsage(rawValue: MTLTextureUsage.renderTarget.rawValue | MTLTextureUsage.shaderRead.rawValue)
        let texture = device.makeTexture(descriptor:textureDescriptor);
        
        
        return texture;
    }
}
