.data
str_quot: .asciiz "Quotient is: " 
str_rem: .asciiz "\nRemainder is: " 

.text
.globl main
main: 
    li $t0, 0x101
    li $t1, 0x010
    xor $t2, $t0, $t1
    andi $t2, $t2, 0x111

    li $v0, 1 # PRINT INT call code
    move $a0, $t2
    syscall

    li $v0, 17 # exit2 call code
    li $a0, 0
    syscall