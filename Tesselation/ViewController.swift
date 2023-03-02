//
//  ViewController.swift
//  MetalProject
//
//  Created by Sina Dashtebozorgy on 22/12/2022.
//




import Cocoa
import Metal
import MetalKit

class ViewController: NSViewController{
    
    var SceneChanged = false 
    
    
    @IBOutlet weak var xSlider: NSSlider!
    @IBOutlet weak var ySlider: NSSlider!
    
    @IBAction func setTesselationLevel(_ sender: NSSlider) {
        switch sender {
        case xSlider:
            renderer.tesselationLevel[0] = Int(sender.doubleValue)
            renderer.changedTesselationFactors = true
            break
        case ySlider:
            renderer.tesselationLevel[1] = Int(sender.doubleValue)
            renderer.changedTesselationFactors = true
            break
        default:
            break
        }
    }

    
    
    override var acceptsFirstResponder: Bool {
        get{
            return true
        }
      
    }
    
    var linearButtonPos = [simd_float4]() {
        didSet {
            renderer.linearPoints2 = linearButtonPos
            renderer.pointsUpdated = true
        }
    }
    
    var secondDegreeButtonPos = [simd_float4]() {
        didSet {
            renderer.secondDegreeBezierPoints0 = secondDegreeButtonPos
            renderer.pointsUpdated = true
        }
    }
    
    var thirdDegreeButtonPos = [simd_float4]() {
        didSet {
            renderer.thirdDegreeBezierPoints0 = thirdDegreeButtonPos
            renderer.pointsUpdated = true
        }
    }
    
    private var previousButtonsPressed  = [Int]()
    private var currentButtonIndex = 0
    
    
    override func mouseDragged(with event: NSEvent) {
        let cutoffx : Float = 15/1000
        let cutoffy : Float = 15/867
        var mouseposx = event.locationInWindow.x
        var mouseposy = event.locationInWindow.y
        mouseposx = (mouseposx/1000)*2 - 1
        mouseposy = (mouseposy/867)*2 - 1
        let mousepos = simd_float4(Float(mouseposx), Float(mouseposy),0,1)
        if(Scene == .linear && vCPs == .v_0){
            var newPos = [simd_float4](repeating : simd_float4(1), count : 2)
            for (index,pos) in renderer.linearPoints0.enumerated() {
                let diffx = abs(mousepos.x - pos.x)
                let diffy = abs(mousepos.y - pos.y)
                if(diffx < cutoffx  && diffy < cutoffy){
                    newPos[index] = mousepos
                }
                else{
                    newPos[index] = renderer.linearPoints0[index]
                }
            }
            renderer.linearPoints0 = newPos
            renderer.pointsUpdated = true
        }
        else if(Scene == .linear && vCPs == .v_1){
            var newPos = [simd_float4](repeating : simd_float4(1), count : 3)
            for (index,pos) in renderer.linearPoints1.enumerated() {
                let diffx = abs(mousepos.x - pos.x)
                let diffy = abs(mousepos.y - pos.y)
                if(diffx < cutoffx  && diffy < cutoffy){
                    newPos[index] = mousepos
                    print(index)
                }
                else{
                    newPos[index] = renderer.linearPoints1[index]
                }
            }
            renderer.linearPoints1 = newPos
            renderer.pointsUpdated = true
            
        }
        else if(Scene == .linear && vCPs == .v_2){
            var newPos = [simd_float4](repeating : simd_float4(1), count : 4)
            for (index,pos) in renderer.linearPoints2.enumerated() {
                let diffx = abs(mousepos.x - pos.x)
                let diffy = abs(mousepos.y - pos.y)
                if(diffx < cutoffx  && diffy < cutoffy){
                    newPos[index] = mousepos
                }
                else{
                    newPos[index] = renderer.linearPoints2[index]
                }
            }
            renderer.linearPoints2 = newPos
            renderer.pointsUpdated = true
        }
        else if(Scene == .second && vCPs == .v_0){
            var newPos = [simd_float4](repeating : simd_float4(1), count : 3)
            for (index,pos) in renderer.secondDegreeBezierPoints0.enumerated() {
                let diffx = abs(mousepos.x - pos.x)
                let diffy = abs(mousepos.y - pos.y)
                if(diffx < cutoffx  && diffy < cutoffy){
                    newPos[index] = mousepos
                }
                else{
                    newPos[index] = renderer.secondDegreeBezierPoints0[index]
                }
            }
            renderer.secondDegreeBezierPoints0 = newPos
            renderer.pointsUpdated = true
        }
        
        else if(Scene == .second && vCPs == .v_1){
            var newPos = [simd_float4](repeating : simd_float4(1), count : 4)
            for (index,pos) in renderer.secondDegreeBezierPoints1.enumerated() {
                let diffx = abs(mousepos.x - pos.x)
                let diffy = abs(mousepos.y - pos.y)
                if(diffx < cutoffx  && diffy < cutoffy){
                    newPos[index] = mousepos
                }
                else{
                    newPos[index] = renderer.secondDegreeBezierPoints1[index]
                }
            }
            renderer.secondDegreeBezierPoints1 = newPos
            renderer.pointsUpdated = true
        }
        else if(Scene == .second && vCPs == .v_2){
            var newPos = [simd_float4](repeating : simd_float4(1), count : 5)
            for (index,pos) in renderer.secondDegreeBezierPoints2.enumerated() {
                let diffx = abs(mousepos.x - pos.x)
                let diffy = abs(mousepos.y - pos.y)
                if(diffx < cutoffx  && diffy < cutoffy){
                    newPos[index] = mousepos
                }
                else{
                    newPos[index] = renderer.secondDegreeBezierPoints2[index]
                }
            }
            renderer.secondDegreeBezierPoints2 = newPos
            renderer.pointsUpdated = true
        }
        
        else if(Scene == .third && vCPs == .v_0){
            var newPos = [simd_float4](repeating : simd_float4(1), count : 4)
            for (index,pos) in renderer.thirdDegreeBezierPoints0.enumerated() {
                let diffx = abs(mousepos.x - pos.x)
                let diffy = abs(mousepos.y - pos.y)
                if(diffx < cutoffx  && diffy < cutoffy){
                    newPos[index] = mousepos
                }
                else{
                    newPos[index] = renderer.thirdDegreeBezierPoints0[index]
                }
            }
            renderer.thirdDegreeBezierPoints0 = newPos
            renderer.pointsUpdated = true
        }
        
        else if(Scene == .third && vCPs == .v_0){
            var newPos = [simd_float4](repeating : simd_float4(1), count : 5)
            for (index,pos) in renderer.thirdDegreeBezierPoints1.enumerated() {
                let diffx = abs(mousepos.x - pos.x)
                let diffy = abs(mousepos.y - pos.y)
                if(diffx < cutoffx  && diffy < cutoffy){
                    newPos[index] = mousepos
                }
                else{
                    newPos[index] = renderer.thirdDegreeBezierPoints1[index]
                }
            }
            renderer.thirdDegreeBezierPoints1 = newPos
            renderer.pointsUpdated = true
        }
        
        else{
            var newPos = [simd_float4](repeating : simd_float4(1), count : 6)
            for (index,pos) in renderer.thirdDegreeBezierPoints2.enumerated() {
                let diffx = abs(mousepos.x - pos.x)
                let diffy = abs(mousepos.y - pos.y)
                if(diffx < cutoffx  && diffy < cutoffy){
                    newPos[index] = mousepos
                }
                else{
                    newPos[index] = renderer.thirdDegreeBezierPoints2[index]
                }
            }
            renderer.thirdDegreeBezierPoints2 = newPos
            renderer.pointsUpdated = true
        }
       
       

    }
    
