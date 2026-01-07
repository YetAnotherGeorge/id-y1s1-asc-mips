.data
str_quot: .asciiz "Quotient is: " 
str_rem: .asciiz "\nRemainder is: " 

.text
.globl main
main: 
    # Divide t0 / t1 -> t2 = quot, t2 = rem
    li $t0, 10
    li $t1, 3
    div $t0, $t1
    mflo $t2
    mfhi $t3

    li $v0, 4 # PRINT STRING call code
    la $a0, str_quot
    syscall
    li $v0, 1 # PRINT INT call code
    move $a0, $t2
    syscall

    li $v0, 4 # PRINT STRING call code
    la $a0, str_rem
    syscall
    li $v0, 1 # PRINT INT call code
    move $a0, $t3
    syscall

    li $v0, 17 # exit2 call code
    li $a0, 0
    syscall