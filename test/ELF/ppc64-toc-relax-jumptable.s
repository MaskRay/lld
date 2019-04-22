# REQUIRES: ppc
# RUN: llvm-mc -filetype=obj -triple=powerpc64le-unknown-linux %s -o %t.o
# RUN: ld.lld %t.o -o %t
# RUN: llvm-objdump -D %t | FileCheck --check-prefixes=CHECK,LE %s

# RUN: llvm-mc -filetype=obj -triple=powerpc64-unknown-linux %s -o %t.o
# RUN: ld.lld %t.o -o %t
# RUN: llvm-objdump -D %t | FileCheck --check-prefixes=CHECK,BE %s


# Verify that the load from the .toc section was relaxed to an
# add of an offset to the TOC base-pointer (calculating the address
# of the jump table rather then loading the address from the .toc).

# CHECK: Disassembly of section .rodata:
# CHECK-NEXT: .rodata:
# CHECK-NEXT: 100001c8

# CHECK-LABEL: _start
# CHECK:       clrldi  3, 3, 62
# CHECK-NEXT:  addis 4, 2, -2
# CHECK-NEXT:  addi  4, 4, -32312
# CHECK-NEXT:  sldi  3, 3, 2

# LE: Disassembly of section .toc:
# LE-NEXT: .toc:
# LE-NEXT: 10020008:       c8 01 00 10
# LE-NEXT: 1002000c:       00 00 00 00

# BE: Disassembly of section .toc:
# BE-NEXT: .toc:
# BE-NEXT: 10020008:       00 00 00 00
# BE-NEXT: 1002000c:       10 00 01 c8

    .text
    .global _start
    .type _start, @function
_start:
.Lstart_gep:
    addis 2, 12, .TOC.-.Lstart_gep@ha
    addi  2,  2, .TOC.-.Lstart_gep@l
.Lstart_lep:
    .localentry _start, .Lstart_lep-.Lstart_gep
    rldicl 3, 3, 0, 62
    addis 4, 2, .LJTI_TE@toc@ha
    ld    4, .LJTI_TE@toc@l(4)
    sldi  3, 3, 2
    lwax  3, 3, 4
    add   3, 3, 4
    mtctr 3
    bctr

.LBB1:
    li 3, 0
    blr
.LBB2:
    li 3, 10
    blr
.LBB3:
    li 3, 55
    blr
.LBB4:
    li 3, 255
    blr

    .section        .rodata,"a",@progbits
    .p2align        2
.LJT:
    .long   .LBB1-.LJT
    .long   .LBB2-.LJT
    .long   .LBB3-.LJT
    .long   .LBB4-.LJT

.section        .toc,"aw",@progbits
# TOC entry for the jumptable address.
.LJTI_TE:
    .tc .LJT[TC],.LJT
