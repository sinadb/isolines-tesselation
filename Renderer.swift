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
    
    var tesselationLevel : [Int]  = [5,5]
    // 3 scenes
    var tesselationScene : Mode?
    // dictates number of vertical tesselation control points to interpolate
    var verticalCPs : extraCP?
   
    
    var pointsUpdated : Bool = false
    var changedTesselationFactors : Bool = false
    
    // linear tesselation scene data
    
    var linearPoints2 : [simd_float4] = [simd_float4(-0.5,-0.5,0,1), simd_float4(0.5,-0.5,0,1),simd_float4(-0.5,0.5,0,1),simd_float4(0.5,0.5,0,1)]
    var linearPoints1 : [simd_float4] = [simd_float4(-0.5,-0.5,0,1), simd_float4(0.5,-0.5,0,1),simd_float4(-0.5,0.5,0,1)]
    var linearPoints0: [simd_float4] = [simd_float4(-0.5,-0.5,0,1),simd_float4(0.5,-0.5,0,1)]
    
    let linearTesselation0 : lineTesselation
    let linearTesselation1 : lineTesselation
    let linearTesselation2 : lineTesselation
    
    var secondDegreeBezierPoints2 : [simd_float4] = [simd_float4(-0.5,0,0,1),simd_float4(-0.5,0.5,0,1),simd_float4(0.5,0.0,0,1),simd_float4(-0.6,0.6,0,1),simd_float4(0.6,0.6,0,1)]
    var secondDegreeBezierPoints1 : [simd_float4] = [simd_float4(-0.5,0,0,1),simd_float4(-0.5,0.5,0,1),simd_float4(0.5,0.0,0,1),simd_float4(-0.6,0.6,0,1)]
    var secondDegreeBezierPoints0 : [simd_float4] = [simd_float4(-0.5,0,0,1),simd_float4(-0.5,0.5,0,1),simd_float4(0.5,0.0,0,1)]
    
    let secondDegreeTesselation2 : lineTesselation
    let secondDegreeTesselation1 : lineTesselation
    let secondDegreeTesselation0 : lineTesselation
    
    let device: MTLDevice
    let commandQueue: MTLCommandQueue
    var pointPipeline : MTLRenderPipelineState
    
    
    var thirdDegreeBezierPoints0 : [simd_float4] = [simd_float4(-0.5,-0.5,0,1),simd_float4(-0.25,0.5,0,1),simd_float4(0,-0.5,0,1 ),simd_float4(0.25,0.5,0,1)]
    var thirdDegreeBezierPoints1 : [simd_float4] = [simd_float4(-0.5,-0.5,0,1),simd_float4(-0.25,0.5,0,1),simd_float4(0,-0.5,0,1 ),simd_float4(0.25,0.5,0,1),simd_float4(-0.6,0.6,0,1)]
    var thirdDegreeBezierPoints2 : [simd_float4] = [simd_float4(-0.5,-0.5,0,1),simd_float4(-0.25,0.5,0,1),simd_float4(0,-0.5,0,1 ),simd_float4(0.25,0.5,0,1),simd_float4(-0.6,0.6,0,1),simd_float4(0.6,0.6,0,1)]
    
    let thirdDegreeTesselation0 : lineTesselation
    let thirdDegreeTesselation1 : lineTesselation
    let thirdDegreeTesselation2 : lineTesselation
    
    var SceneGraph = [lineTesselation]()
    
    
