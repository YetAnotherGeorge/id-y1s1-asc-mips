
# II.4) (3 puncte)
# Program care verifica daca un numar natural este prim. Numarul este dat intr-o variabila n de 
# tip word declarata cu initializare in program; raspunsul va fi stocat intr-o variabila x de 
# tip byte sub forma 
# 0=neprim,
# 1=prim.


.data
# DEFINE-URI SYSCALLS
.eqv PRINT_INT    1   
.eqv PRINT_FLOAT  2 
.eqv PRINT_DOUBLE 3
.eqv PRINT_STR    4

.eqv READ_INT    5
.eqv READ_FLOAT  6
.eqv READ_DOUBLE 7
.eqv READ_STRING 8

.eqv PRINT_CHAR 11
.eqv READ_CHAR  12

.eqv FILE_OPEN 13
.eqv FILE_READ 14
.eqv FILE_WRITE 15
.eqv FILE_CLOSE 16

.eqv SBRK 9
.eqv EXIT 10
.eqv EXIT_WCODE 17

# STRING-URI
main_str_enter_num: .asciiz "Introduceti un numar pentru a verifica daca este prim \n" 
main_str_entered: .asciiz "Numarul introdus este: "

.text
.globl main
main: 
    # li $v0, PRINT_STR
    # la $a0, main_str_enter_num
    # syscall

    # li $v0, READ_INT # Read int into $v0
    # syscall
    # move $t0, $v0 # Save int to t0 register

    li $t0, 12 # INPUT

    # Afiseaza numar citit
    li $v0, PRINT_STR
    la $a0, main_str_entered
    syscall
    li $v0, PRINT_INT
    move $a0, $t0 
    syscall

    # Save $t0 to stack
    addi $sp, $sp, -4
    sw $t0, 0($sp)

    # check_is_prime(number)
    move $a0, $t0
    jal check_is_prime
    move $t1, $v0 # Salveaza rezultat in t1 (bool)
    
    sw $t0, 0($sp) # Restaureaza $t0
    addi $sp, $sp, 4

    # t0: numar introdus, t1: rezultat
    li $v0, PRINT_CHAR
    li $a0, '\n'
    syscall
    li $v0, PRINT_INT
    move $a0, $t1
    syscall

    li $v0, EXIT_WCODE # exit2 call code
    li $a0, 0
    syscall

# check_is_prime($a0: word - UINT) -> $v0 = bool (word) 
check_is_prime:
    # 1. Setare stack frame
    addi $sp, $sp, -4
    sw $fp, 0($sp) # Push old frame pointer
    move $fp, $sp # Setup new frame pointer

    # 2. Body;
    # VARS: $t0 = num, $t1 = is_prime, $t2 = i
    move $t0, $a0 # num 
    li $t1, 0 # is_prime = false

    blt $t0, 2, check_is_prime_loop_end # Sari la final daca num <= 2

    li $t1, 1 # is_prime = true
    li $t2, 2 # i = 2
    check_is_prime_loop_iter:
        bge $t2, $t0, check_is_prime_loop_end # if (i >= n)

        remu $t3, $t0, $t2 # t3 = n % i 

        bnez $t3, check_is_prime_loop_1 
        li $t1, 0 # is_prime = false
        b check_is_prime_loop_end
    check_is_prime_loop_1: 

        # li $v0, PRINT_CHAR
        # li $a0, '\n'
        # syscall
        # li $v0, PRINT_INT
        # move $a0, $t2
        # syscall
        # li $v0, PRINT_CHAR
        # li $a0, ' '
        # syscall
        # li $v0, PRINT_INT
        # move $a0, $t3
        # syscall

        addi $t2, $t2, 1
        b check_is_prime_loop_iter

    check_is_prime_loop_end: 
    move $v0, $t1

    # 3. Stack frame & return
    lw $fp, 0($sp)
    addi $sp, $sp, 4 
    jr $ra
