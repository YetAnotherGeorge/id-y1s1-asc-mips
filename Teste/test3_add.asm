.data
str1: .asciiz "Value is: " 

.text
.globl main
main: 
   li $t0, 1
   li $t1, 2
   add $t2, $t0, $t1

   li $v0, 4 # PRINT STRING call code
   la $a0, str1 
   syscall

   li $v0, 1 # PRINT INT call code
   move $a0, $t2
   syscall

   li $v0, 17 # exit2 call code
   li $a0, 0
   syscall