# REQUIRES: ppc
# RUN: llvm-mc -filetype=obj -triple=powerpc %s -o %t.o
# RUN: echo '.globl f, g, h; f: g: h:' | llvm-mc -filetype=obj -triple=powerpc - -o %t1.o
# RUN: ld.lld -shared %t1.o -o %t1.so

# RUN: ld.lld -pie %t.o %t1.so -o %t
# RUN: llvm-readobj -r %t | FileCheck --check-prefix=RELOC %s
# RUN: llvm-objdump -d --no-show-raw-insn %t | FileCheck %s

# RUN: ld.lld -shared %t.o %t1.so -o %t
# RUN: llvm-readobj -r %t | FileCheck --check-prefix=RELOC %s
# RUN: llvm-objdump -d --no-show-raw-insn %t | FileCheck %s

# RELOC:      .rela.dyn {
# RELOC-NEXT:   R_PPC_ADDR32 f 0x0
# RELOC-NEXT:   R_PPC_ADDR32 g 0x0
# RELOC-NEXT:   R_PPC_ADDR32 h 0x0
# RELOC-NEXT: }
# RELOC-NEXT: .rela.plt {
# RELOC-NEXT:   R_PPC_JMP_SLOT f 0x0
# RELOC-NEXT:   R_PPC_JMP_SLOT g 0x0
# RELOC-NEXT:   R_PPC_JMP_SLOT h 0x0
# RELOC-NEXT: }

## .got2+0x8000-0x10004 = 0x30000+0x8000-0x10004 = 65536*2+32764
# CHECK-LABEL: _start:
# CHECK-NEXT:    bcl 20, 31, .+4
# CHECK-NEXT:  10004: mflr 30
# CHECK-NEXT:    addis 30, 30, 2
# CHECK-NEXT:    addi 30, 30, 32764

## Two bl __plt_f
# CHECK-NEXT:    bl .+24
# CHECK-NEXT:    bl .+20
## Two bl __plt_g
# CHECK-NEXT:    bl .+32
# CHECK-NEXT:    bl .+28
## Two bl __plt_h
# CHECK-NEXT:    bl .+40
# CHECK-NEXT:    bl .+36
# CHECK-EMPTY:

# CHECK-NEXT:  __plt_f:
# CHECK-NEXT:    lwz 11, 32760(30)
# CHECK-NEXT:    mtctr 11
# CHECK-NEXT:    bctr
# CHECK-NEXT:    nop
# CHECK-EMPTY:
# CHECK-NEXT:  __plt_g:
# CHECK-NEXT:    lwz 11, 32764(30)
# CHECK-NEXT:    mtctr 11
# CHECK-NEXT:    bctr
# CHECK-NEXT:    nop
# CHECK-EMPTY:

## __plt_h needs two instructions addis+lwz to represent the offset 65536*1-32768.
# CHECK-NEXT:  __plt_h:
# CHECK-NEXT:    addis 11, 30, 1
# CHECK-NEXT:    lwz 11, -32768(11)
# CHECK-NEXT:    mtctr 11
# CHECK-NEXT:    bctr

.section .got2,"aw"
.space 65516
.long f
.long g
.long h

.text
.globl _start
_start:
  bcl 20,31,.L
.L:
  mflr 30
  addis 30, 30, .got2+0x8000-.L@ha
  addi 30, 30, .got2+0x8000-.L@l
  bl f+32768@plt
  bl f+32768@plt
  bl g+32768@plt
  bl g+32768@plt
  bl h+32768@plt
  bl h+32768@plt
