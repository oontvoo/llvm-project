// RUN: %clang_cc1 -triple aarch64-none-linux-gnu -target-feature +sve -O2 -S \
// RUN:   -mllvm -prefer-predicate-over-epilogue=scalar-epilogue -o - %s -mvscale-min=2 -mvscale-max=2  | FileCheck %s --check-prefixes=CHECK,CHECK256
// RUN: %clang_cc1 -triple aarch64-none-linux-gnu -target-feature +sve -O2 -S \
// RUN:   -mllvm -prefer-predicate-over-epilogue=scalar-epilogue -o - %s -mvscale-min=4 -mvscale-max=4  | FileCheck %s --check-prefixes=CHECK,CHECK512
// RUN: %clang_cc1 -triple aarch64-none-linux-gnu -target-feature +sve -O2 -S \
// RUN:   -mllvm -prefer-predicate-over-epilogue=scalar-epilogue -o - %s -mvscale-min=8 -mvscale-max=8 | FileCheck %s --check-prefixes=CHECK,CHECK1024
// RUN: %clang_cc1 -triple aarch64-none-linux-gnu -target-feature +sve -O2 -S \
// RUN:   -mllvm -prefer-predicate-over-epilogue=scalar-epilogue -o - %s -mvscale-min=16 -mvscale-max=16 | FileCheck %s --check-prefixes=CHECK,CHECK2048

// REQUIRES: aarch64-registered-target

#include <arm_sve.h>

void func(int *restrict a, int *restrict b) {
// CHECK-LABEL: func
// CHECK256-COUNT-8: str
// CHECK512-COUNT-4: str
// CHECK1024-COUNT-2: str
// CHECK2048-COUNT-1: str
#pragma clang loop vectorize(enable)
  for (int i = 0; i < 64; ++i)
    a[i] += b[i];
}
