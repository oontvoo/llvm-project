//===-- X86Counter.h --------------------------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_TOOLS_LLVM_EXEGESIS_X86COUNTER_H
#define LLVM_TOOLS_LLVM_EXEGESIS_X86COUNTER_H

#include "../PerfHelper.h"
#include "llvm/Support/Error.h"

// FIXME: Use appropriate wrappers for poll.h and mman.h
// to support Windows and remove this linux-only guard.
#if defined(__linux__) && defined(HAVE_LIBPFM)

namespace llvm {
namespace exegesis {

class X86LbrPerfEvent : public pfm::PerfEvent {
public:
  X86LbrPerfEvent(unsigned SamplingPeriod);
};

class X86LbrCounter : public pfm::Counter {
public:
  explicit X86LbrCounter(pfm::PerfEvent &&Event);

  virtual ~X86LbrCounter();

  void start() override;
  llvm::Expected<int64_t> readOrError() const override;

private:
  void *MMappedBuffer = nullptr;
};

} // namespace exegesis
} // namespace llvm

#endif // defined(__linux__) && defined(HAVE_LIBPFM)

#endif // LLVM_TOOLS_LLVM_EXEGESIS_X86COUNTER_H