//    func updateLinearPoints(){
//        if(pointsUpdated){
//            linearTesselation.controlPointBuffer?.contents().copyMemory(from: linearPoints, byteCount: MemoryLayout<simd_float4>.stride*4)
//            pointsUpdated = false
//            //linearTesselation.updateControlPoints(with: linearPoints)
//
//        }
//    }
//    func updateSecondDegreePoints(){
//        if(pointsUpdated){
//            secondDegreeTesselation.controlPointBuffer?.contents().copyMemory(from: secondDegreeBezierPoints, byteCount: MemoryLayout<simd_float4>.stride*secondDegreeBezierPoints.count)
//            pointsUpdated = false
//            //secondDegreeTesselation.updateControlPoints(with: secondDegreeBezierPoints)
//
//        }
//    }
//    func updateThirdDegreePoints(){
//        if(pointsUpdated){
//            thirdDegreeTesselation.controlPointBuffer?.contents().copyMemory(from: thirdDegreeBezierPoints, byteCount: MemoryLayout<simd_float4>.stride*thirdDegreeBezierPoints.count)
//            pointsUpdated = false
//
//
//        }
//    }
     init?(mtkView: MTKView) {
        
        device = mtkView.device!
         mtkView.preferredFramesPerSecond = 120
         
         mtkView.colorPixelFormat = .bgra8Unorm
         
         
         linearTesselation0 = lineTesselation(device, .linear, with: tesselationLevel, CPCount: 2)!
         linearTesselation0.initialiseBuffer(with: linearPoints0)
         linearTesselation0.tesselate()
         SceneGraph.append(linearTesselation0)
         
         linearTesselation1 = lineTesselation(device, .linear, with: tesselationLevel, CPCount: 3)!
         linearTesselation1.initialiseBuffer(with: linearPoints1)
         linearTesselation1.tesselate()
         SceneGraph.append(linearTesselation1)
         
         linearTesselation2 = lineTesselation(device, .linear, with: tesselationLevel, CPCount: 4)!
         linearTesselation2.initialiseBuffer(with: linearPoints2)
         linearTesselation2.tesselate()
         SceneGraph.append(linearTesselation2)
         
         secondDegreeTesselation0 = lineTesselation(device, .second, with: tesselationLevel, CPCount: 3)!
         secondDegreeTesselation0.initialiseBuffer(with: secondDegreeBezierPoints0)
         secondDegreeTesselation0.tesselate()
         SceneGraph.append(secondDegreeTesselation0)
         
         secondDegreeTesselation1 = lineTesselation(device, .second, with: tesselationLevel, CPCount: 4)!
         secondDegreeTesselation1.initialiseBuffer(with: secondDegreeBezierPoints1)
         secondDegreeTesselation1.tesselate()
         SceneGraph.append(secondDegreeTesselation1)
         
         
         secondDegreeTesselation2 = lineTesselation(device, .second, with: tesselationLevel, CPCount: 5)!
         secondDegreeTesselation2.initialiseBuffer(with: secondDegreeBezierPoints2)
         secondDegreeTesselation2.tesselate()
         SceneGraph.append(secondDegreeTesselation2)
         
         
         thirdDegreeTesselation0 = lineTesselation(device, .third, with: tesselationLevel, CPCount: 4)!
         thirdDegreeTesselation0.initialiseBuffer(with: thirdDegreeBezierPoints0)
         thirdDegreeTesselation0.tesselate()
         SceneGraph.append(thirdDegreeTesselation0)
         
         
         thirdDegreeTesselation1 = lineTesselation(device, .third, with: tesselationLevel, CPCount: 5)!
         thirdDegreeTesselation1.initialiseBuffer(with: thirdDegreeBezierPoints1)
         thirdDegreeTesselation1.tesselate()
         SceneGraph.append(thirdDegreeTesselation1)
         
         thirdDegreeTesselation2 = lineTesselation(device, .third, with: tesselationLevel, CPCount: 6)!
         thirdDegreeTesselation2.initialiseBuffer(with: thirdDegreeBezierPoints2)
         thirdDegreeTesselation2.tesselate()
         SceneGraph.append(thirdDegreeTesselation2)
         
       
         
        
         
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
        
        if(changedTesselationFactors){
            for element in SceneGraph{
                element.updateTesselationLevel(with: tesselationLevel)
            }
            changedTesselationFactors = false
        }
        if(pointsUpdated){
            if let mode = Scene, let v = vCPs {
                switch mode {
                case .linear:
                    switch v {
                    case .v_0 :
                        linearTesselation0.updateControlPoints(with: linearPoints0)
                        pointsUpdated = false
                        break
                    case .v_1 :
                        linearTesselation1.updateControlPoints(with: linearPoints1)
                        pointsUpdated = false
                    case .v_2 :
                        linearTesselation2.updateControlPoints(with: linearPoints2)
                        pointsUpdated = false
                        break
                    default :
                        break
                    }
                case .second:
                    switch v {
                    case .v_0 :
                        secondDegreeTesselation0.updateControlPoints(with: secondDegreeBezierPoints0)
                        pointsUpdated = false
                        break
                    case .v_1 :
                        secondDegreeTesselation1.updateControlPoints(with: secondDegreeBezierPoints1)
                        pointsUpdated = false
                        break
                    case .v_2 :
                        secondDegreeTesselation2.updateControlPoints(with: secondDegreeBezierPoints2)
                        pointsUpdated = false
                        break
                    default :
                        break
                    }
                case .third:
                    switch v {
                    case .v_0 :
                        thirdDegreeTesselation0.updateControlPoints(with: thirdDegreeBezierPoints0)
                        pointsUpdated = false
                        break
                    case .v_1 :
                        thirdDegreeTesselation1.updateControlPoints(with: thirdDegreeBezierPoints1)
                        pointsUpdated = false
                        break
                    case .v_2 :
                        thirdDegreeTesselation2.updateControlPoints(with: thirdDegreeBezierPoints2)
                        pointsUpdated = false
                        break
                    default :
                        break
                    }
                default:
                    break
                }
            }
        }
        
        
        if let mode = Scene, let v = vCPs {
            switch mode {
            case .linear:
                switch v {
                case .v_0 :
                    linearTesselation0.tesselate()
                    linearTesselation0.draw(in: view, with: pointPipeline)
                    break
                case .v_1 :
                    linearTesselation1.tesselate()
                    linearTesselation1.draw(in: view, with: pointPipeline)
                    break
                case .v_2 :
                    linearTesselation2.tesselate()
                    linearTesselation2.draw(in: view, with: pointPipeline)
                    break
                default :
                    break
                }
            case .second:
                switch v {
                case .v_0 :
                    secondDegreeTesselation0.tesselate()
                    secondDegreeTesselation0.draw(in: view, with: pointPipeline)
                    break
                case .v_1 :
                    secondDegreeTesselation1.tesselate()
                    secondDegreeTesselation1.draw(in: view, with: pointPipeline)
                    break
                case .v_2 :
                    secondDegreeTesselation2.tesselate()
                    secondDegreeTesselation2.draw(in: view, with: pointPipeline)
                    break
                default :
                    break
                }
            case .third:
                switch v {
                case .v_0 :
                    thirdDegreeTesselation0.tesselate()
                    thirdDegreeTesselation0.draw(in: view, with: pointPipeline)
                    break
                case .v_1 :
                    thirdDegreeTesselation1.tesselate()
                    thirdDegreeTesselation1.draw(in: view, with: pointPipeline)
                    break
                case .v_2 :
                    thirdDegreeTesselation2.tesselate()
                    thirdDegreeTesselation2.draw(in: view, with: pointPipeline)
                    break
                default :
                    break
                }
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
