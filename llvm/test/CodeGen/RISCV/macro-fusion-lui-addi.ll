; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
;RUN: llc < %s -mtriple=riscv64 -mattr=+f -mcpu=sifive-u74 -target-abi=lp64f \
;RUN:   | FileCheck %s --check-prefix=NOFUSION
;RUN: llc < %s -mtriple=riscv64 -mattr=+f,+lui-addi-fusion -mcpu=sifive-u74 \
;RUN:   -target-abi=lp64f | FileCheck %s --check-prefix=FUSION
;RUN: llc < %s -mtriple=riscv64 -mattr=+f,+lui-addi-fusion,+use-postra-scheduler -mcpu=sifive-u74 \
;RUN:   -misched-postra-direction=topdown -target-abi=lp64f \
;RUN:   | FileCheck %s --check-prefixes=FUSION-POSTRA,FUSION-POSTRA-TOPDOWN
;RUN: llc < %s -mtriple=riscv64 -mattr=+f,+lui-addi-fusion,+use-postra-scheduler -mcpu=sifive-u74 \
;RUN:   -misched-postra-direction=bottomup -target-abi=lp64f \
;RUN:   | FileCheck %s --check-prefixes=FUSION-POSTRA,FUSION-POSTRA-BOTTOMUP
;RUN: llc < %s -mtriple=riscv64 -mattr=+f,+lui-addi-fusion,+use-postra-scheduler -mcpu=sifive-u74 \
;RUN:   -misched-postra-direction=bidirectional -target-abi=lp64f \
;RUN:   | FileCheck %s --check-prefixes=FUSION-POSTRA,FUSION-POSTRA-BIDIRECTIONAL
;RUN: llc < %s -mtriple=riscv64 -mattr=+f,+lui-addi-fusion -target-abi=lp64f \
;RUN:   | FileCheck %s --check-prefix=FUSION-GENERIC

@.str = private constant [4 x i8] c"%f\0A\00", align 1

define void @foo(i32 signext %0, i32 signext %1) {
; NOFUSION-LABEL: foo:
; NOFUSION:       # %bb.0:
; NOFUSION-NEXT:    lui a0, %hi(.L.str)
; NOFUSION-NEXT:    fcvt.s.w fa0, a1
; NOFUSION-NEXT:    addi a0, a0, %lo(.L.str)
; NOFUSION-NEXT:    tail bar
;
; FUSION-LABEL: foo:
; FUSION:       # %bb.0:
; FUSION-NEXT:    lui a0, %hi(.L.str)
; FUSION-NEXT:    addi a0, a0, %lo(.L.str)
; FUSION-NEXT:    fcvt.s.w fa0, a1
; FUSION-NEXT:    tail bar
;
; FUSION-POSTRA-TOPDOWN-LABEL: foo:
; FUSION-POSTRA-TOPDOWN:       # %bb.0:
; FUSION-POSTRA-TOPDOWN-NEXT:    lui a0, %hi(.L.str)
; FUSION-POSTRA-TOPDOWN-NEXT:    addi a0, a0, %lo(.L.str)
; FUSION-POSTRA-TOPDOWN-NEXT:    fcvt.s.w fa0, a1
; FUSION-POSTRA-TOPDOWN-NEXT:    tail bar
;
; FUSION-POSTRA-BOTTOMUP-LABEL: foo:
; FUSION-POSTRA-BOTTOMUP:       # %bb.0:
; FUSION-POSTRA-BOTTOMUP-NEXT:    fcvt.s.w fa0, a1
; FUSION-POSTRA-BOTTOMUP-NEXT:    lui a0, %hi(.L.str)
; FUSION-POSTRA-BOTTOMUP-NEXT:    addi a0, a0, %lo(.L.str)
; FUSION-POSTRA-BOTTOMUP-NEXT:    tail bar
;
; FUSION-POSTRA-BIDIRECTIONAL-LABEL: foo:
; FUSION-POSTRA-BIDIRECTIONAL:       # %bb.0:
; FUSION-POSTRA-BIDIRECTIONAL-NEXT:    lui a0, %hi(.L.str)
; FUSION-POSTRA-BIDIRECTIONAL-NEXT:    addi a0, a0, %lo(.L.str)
; FUSION-POSTRA-BIDIRECTIONAL-NEXT:    fcvt.s.w fa0, a1
; FUSION-POSTRA-BIDIRECTIONAL-NEXT:    tail bar
;
; FUSION-GENERIC-LABEL: foo:
; FUSION-GENERIC:       # %bb.0:
; FUSION-GENERIC-NEXT:    fcvt.s.w fa0, a1
; FUSION-GENERIC-NEXT:    lui a0, %hi(.L.str)
; FUSION-GENERIC-NEXT:    addi a0, a0, %lo(.L.str)
; FUSION-GENERIC-NEXT:    tail bar
  %3 = sitofp i32 %1 to float
  tail call void @bar(ptr @.str, float %3)
  ret void
}

