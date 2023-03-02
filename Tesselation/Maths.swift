//
//  Maths.swift
//  MetalProject
//
//  Created by Sina Dashtebozorgy on 23/12/2022.
//




import Foundation



func create_scale_matrix(scale : simd_float3)->simd_float4x4{
    var matrix = matrix_identity_float4x4
    matrix[0,0] = scale.x
    matrix[1,1] = scale.y
    matrix[2,2] = scale.z
    return matrix
}
func create_translate_matrix(translate : simd_float3) -> simd_float4x4{
    var matrix = matrix_identity_float4x4
    matrix[3,0] = translate.x
    matrix[3,1] = translate.y
    matrix[3,2] = translate.z
    return matrix
}

func rot_y(angle : Float) -> simd_float4x4 {
    let theta = (angle/180)*3.14
    let result = simd_float4x4(simd_float4(cosf(theta),0,-sinf(theta),0), simd_float4(0,1,0,0), simd_float4(sinf(theta),0,cosf(theta),0), simd_float4(0,0,0,1))
    return result
}

func rot_x(angle : Float) -> simd_float4x4 {
    let theta = (angle/180)*3.14
    let result = simd_float4x4(simd_float4(1,0,0,0), simd_float4(0,cosf(theta),sinf(theta),0), simd_float4(0,-sinf(theta),cosf(theta),0),simd_float4(0,0,0,1))
    return result
}

func create_projection_matrix(fovRadians: Float,
     aspectRatio: Float,
     near: Float,
     far: Float) -> simd_float4x4
{
    let sy = 1 / tan(fovRadians * 0.5)
    let sx = sy / aspectRatio
    let zRange = far - near
    let sz = -(far + near) / zRange
    let tz = -2 * far * near / zRange
    let result = simd_float4x4(SIMD4<Float>(sx, 0,  0,  0),
              SIMD4<Float>(0, sy,  0,  0),
              SIMD4<Float>(0,  0, sz, -1),
              SIMD4<Float>(0,  0, tz,  0))
    return result
}






