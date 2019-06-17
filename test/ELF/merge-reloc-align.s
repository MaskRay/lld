# REQUIRES: x86
# RUN: llvm-mc -filetype=obj -triple=x86_64 %s -o %t.o
# RUN: ld.lld -r %t.o -o %t1.o
# RUN: llvm-readelf -S %t1.o | FileCheck --check-prefix=SEC %s
# RUN: llvm-readelf -x .cst8 %t1.o | FileCheck %s

## Check that if we have two SHF_MERGE sections with the same name, flags and
## entsize, but different alignments, we concatenate them with the larger
## input alignment as the output alignment.

# SEC: Name  Type     {{.*}} Size   ES Flg Lk Inf Al
# SEC: .cst8 PROGBITS {{.*}} 000020 08  AM  0   0  8

# CHECK:      0x00000000 01000000 00000000 01000000 00000000
# CHECK-NEXT: 0x00000010 01000000 00000000 02000000 00000000

.section .cst8,"aM",@progbits,8,unique,0
.align 4
.quad 1
.quad 1

.section .cst8,"aM",@progbits,8,unique,1
.align 8
.quad 1
.quad 2
