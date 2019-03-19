# REQUIRES: x86

# Test that we don't fail with foo being undefined.

# RUN: llvm-mc -filetype=obj -triple=x86_64-pc-linux %s -o %t.o
# RUN: ld.lld --export-dynamic %t.o -o %t
# RUN: llvm-readelf -r %t | FileCheck --check-prefix=NOREL %s
# RUN: llvm-readelf -x .text -x .data %t | FileCheck --check-prefix=HEX %s
# RUN: llvm-readobj --dyn-syms %t | FileCheck --implicit-check-not=foo /dev/null

# NOREL: no relocations

## gABI leaves the behavior of weak undefined references implementation defined.
## We choose to resolve them statically and not create a dynamic relocation for
## implementation simplicity. This also matches ld.bfd and gold.

# HEX: 0x{{[0-9a-f]+}} 00000000 00000000
# HEX: 0x{{[0-9a-f]+}} 00000000 00000000

        .text
        .weak foo
        .quad foo

        .data
        .weak foo
        .quad foo
