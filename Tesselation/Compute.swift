//
//  Compute.swift
//  TestMetal
//
//  Created by Sina Dashtebozorgy on 21/02/2023.
//


import Foundation
import MetalKit
import AppKit
import Cocoa
import simd


enum Mode : Int{
    
    case linear = 2
    case second = 3
    case third = 4
}

class lineTesselation {
    

    let device : MTLDevice
    let computePipelineState : MTLComputePipelineState?
    let commandQueue : MTLCommandQueue?
    var tesselationFactors : [Int]
    let tesselationMode : Mode
    var pointsBuffer : MTLBuffer?
    var outputBuffer : MTLBuffer?
    var threadsLength : Int
    var controlPointCount : Int
    var controlPointBuffer : MTLBuffer?
    var CPSize : Float = 30
    var OPSize : Float = 3
    
    init?(_ device : MTLDevice, _ mode : Mode, with tesselationLevels : [Int], CPCount : inout Int){
        self.device = device
        tesselationMode = mode
        tesselationFactors = tesselationLevels
        controlPointCount = CPCount
        print(controlPointCount)
        let computeFunctionConstant = MTLFunctionConstantValues()
        var tesselationModeValue = mode.rawValue
        computeFunctionConstant.setConstantValue(&tesselationModeValue, type: .int, index: 0)
        computeFunctionConstant.setConstantValue(&CPCount, type: .int, index: 1)
        let library = device.makeDefaultLibrary()!
        let computeFunction = try! library.makeFunction(name: "tesselate", constantValues: computeFunctionConstant)
        do{
            try computePipelineState = device.makeComputePipelineState(function: computeFunction)
        }
        catch{
            print("Failed to initialise the compute pipeline")
            return nil
        }
        
        switch mode.rawValue {
        case 2:
            threadsLength = (tesselationLevels[0] + 1)*(tesselationLevels[1] + 1)
            break
        case 3:
            if(CPCount == 3){
                threadsLength = (tesselationLevels[0] + 1)
                tesselationFactors[1] = 0
                
            }
            else{
                threadsLength = (tesselationLevels[0] + 1)*(tesselationLevels[1] + 1)
            }
            break
        case 4:
            if(CPCount == 4){
                threadsLength = (tesselationLevels[0] + 1)
                tesselationFactors[1] = 0
            }
            else{
                threadsLength = (tesselationLevels[0] + 1)*(tesselationLevels[1] + 1)
            }
        default:
            return nil
        }
        
        
        commandQueue = device.makeCommandQueue()
        
    }
   
    func initialiseBuffer(with points : [simd_float4]){
        switch tesselationMode.rawValue {
        case 2:
            controlPointBuffer = device.makeBuffer(bytes: points, length: MemoryLayout<simd_float4>.stride*4, options: [])
            outputBuffer = device.makeBuffer(length: MemoryLayout<simd_float4>.stride*threadsLength, options: [])
            break
        case 3:
            switch points.count {
            case 3:
                controlPointBuffer = device.makeBuffer(bytes: points, length: MemoryLayout<simd_float4>.stride*3, options: [])
                outputBuffer = device.makeBuffer(length: MemoryLayout<simd_float4>.stride*threadsLength, options: [])
                break
            case 4:
                controlPointBuffer = device.makeBuffer(bytes: points, length: MemoryLayout<simd_float4>.stride*4, options: [])
                outputBuffer = device.makeBuffer(length: MemoryLayout<simd_float4>.stride*threadsLength, options: [])
                break
            case 5:
                controlPointBuffer = device.makeBuffer(bytes: points, length: MemoryLayout<simd_float4>.stride*5, options: [])
                
                outputBuffer = device.makeBuffer(length: MemoryLayout<simd_float4>.stride*threadsLength, options: [])
                break
            default:
                break
            }
            break
        case 4:
            switch points.count {
            case 4:
                controlPointBuffer = device.makeBuffer(bytes: points, length: MemoryLayout<simd_float4>.stride*4, options: [])
                outputBuffer = device.makeBuffer(length: MemoryLayout<simd_float4>.stride*threadsLength, options: [])
                break
            case 5:
                controlPointBuffer = device.makeBuffer(bytes: points, length: MemoryLayout<simd_float4>.stride*5, options: [])
                outputBuffer = device.makeBuffer(length: MemoryLayout<simd_float4>.stride*threadsLength, options: [])
                break
            case 6:
                controlPointBuffer = device.makeBuffer(bytes: points, length: MemoryLayout<simd_float4>.stride*6, options: [])
                
                outputBuffer = device.makeBuffer(length: MemoryLayout<simd_float4>.stride*threadsLength, options: [])
                break
            default:
                break
            }
            break
        default:
            break
        }
        
    }
    
    func updateControlPoints(with points : [simd_float4]){
        switch tesselationMode.rawValue {
        case 2:
            pointsBuffer?.contents().copyMemory(from: points, byteCount: MemoryLayout<simd_float4>.stride*4)
            break
        case 3:
            pointsBuffer?.contents().copyMemory(from: points, byteCount: MemoryLayout<simd_float4>.stride*3)
        case 4:
            pointsBuffer?.contents().copyMemory(from: points, byteCount: MemoryLayout<simd_float4>.stride*4)
            break
        default:
            break
        }
    }
    
    
    
