//
//  RttScene.swift
//  mtkTest
//
//  Created by Adam Ferriss on 8/3/18.
//  Copyright © 2018 Adam Ferriss. All rights reserved.
//

import MetalKit

class RttScene : Scene {
    var quad: Plane
    
    override init(device: MTLDevice, size: CGSize) {
        quad = Plane(device: device, width: Int(size.width), height: Int(size.height))
        
        super.init(device: device, size: size)
        add(childNode: quad)
    }
    
    override func update(deltaTime: Float){
        
    }
}
