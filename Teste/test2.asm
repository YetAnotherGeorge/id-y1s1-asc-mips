.data
str: .asciiz "the answer = "

.text
.globl main
main: 
    # Print str
    li $v0, 4 
    la $a0, str 
    syscall

    # Print 5
    li $v0, 1
    li $a0, 5
    syscall

    # exit
    li $v0, 17
    li $a0, 1
    syscall