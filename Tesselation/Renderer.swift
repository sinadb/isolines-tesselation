//
//  Renderer.swift
//  MetalProject
//
//  Created by Sina Dashtebozorgy on 22/12/2022.
//

import Foundation
import Metal
import MetalKit
import AppKit
import Cocoa


struct Colours {
    static var green = simd_float4(0,1,0,1)
    static var red = simd_float4(1,0,0,1)
}








func buildRenderPipeLineWith(device : MTLDevice, mtkView : MTKView , vertexDescriptor : MTLVertexDescriptor)throws -> MTLRenderPipelineState{
    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    let library = device.makeDefaultLibrary()
    pipelineDescriptor.vertexFunction = library?.makeFunction(name: "tesselation_shader_triangle")
    pipelineDescriptor.fragmentFunction = library?.makeFunction(name: "fragmentShader")
    pipelineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
    pipelineDescriptor.supportIndirectCommandBuffers = true
    pipelineDescriptor.vertexDescriptor = vertexDescriptor
    pipelineDescriptor.depthAttachmentPixelFormat = mtkView.depthStencilPixelFormat
    
    
    
    
    return try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
}



class Renderer : NSObject, MTKViewDelegate {
    
    // 3 scenes
    var tesselationScene : Mode?
    var pointsUpdated : Bool = false
    var linearPoints : [simd_float4] = [simd_float4(-0.5,-0.5,0,1), simd_float4(0.5,-0.5,0,1),simd_float4(-0.5,0.5,0,1),simd_float4(0.5,0.5,0,1)]
    
    var secondDegreeBezierPoints : [simd_float4] = [simd_float4(-0.5,0,0,1),simd_float4(-0.5,0.5,0,1),simd_float4(0.5,0.0,0,1),simd_float4(-0.6,0.6,0,1),simd_float4(0.6,0.6,0,1)]
    let secondDegreeTesselation : lineTesselation
    let linearTesselation : lineTesselation
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    var pointPipeline : MTLRenderPipelineState
    let rValues : [Float] = [1,2,3,4,5]
    let rBuffer : MTLBuffer
    
    var thirdDegreeBezierPoints : [simd_float4] = [simd_float4(-0.5,-0.5,0,1),simd_float4(-0.25,0.5,0,1),simd_float4(0,-0.5,0,1 ),simd_float4(0.25,0.5,0,1)]
    var thirdDegreeTesselation : lineTesselation

    
    
    func updateLinearPoints(){
        if(pointsUpdated){
            linearTesselation.controlPointBuffer?.contents().copyMemory(from: linearPoints, byteCount: MemoryLayout<simd_float4>.stride*4)
            pointsUpdated = false
            //linearTesselation.updateControlPoints(with: linearPoints)
            
        }
    }
    func updateSecondDegreePoints(){
        if(pointsUpdated){
            secondDegreeTesselation.controlPointBuffer?.contents().copyMemory(from: secondDegreeBezierPoints, byteCount: MemoryLayout<simd_float4>.stride*secondDegreeBezierPoints.count)
            pointsUpdated = false
            //secondDegreeTesselation.updateControlPoints(with: secondDegreeBezierPoints)
            
        }
    }
    func updateThirdDegreePoints(){
        if(pointsUpdated){
            thirdDegreeTesselation.controlPointBuffer?.contents().copyMemory(from: thirdDegreeBezierPoints, byteCount: MemoryLayout<simd_float4>.stride*thirdDegreeBezierPoints.count)
            pointsUpdated = false
           
            
        }
    }
     init?(mtkView: MTKView) {
        
        device = mtkView.device!
         mtkView.preferredFramesPerSecond = 120
         
         mtkView.colorPixelFormat = .bgra8Unorm
         
         var count = 4
         linearTesselation = lineTesselation(device, .linear, with: [5,5], CPCount: &count)!
         linearTesselation.initialiseBuffer(with: linearPoints)
         linearTesselation.tesselate()
         
         count = 5
         secondDegreeTesselation = lineTesselation(device, .second, with: [30,3], CPCount: &count)!
         secondDegreeTesselation.initialiseBuffer(with: secondDegreeBezierPoints)
         secondDegreeTesselation.tesselate()
         
         count = 4
         thirdDegreeTesselation = lineTesselation(device, .third, with: [10000,3], CPCount: &count)!
         thirdDegreeTesselation.initialiseBuffer(with: thirdDegreeBezierPoints)
         thirdDegreeTesselation.tesselate()
         
         rBuffer = device.makeBuffer(bytes: rValues, length: MemoryLayout<Float>.stride*5, options: [])!
         var tempValues : [Float] = [7,8,9,6,7]
         rBuffer.contents().copyMemory(from: tempValues, byteCount: 4*3)
         let ptr = rBuffer.contents().bindMemory(to: Float.self, capacity: 5)
         
         for i in 0...4{
             print("\(i)th value is : \((ptr+i).pointee)")
         }
         
        
         
         let tempLib = device.makeDefaultLibrary()!
         let pointPipeLineDescriptor = MTLRenderPipelineDescriptor()
         pointPipeLineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
         pointPipeLineDescriptor.vertexFunction = tempLib.makeFunction(name: "pointVertexShader")!
         pointPipeLineDescriptor.fragmentFunction = tempLib.makeFunction(name: "pointFragmentShader")
         
         try! pointPipeline = device.makeRenderPipelineState(descriptor: pointPipeLineDescriptor)
         
         
         
         
    
         
      
        commandQueue = device.makeCommandQueue()!
       
       
        
    }
   
    // mtkView will automatically call this function
    // whenever it wants new content to be rendered.
    func draw(in view: MTKView) {
        
        if let mode = tesselationScene {
            switch mode {
            case .linear:
                updateLinearPoints()
                linearTesselation.tesselate()
                linearTesselation.draw(in: view, with: pointPipeline)
            case .second:
                updateSecondDegreePoints()
                secondDegreeTesselation.tesselate()
                secondDegreeTesselation.draw(in: view, with: pointPipeline)
                break
            case .third:
                updateThirdDegreePoints()
                thirdDegreeTesselation.tesselate()
                thirdDegreeTesselation.draw(in: view, with: pointPipeline)
                break
            default:
                break
            }
        }
        

        
        
        

      
    }
    

    // mtkView will automatically call this function
    // whenever the size of the view changes (such as resizing the window).
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
}
