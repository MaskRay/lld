# REQUIRES: ppc
# RUN: llvm-mc -filetype=obj -triple=powerpc64le-unknown-linux %p/Inputs/ppc64-toc-relax-shared.s -o %t.o
# RUN: ld.lld -shared %t.o -o %t.so
# RUN: llvm-mc -filetype=obj -triple=powerpc64le-unknown-linux %s -o %t1.o
# RUN: llvm-mc -filetype=obj -triple=powerpc64le-unknown-linux %p/Inputs/ppc64-toc-relax.s -o %t2.o
# RUN: llvm-readobj -r %t1.o | FileCheck --check-prefixes=RELOCS-LE %s
# RUN: ld.lld %t1.o %t2.o %t.so -o %t
# RUN: llvm-objdump -d --no-show-raw-insn %t | FileCheck --check-prefixes=COMMON,EXE %s

# RUN: ld.lld -shared %t1.o %t2.o %t.so -o %t2.so
# RUN: llvm-objdump -d --no-show-raw-insn %t2.so | FileCheck --check-prefixes=COMMON,SHARED %s

# RUN: llvm-mc -filetype=obj -triple=powerpc64-unknown-linux %p/Inputs/ppc64-toc-relax-shared.s -o %t.o
# RUN: ld.lld -shared %t.o -o %t.so
# RUN: llvm-mc -filetype=obj -triple=powerpc64-unknown-linux %s -o %t1.o
# RUN: llvm-mc -filetype=obj -triple=powerpc64-unknown-linux %p/Inputs/ppc64-toc-relax.s -o %t2.o
# RUN: llvm-readobj -r %t1.o | FileCheck --check-prefixes=RELOCS-BE %s
# RUN: ld.lld %t1.o %t2.o %t.so -o %t
# RUN: llvm-objdump -d --no-show-raw-insn %t | FileCheck --check-prefixes=COMMON,EXE %s

# RUN: ld.lld -shared %t1.o %t2.o %t.so -o %t2.so
# RUN: llvm-objdump -d --no-show-raw-insn %t2.so | FileCheck --check-prefixes=COMMON,SHARED %s

# RELOCS-LE:      .rela.text {
# RELOCS-LE-NEXT:   0x0 R_PPC64_TOC16_HA .toc 0x0
# RELOCS-LE-NEXT:   0x4 R_PPC64_TOC16_LO_DS .toc 0x0
# RELOCS-LE:        0x18 R_PPC64_TOC16_HA .toc 0x10
# RELOCS-LE-NEXT:   0x1C R_PPC64_TOC16_LO_DS .toc 0x10
# RELOCS-LE-NEXT: }
# RELOCS-LE:      .rela.toc {
# RELOCS-LE-NEXT:   0x0 R_PPC64_ADDR64 hidden 0x0
# RELOCS-LE:        0x10 R_PPC64_ADDR64 default 0x0
# RELOCS-LE-NEXT: }

# RELOCS-BE:      .rela.text {
# RELOCS-BE-NEXT:   0x2 R_PPC64_TOC16_HA .toc 0x0
# RELOCS-BE-NEXT:   0x6 R_PPC64_TOC16_LO_DS .toc 0x0
# RELOCS-BE:        0x1A R_PPC64_TOC16_HA .toc 0x10
# RELOCS-BE-NEXT:   0x1E R_PPC64_TOC16_LO_DS .toc 0x10
# RELOCS-BE-NEXT: }
# RELOCS-BE:      .rela.toc {
# RELOCS-BE-NEXT:   0x0 R_PPC64_ADDR64 hidden 0x0
# RELOCS-BE:        0x10 R_PPC64_ADDR64 default 0x0
# RELOCS-BE-NEXT: }

# NM: 0000000010030000 D default
# NM: 0000000010030000 d hidden

# `hidden` is non-preemptable. It is relaxed.
# address(hidden) - (.got+0x8000) = 0x10030000 - (0x100200c0+0x8000) = 32576
# COMMON: nop
# COMMON: addi 3, 2, 32576
# COMMON: lwa 3, 0(3)
  addis 3, 2, .Lhidden@toc@ha
  ld    3, .Lhidden@toc@l(3)
  lwa   3, 0(3)

# `shared` is not defined in an object file. The ld instruction cannot be relaxed.
# The first addis can still be relaxed to nop, though.
# COMMON: nop
# COMMON: ld 4, -32760(2)
# COMMON: lwa 4, 0(4)
  addis 4, 2, .Lshared@toc@ha
  ld    4, .Lshared@toc@l(4)
  lwa   4, 0(4)

# `default` has default visibility. It is non-preemptable when producing an executable.
# address(default) - (.got+0x8000) = 0x10030000 - (0x100200c0+0x8000) = 32576
# EXE: nop
# EXE: addi 5, 2, 32576
# EXE: lwa 5, 0(5)

# SHARED: nop
# SHARED: ld 5, -32752(2)
# SHARED: lwa 5, 0(5)
  addis 5, 2, .Ldefault@toc@ha
  ld    5, .Ldefault@toc@l(5)
  lwa   5, 0(5)

.section .toc,"aw",@progbits
.Lhidden:
  .tc hidden[TC], hidden
.Lshared:
  .tc shared[TC], shared
.Ldefault:
  .tc default[TC], default