declare void @bar(ptr, float)

; Test that we prefer lui+addiw over li+slli.
define i32 @test_matint() {
; NOFUSION-LABEL: test_matint:
; NOFUSION:       # %bb.0:
; NOFUSION-NEXT:    li a0, 1
; NOFUSION-NEXT:    slli a0, a0, 11
; NOFUSION-NEXT:    ret
;
; FUSION-LABEL: test_matint:
; FUSION:       # %bb.0:
; FUSION-NEXT:    lui a0, 1
; FUSION-NEXT:    addi a0, a0, -2048
; FUSION-NEXT:    ret
;
; FUSION-POSTRA-LABEL: test_matint:
; FUSION-POSTRA:       # %bb.0:
; FUSION-POSTRA-NEXT:    lui a0, 1
; FUSION-POSTRA-NEXT:    addi a0, a0, -2048
; FUSION-POSTRA-NEXT:    ret
;
; FUSION-GENERIC-LABEL: test_matint:
; FUSION-GENERIC:       # %bb.0:
; FUSION-GENERIC-NEXT:    lui a0, 1
; FUSION-GENERIC-NEXT:    addi a0, a0, -2048
; FUSION-GENERIC-NEXT:    ret
  ret i32 2048
}

define void @test_regalloc_hint(i32 noundef signext %0, i32 noundef signext %1) {
; NOFUSION-LABEL: test_regalloc_hint:
; NOFUSION:       # %bb.0:
; NOFUSION-NEXT:    mv a0, a1
; NOFUSION-NEXT:    lui a1, 3014
; NOFUSION-NEXT:    addi a1, a1, 334
; NOFUSION-NEXT:    tail bar
;
; FUSION-LABEL: test_regalloc_hint:
; FUSION:       # %bb.0:
; FUSION-NEXT:    mv a0, a1
; FUSION-NEXT:    lui a1, 3014
; FUSION-NEXT:    addi a1, a1, 334
; FUSION-NEXT:    tail bar
;
; FUSION-POSTRA-LABEL: test_regalloc_hint:
; FUSION-POSTRA:       # %bb.0:
; FUSION-POSTRA-NEXT:    mv a0, a1
; FUSION-POSTRA-NEXT:    lui a1, 3014
; FUSION-POSTRA-NEXT:    addi a1, a1, 334
; FUSION-POSTRA-NEXT:    tail bar
;
; FUSION-GENERIC-LABEL: test_regalloc_hint:
; FUSION-GENERIC:       # %bb.0:
; FUSION-GENERIC-NEXT:    lui a2, 3014
; FUSION-GENERIC-NEXT:    addi a2, a2, 334
; FUSION-GENERIC-NEXT:    mv a0, a1
; FUSION-GENERIC-NEXT:    mv a1, a2
; FUSION-GENERIC-NEXT:    tail bar
  tail call void @bar(i32 noundef signext %1, i32 noundef signext 12345678)
  ret void
}
