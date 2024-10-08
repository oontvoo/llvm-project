//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
// UNSUPPORTED: c++03, c++11, c++14, c++17

// <chrono>
// class weekday;

//  constexpr unsigned iso_encoding() const noexcept;
//  Returns the underlying weekday, _except_ that returns '7' for Sunday (zero)
//    See [time.cal.wd.members]

#include <chrono>
#include <cassert>
#include <type_traits>
#include <utility>

#include "test_macros.h"

using weekday = std::chrono::weekday;

constexpr bool test() {
  //  This is different than all the other tests, because the '7' gets converted to
  //  a zero in the constructor, but then back to '7' by iso_encoding().
  for (unsigned i = 0; i <= 10; ++i) {
    weekday wd(i);
    assert(wd.iso_encoding() == (i == 0 ? 7 : i));
  }

  return true;
}

int main(int, char**) {
  ASSERT_NOEXCEPT(std::declval<weekday&>().iso_encoding());
  ASSERT_SAME_TYPE(unsigned, decltype(std::declval<weekday&>().iso_encoding()));

  test();
  static_assert(test());

  return 0;
}
