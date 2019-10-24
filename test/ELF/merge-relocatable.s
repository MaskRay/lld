# REQUIRES: x86

## Test we keep a SHT_REL[A] section that relocates a SHF_MERGE section in -r mode.
## The relocated SHF_MERGE section is not merged.

# RUN: llvm-mc -filetype=obj -triple=x86_64-pc-linux %s -o %t.o
# RUN: ld.lld -r %t.o -o %t
# RUN: llvm-readobj -S %t | FileCheck %s

# CHECK:     Name: .rodata.cst8
# CHECK-NOT: }
# CHECK:     Size: 16
# CHECK:     Name: .rela.rodata.cst8
# CHECK-NOT: }
# CHECK:     Size: 48

foo:

.section .rodata.cst8,"aM",@progbits,8,unique,0
bar:
.quad foo

.section .rodata.cst8,"aM",@progbits,8,unique,1
baz:
.quad foo
