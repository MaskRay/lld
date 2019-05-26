# REQUIRES: ppc
# RUN: llvm-mc -filetype=obj -triple=powerpc %s -o %t.o
# RUN: ld.lld %t.o -o %t
# RUN: llvm-objdump -d --no-show-raw-insn %t | FileCheck %s
# RUN: llvm-objdump -s --no-show-raw-insn %t | FileCheck --check-prefix=HEX %s

.section .R_PPC_ADDR16_HA,"ax",@progbits
1:
  lis 4, 1b@ha
# CHECK-LABEL: section .R_PPC_ADDR16_HA:
# CHECK: 10010000: lis 4, 4097

.section .R_PPC_ADDR16_HI,"ax",@progbits
1:
  lis 4,1b@h
# CHECK-LABEL: section .R_PPC_ADDR16_HI:
# CHECK: 10010004: lis 4, 4097

.section .R_PPC_ADDR16_LO,"ax",@progbits
1:
  addi 4, 4, 1b@l
# CHECK-LABEL: section .R_PPC_ADDR16_LO:
# CHECK: 10010008: addi 4, 4, 8

.section .R_PPC_ADDR32,"a",@progbits
.Lfoo:
  .long .Lfoo
# HEX-LABEL: section .R_PPC_ADDR32:
# HEX-NEXT: 1001000c 1001000c