    func tesselateLinear(){
        guard let commandBuffer = commandQueue?.makeCommandBuffer() else {return}
        guard let computeEncoder = commandBuffer.makeComputeCommandEncoder() else {return}
        computeEncoder.setComputePipelineState(computePipelineState!)
        computeEncoder.setBuffer(controlPointBuffer, offset: 0, index: 0)
        computeEncoder.setBuffer(outputBuffer, offset: 0, index: 1)
        var factor = simd_float2(Float(tesselationFactors[0]),Float(tesselationFactors[1]))
        computeEncoder.setBytes(&factor, length: MemoryLayout<simd_float2>.stride, index: 2)
        computeEncoder.dispatchThreads(MTLSize(width: tesselationFactors[0] + 1, height: tesselationFactors[1] + 1, depth: 1), threadsPerThreadgroup: MTLSize(width: 32, height: 32, depth: 1))
        
        computeEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
    }
    
    func tesselateSecond(){
        guard let commandBuffer = commandQueue?.makeCommandBuffer() else {return}
        guard let computeEncoder = commandBuffer.makeComputeCommandEncoder() else {return}
        computeEncoder.setComputePipelineState(computePipelineState!)
        computeEncoder.setBuffer(controlPointBuffer, offset: 0, index: 0)
        computeEncoder.setBuffer(outputBuffer, offset: 0, index: 1)
        var factor = simd_float2(Float(tesselationFactors[0]),Float(tesselationFactors[1]))
        computeEncoder.setBytes(&factor, length: MemoryLayout<simd_float2>.stride, index: 2)
        computeEncoder.dispatchThreads(MTLSize(width: tesselationFactors[0] + 1, height: tesselationFactors[1] + 1, depth: 1), threadsPerThreadgroup: MTLSize(width: 32, height: 32, depth: 1))
        computeEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        
    }
    
    func tesselateThird(){
        guard let commandBuffer = commandQueue?.makeCommandBuffer() else {return}
        guard let computeEncoder = commandBuffer.makeComputeCommandEncoder() else {return}
        computeEncoder.setComputePipelineState(computePipelineState!)
        computeEncoder.setBuffer(controlPointBuffer, offset: 0, index: 0)
        computeEncoder.setBuffer(outputBuffer, offset: 0, index: 1)
        var factor = simd_float2(Float(tesselationFactors[0]),Float(tesselationFactors[1]))
        computeEncoder.setBytes(&factor, length: MemoryLayout<simd_float2>.stride, index: 2)
        computeEncoder.dispatchThreads(MTLSize(width: tesselationFactors[0] + 1, height: tesselationFactors[1] + 1, depth: 1), threadsPerThreadgroup: MTLSize(width: 32, height: 32, depth: 1))
        computeEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
    
    func tesselate(){
        switch tesselationMode.rawValue {
        case 2:
            tesselateLinear()
            break
        case 3:
            tesselateSecond()
            break
        case 4:
            tesselateThird()
            break
        default:
            break
        }
    }
    
    func draw(in view : MTKView, with pipeline : MTLRenderPipelineState){
        guard let commandBuffer = commandQueue?.makeCommandBuffer() else {return}
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else {return}
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1, 1, 1, 1)
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        guard let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {return}

        renderEncoder.setRenderPipelineState(pipeline)
        renderEncoder.setVertexBuffer(outputBuffer, offset: 0, index: 0)
        renderEncoder.setVertexBytes(&OPSize, length: 4, index: 4)
        renderEncoder.setFragmentBytes(&Colours.red, length: MemoryLayout<simd_float4>.stride, index: 3)
        renderEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: threadsLength)
        let width = tesselationFactors[0]
        for i in 0...tesselationFactors[1]{
            renderEncoder.drawPrimitives(type: .lineStrip, vertexStart: i + i*width, vertexCount: width + 1 )
        }
        renderEncoder.endEncoding()
//
//        switch tesselationMode.rawValue {
//        case 2:
//            renderEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: threadsLength)
//            let width = tesselationFactors[0]
//            for i in 0...tesselationFactors[1]{
//                renderEncoder.drawPrimitives(type: .lineStrip, vertexStart: i + i*width, vertexCount: width + 1 )
//            }
//            renderEncoder.endEncoding()
//            break
//        case 3:
//            renderEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: threadsLength)
//            let width = tesselationFactors[0]
//            for i in 0...tesselationFactors[1]{
//                renderEncoder.drawPrimitives(type: .lineStrip, vertexStart: i + i*width, vertexCount: width + 1 )
//            }
//            renderEncoder.endEncoding()
//            break
//        case 4:
//            renderEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: threadsLength)
//            let width = tesselationFactors[0]
//            for i in 0...tesselationFactors[1]{
//                renderEncoder.drawPrimitives(type: .lineStrip, vertexStart: i + i*width, vertexCount: width + 1 )
//            }
//            renderEncoder.endEncoding()
//        default:
//            break
//        }
//
//
       
        
        renderPassDescriptor.colorAttachments[0].loadAction = .load
        
        guard let controlPointsRenderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {return}
       
        controlPointsRenderEncoder.setRenderPipelineState(pipeline)
        controlPointsRenderEncoder.setVertexBuffer(controlPointBuffer, offset: 0, index: 0)
        controlPointsRenderEncoder.setVertexBytes(&CPSize, length: 4, index: 4)
        controlPointsRenderEncoder.setFragmentBytes(&Colours.green, length: MemoryLayout<simd_float4>.stride, index: 3)
        controlPointsRenderEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: controlPointCount)
       
        controlPointsRenderEncoder.endEncoding()
        

        commandBuffer.present(view.currentDrawable!)
        commandBuffer.commit()
        
    }
}

