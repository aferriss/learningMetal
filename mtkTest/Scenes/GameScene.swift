//
//  GameScene.swift
//  mtkTest
//
//  Created by Adam Ferriss on 8/1/18.
//  Copyright © 2018 Adam Ferriss. All rights reserved.
//

import MetalKit

class GameScene: Scene {
    var quad: Plane
//    var quad2: Plane
    
    override init(device: MTLDevice, size: CGSize){
//        quad = Plane(device: device)
//        quad = Plane(device: device, imageName: "matador.png")
        quad = Plane(device: device, imageName: "mars.jpg", shader: "fullScreen" )
//        quad = Plane(device: device, imageName: "matador.png", maskImageName: "picture-frame-mask.png")
        
//        let frame = Plane(device: device, imageName: "picture-frame.png")
        
        
        
//        quad.position.x = -1
//        quad.position.y = 1
    
        
//        quad2 = Plane(device: device, imageName: "matador.png")
//        quad2.position.x = 1
//        quad2.scale = float3(0.5)
//        quad2.position.y = 1.5
//        quad.add(childNode: quad2)
        
//        add(childNode: quad2)
        super.init(device: device, size: size)
        
        add(childNode: quad)
    }
    
    override func update(deltaTime: Float){
//        quad.rotation.y += deltaTime
//        quad2.rotation.y += deltaTime
        
    }
    
    
}
