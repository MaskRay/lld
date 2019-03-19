// REQUIRES: x86
// RUN: llvm-mc -filetype=obj -triple=x86_64-unknown-linux %s -o %t.o
// RUN: ld.lld %t.o -o %t
// RUN: llvm-readobj -dyn-symbols %t | FileCheck %s
// RUN: ld.lld -pie %t.o -o %t
// RUN: llvm-readobj -V --dyn-syms %t | FileCheck %s

        .globl _start
_start:
        .type foo,@function
        .weak foo
        .long foo@gotpcrel

// Test that an entry for weak undefined symbols is NOT emitted in .dynsym as
// the executable was not linked with any shared libraries. There are other
// tests which ensure that the weak undefined symbols do get emitted in .dynsym
// for executables linked against dynamic libraries.

// CHECK-NOT: foo
