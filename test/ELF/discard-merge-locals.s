# REQUIRES: x86

## Test that local symbols in a SHF_MERGE section are omitted.

# RUN: llvm-mc -filetype=obj -triple=x86_64 %s -o %t.o
# RUN: ld.lld %t.o -o %t
# RUN: llvm-nm %t | count 0

# RUN: ld.lld --discard-locals %t.o -o %t2
# RUN: llvm-nm %t2 | count 0

lea .L.str(%rip), %rdi
lea local(%rip), %rdi

.section .rodata.str1.1,"aMS",@progbits,1
.L.str:
local:
