# REQUIRES: x86
# RUN: echo 'SECTIONS { \
# RUN:   .text.foo : { *(.text.foo) } .text.bar : { *(.text.bar) } \
# RUN:   .rodata.foo : { *(.rodata.foo) } .rodata.bar : { *(.rodata.bar) } }' > %t.script
# RUN: llvm-mc -filetype=obj -triple=x86_64-pc-linux %s -o %t.o
# RUN: ld.lld %t.o --script %t.script --icf=all --print-icf-sections | count 0

.section .text.foo,"ax"
ret

.section .text.bar,"ax"
ret

.section .rodata.foo,"a"
.byte 42

.section .rodata.bar,"a"
.byte 42
