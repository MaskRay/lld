# REQUIRES: arm
# RUN: llvm-mc -filetype=obj -triple=armv7a-none-linux-android %s -o %t.o
# RUN: ld.lld %t.o -o %t
# RUN: llvm-readelf -l %t | FileCheck %s
# RUN: ld.lld %t.o --android-tls -o %t
# RUN: llvm-readelf -l %t | FileCheck --check-prefix=A32 %s

# RUN: llvm-mc -filetype=obj -triple=aarch64-none-linux-android %s -o %t.o
# RUN: ld.lld %t.o -o %t
# RUN: llvm-readelf -l %t | FileCheck %s
# RUN: ld.lld %t.o --android-tls -o %t
# RUN: llvm-readelf -l %t | FileCheck --check-prefix=A64 %s

# CHECK: TLS {{.*}} 0x1

## Android Bionic reserves several slots after the thread pointer. Check we
## overalign the PT_TLS segment to adapt to its TLS layout.

# A32: TLS {{.*}} 0x20
# A64: TLS {{.*}} 0x40

.section .tbss,"awT",%nobits
.byte 0