    override func mouseDown(with event: NSEvent) {
        let cutoffx : Float = 15/1000
        let cutoffy : Float = 15/867
        var mouseposx = event.locationInWindow.x
        var mouseposy = event.locationInWindow.y
        mouseposx = (mouseposx/1000)*2 - 1
        mouseposy = (mouseposy/867)*2 - 1
        let mousepos = simd_float4(Float(mouseposx), Float(mouseposy),0,1)
        for (index,pos) in renderer.linearPoints2.enumerated() {
            let diffx = abs(mousepos.x - pos.x)
            let diffy = abs(mousepos.y - pos.y)
            if(diffx < cutoffx  && diffy < cutoffy){
                if(!previousButtonsPressed.contains(index)){
                    previousButtonsPressed.append(index)
                }
                currentButtonIndex = index
                return
                
            }
           
        }
    }

    var mtkView: MTKView!
    var renderer: Renderer!
    
    
    
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        

        // First we save the MTKView to a convenient instance variable
        
        
        
        guard let mtkViewTemp = self.view as? MTKView else {
            print("View attached to ViewController is not an MTKView!")
            return
        }
       
        
        
        mtkView = mtkViewTemp
        mtkView.frame = NSRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 1000, height: 1000))
        print(mtkView.drawableSize)
      
        
        
       
        

        // Then we create the default device, and configure mtkView with it
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported on this device")
            return
        }

        print("My GPU is: \(defaultDevice)")
        mtkView.device = defaultDevice

        // Lastly we create an instance of our Renderer object,
        // and set it as the delegate of mtkView
        guard let tempRenderer = Renderer(mtkView: mtkView) else {
            print("Renderer failed to initialize")
            return
        }
       renderer = tempRenderer
       mtkView.delegate = renderer
    }
}



