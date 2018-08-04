//
//  ViewController.swift
//  mtkTest
//
//  Created by Adam Ferriss on 8/1/18.
//  Copyright © 2018 Adam Ferriss. All rights reserved.
//

import UIKit
import MetalKit

enum Colors {
    static let green = MTLClearColor(red: 0.0, green: 0.4, blue: 0.2, alpha: 1.0)
    static let black = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
}

class ViewController: UIViewController {

    var metalView: MTKView {
        return view as! MTKView
    }
    
    var renderer: Renderer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        metalView.device = MTLCreateSystemDefaultDevice()
    
        guard let device = metalView.device else {
            fatalError("Device not created, Run on a real device")
        }
        
        
        metalView.clearColor = Colors.black
        
        metalView.framebufferOnly = false;
        
        renderer = Renderer(device: device)
        renderer?.scene = GameScene(device: device, size: view.bounds.size)
        renderer?.rttScene = RttScene(device: device, size: view.bounds.size)
        
        metalView.delegate = renderer
        
        
    }
}

