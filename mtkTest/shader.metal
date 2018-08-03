//
//  shader.metal
//  mtkTest
//
//  Created by Adam Ferriss on 8/1/18.
//  Copyright © 2018 Adam Ferriss. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

//struct Constants {
//    float time;
//};

struct ModelConstants {
    float4x4 modelViewMatrix;
};

struct FragUniforms {
    float time;
};

struct VertexIn {
    float4 position [[ attribute(0 )]];
    float4 color [[ attribute(1) ]];
    float2 textureCoordinates [[ attribute(2 )]];
};

struct VertexOut {
    float4 position [[ position ]];
    float4 color;
    float2 textureCoordinates;
    float time;
};


struct FragmentOut {
    float4 color0 [[ color(0) ]];
    float4 color1 [[ color(1) ]];
};

vertex VertexOut fullScreen(const VertexIn vertexIn [[ stage_in ]] ){
    VertexOut v;
    v.position = vertexIn.position;
    v.color = vertexIn.color;
    v.textureCoordinates = vertexIn.textureCoordinates;
    
    return v;
}

vertex VertexOut vertex_shader(const VertexIn vertexIn [[ stage_in ]], constant ModelConstants &modelConstants [[ buffer(1) ]] ){
    
    VertexOut vertexOut;
    vertexOut.position = modelConstants.modelViewMatrix * vertexIn.position;
//    vertexOut.position = vertexIn.position;
    vertexOut.color = vertexIn.color;
    vertexOut.textureCoordinates = vertexIn.textureCoordinates;
//    vertexOut.time = constants.time;
    
    return vertexOut;
}

fragment half4 fragment_shader(VertexOut vertexIn [[ stage_in ]]){
    return half4(vertexIn.color);
}

//fragment half4 fragment_shader( VertexOut vertexIn [[ stage_in ]],
//                               texture2d<float> texture [[texture(0) ]]
//                               ){
//    constexpr sampler defaultSampler;
//
//
//    float2 tc = vertexIn.textureCoordinates;
//
//    tc.x = tc.x + sin(tc.y*10.0 + vertexIn.time) * 0.1;
//    float4 color = texture.sample(defaultSampler, tc);
//    return half4(color);
//}
float3 hsb2rgb(float3 c) {
    float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    float3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float3 rgb2hsb( float3 c ){
    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    float4 p = mix(float4(c.bg, K.wz),
                 float4(c.gb, K.xy),
                 step(c.b, c.g));
    float4 q = mix(float4(p.xyw, c.r),
                 float4(c.r, p.yzx),
                 step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)),
                d / (q.x + e),
                q.x);
}

fragment FragmentOut textured_fragment( VertexOut vertexIn [[ stage_in ]],
                                       sampler sampler2d [[ sampler(0) ]],
                                       texture2d<float> texture [[texture(0) ]],
                                       constant FragUniforms &fragUniforms [[ buffer(2) ]]
                                       ){

    FragmentOut out;
    
    float2 tc = vertexIn.textureCoordinates;
    
    if(fragUniforms.time > 60 ){
        tc.y = 1.0 - tc.y;
    }
    

    tc = 2.0 * tc - 1.0;
    tc *= 0.995;
    tc = tc * 0.5 + 0.5;
    
    float4 color = texture.sample(sampler2d, tc);
    
//    color.rgb += 0.01;// fragUniforms.time*0.01;
    
//    float3 hsv = rgb2hsb(color.rgb);
//    hsv.r += 0.01;
//    hsv.r = fract(hsv.r);
    
//    color.rgb = hsb2rgb(hsv);
    

    
//    float4 color2 = texture.sample(sampler2d, tc + sin(hsv.r*6.2831)*0.001 );
    
//    color2.rgb = rgb2hsb(color2.rgb);
//    color2.r += 0.01;
//    color2.r = fract(color2.r);
    
//    color2.rgb = hsb2rgb(color2.rgb);
//    color.rgb = fract(color.rgb);
    
    color.rgb -= 0.005;
    color.rgb = fract(color.rgb);
    
//    if( color.a == 0.0){
//        discard_fragment();
//    }
    
    out.color0 = color;
//    out.color1 = color+0.5;
    
    return out;
//    return half4(color);

}

/*
fragment half4 textured_fragment( VertexOut vertexIn [[ stage_in ]],
                               sampler sampler2d [[ sampler(0) ]],
                               texture2d<float> texture [[texture(0) ]],
                               constant FragUniforms &fragUniforms [[ buffer(2) ]]
                               ){
//    constexpr sampler defaultSampler;
    
    float2 tc = vertexIn.textureCoordinates;
    
    
    
//    tc.x = tc.x + sin(tc.y*10.0 + vertexIn.time) * 0.1;
    float4 color = texture.sample(sampler2d, tc);
    
    color.rgb += fragUniforms.time*0.01;
    
    color.rgb = fract(color.rgb);
    
    if( color.a == 0.0){
        discard_fragment(); 
    }
    
    
    return half4(color);
}
*/

fragment half4 textured_mask_fragment(VertexOut vertexIn [[ stage_in ]],
                                      sampler sampler2d [[ sampler(0) ]],
                                      texture2d<float> texture [[ texture(0) ]],
                                      texture2d<float> maskTexture [[texture(1)]]){
    
    float4 color = texture.sample(sampler2d, vertexIn.textureCoordinates);
    float4 mask = maskTexture.sample(sampler2d, vertexIn.textureCoordinates);
    
    if( mask.a < 0.5 ){
        discard_fragment();
    }
    
    return half4(color);
}
