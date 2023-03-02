//
//  Shaders.metal
//  MetalProject
//
//  Created by Sina Dashtebozorgy on 23/12/2022.
//

#include <metal_stdlib>
using namespace metal;
#include <simd/simd.h>

constant int tesselationMode [[function_constant(0)]];
constant int controlPointCounts [[function_constant(1)]];


struct VertexOut{
    float4 pos [[position]];
    float4 colour;
    float4 normal;
    float2 tex;
    float3 tex_3;
    float pointSize [[point_size]];
    
};





vertex VertexOut pointVertexShader(const device float4 *vertices [[buffer(0)]], uint index [[vertex_id]], constant float & pSize [[buffer(4)]]){
    
    float3 pos = vertices[index].xyz;
    VertexOut out;
    out.pos = float4(pos,1);
    out.pointSize = pSize;
    return out;
}

fragment float4 pointFragmentShader(VertexOut interpolated [[stage_in]], constant simd_float4 &colour [[buffer(3)]]){
    return colour;
    
}



template <typename T>
    T bilerp(T c00, T c01, T c10, T c11, float2 uv){
        T c0 = mix(c00, c01, T(uv[0]));
        T c1 = mix(c10, c11, T(uv[0]));
        return mix(c0, c1, T(uv[1]));
    }


template <typename T>
    T secondDegreeLerp(T c00, T c01, T c11, float2 uv){
        float t = float(uv[0]);
        
        return (1.0 - t)*(1.0 - t)*c00 + 2.0*(1.0 - t)*t*c01 + t*t*c11;
       
    }

template <typename T>
    T thirdDegreeLerp(T c00, T c01, T c10, T c11, float2 uv){
        float t = float(uv[0]);
        return pow((1.0 - t),3.0)*c00 + 3.0*pow((1.0 - t),2.0)*t*c01 + 3.0*(1.0 - t)*pow(t,2.0)*c10 + pow(t,3.0)*c11;
       
    }
    





kernel void tesselate(const device float4 *input [[buffer(0)]], device float4 *output [[buffer(1)]], uint2 index [[thread_position_in_grid]], constant float2 &tessFactor [[buffer(2)]], uint2 size [[threads_per_grid]]){
    
    if(tesselationMode == 2){
        if(controlPointCounts == 2){
            float xoffset = 1.0 / tessFactor[0];
            xoffset *= float(index.x);
            float4 final = mix(input[0],input[1],xoffset);
            output[index.x] = final;
            
        }
        else if(controlPointCounts == 3){
            float xoffset = 1.0/tessFactor[0];
            float yoffset = 1.0/tessFactor[1];
            
            xoffset *= float(index.x);
            yoffset *= float(index.y);
            float4 bottom = mix(input[0],input[1],xoffset);
            float4 final = mix(bottom,input[2],yoffset);
            output[size.x * index.y + index.x] = final;
        }
        
        
        else {
            float xoffset = 1.0/tessFactor[0];
            float yoffset = 1.0/tessFactor[1];
            
            xoffset *= float(index.x);
            yoffset *= float(index.y);
            
            float4 final = bilerp(input[0], input[1], input[2], input[3], float2(xoffset,yoffset));
            
            output[size.x * index.y + index.x] = final;
        }
    }
    
    else if(tesselationMode == 3){
        if(controlPointCounts == 3){
            float xoffset = 1.0 / tessFactor[0];
            xoffset *= float(index.x);
            float3 final = secondDegreeLerp(input[0].xyz, input[1].xyz, input[2].xyz, float2(xoffset,0));
            output[index.x] = float4(final,1);
        }
        else if(controlPointCounts == 4){
            float xoffset = 1.0 / tessFactor[0];
            float yoffset = 1.0 / tessFactor[1];
            xoffset *= float(index.x);
            yoffset *= float(index.y);
            float3 final = secondDegreeLerp(input[0].xyz, input[1].xyz, input[2].xyz, float2(xoffset,0));
            final = mix(final, input[3].xyz, yoffset);
            output[size.x * index.y + index.x] = float4(final,1);
        }
        else{
            float xoffset = 1.0 / tessFactor[0];
            float yoffset = 1.0 / tessFactor[1];
            xoffset *= float(index.x);
            yoffset *= float(index.y);
            float3 final = secondDegreeLerp(input[0].xyz, input[1].xyz, input[2].xyz, float2(xoffset,0));
            float3 top = mix(input[3].xyz,input[4].xyz,xoffset);
            final = mix(final, top, yoffset);
            output[size.x * index.y + index.x] = float4(final,1);
        }
    
    }
    else{
        if(controlPointCounts == 4){
            float xoffset = 1.0 / tessFactor[0];
            xoffset *= float(index.x);
            float3 final = thirdDegreeLerp(input[0].xyz, input[1].xyz, input[2].xyz, input[3].xyz, float2(xoffset,0));
            output[index.x] = float4(final,1);
        }
        else if(controlPointCounts == 5){
            float xoffset = 1.0 / tessFactor[0];
            float yoffset = 1.0 / tessFactor[1];
            xoffset *= float(index.x);
            yoffset *= float(index.y);
            float3 bottom = thirdDegreeLerp(input[0].xyz, input[1].xyz, input[2].xyz, input[3].xyz, float2(xoffset,0));
            float3 final = mix(bottom, input[4].xyz, yoffset);
            output[size.x * index.y + index.x] = float4(final,1);
            
        }
        else{
            float xoffset = 1.0 / tessFactor[0];
            float yoffset = 1.0 / tessFactor[1];
            xoffset *= float(index.x);
            yoffset *= float(index.y);
            float3 bottom = thirdDegreeLerp(input[0].xyz, input[1].xyz, input[2].xyz, input[3].xyz, float2(xoffset,0));
            float3 top = mix(input[4].xyz,input[5].xyz,xoffset);
            float3 final = mix(bottom,top, yoffset);
            output[size.x * index.y + index.x] = float4(final,1);
        }
    }
    
    
    
   
    
}

    

