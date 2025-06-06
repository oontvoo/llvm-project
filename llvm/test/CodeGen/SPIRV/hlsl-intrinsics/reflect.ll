; RUN: llc -O0 -mtriple=spirv-unknown-vulkan %s -o - | FileCheck %s
; RUN: %if spirv-tools %{ llc -O0 -mtriple=spirv-unknown-vulkan %s -o - -filetype=obj | spirv-val %}

; Make sure SPIRV operation function calls for reflect are lowered correctly.

; CHECK-DAG: %[[#op_ext_glsl:]] = OpExtInstImport "GLSL.std.450"
; CHECK-DAG: %[[#float_16:]] = OpTypeFloat 16
; CHECK-DAG: %[[#vec4_float_16:]] = OpTypeVector %[[#float_16]] 4
; CHECK-DAG: %[[#float_32:]] = OpTypeFloat 32
; CHECK-DAG: %[[#vec4_float_32:]] = OpTypeVector %[[#float_32]] 4

define noundef <4 x half> @reflect_half4(<4 x half> noundef %a, <4 x half> noundef %b) {
entry:
  ; CHECK: %[[#]] = OpFunction %[[#vec4_float_16]] None %[[#]]
  ; CHECK: %[[#arg0:]] = OpFunctionParameter %[[#vec4_float_16]]
  ; CHECK: %[[#arg1:]] = OpFunctionParameter %[[#vec4_float_16]]
  ; CHECK: %[[#]] = OpExtInst %[[#vec4_float_16]] %[[#op_ext_glsl]] Reflect %[[#arg0]] %[[#arg1]]
  %spv.reflect = call <4 x half> @llvm.spv.reflect.f16(<4 x half> %a, <4 x half> %b)
  ret <4 x half> %spv.reflect
}

define noundef <4 x float> @reflect_float4(<4 x float> noundef %a, <4 x float> noundef %b) {
entry:
  ; CHECK: %[[#]] = OpFunction %[[#vec4_float_32]] None %[[#]]
  ; CHECK: %[[#arg0:]] = OpFunctionParameter %[[#vec4_float_32]]
  ; CHECK: %[[#arg1:]] = OpFunctionParameter %[[#vec4_float_32]]
  ; CHECK: %[[#]] = OpExtInst %[[#vec4_float_32]] %[[#op_ext_glsl]] Reflect %[[#arg0]] %[[#arg1]]
  %spv.reflect = call <4 x float> @llvm.spv.reflect.f32(<4 x float> %a, <4 x float> %b)
  ret <4 x float> %spv.reflect
}

declare <4 x half> @llvm.spv.reflect.f16(<4 x half>, <4 x half>)
declare <4 x float> @llvm.spv.reflect.f32(<4 x float>, <4 x float>)
