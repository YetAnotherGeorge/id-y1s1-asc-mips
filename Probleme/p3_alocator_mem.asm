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

# BLOC MEMORIE
mem: .space 1024
mem_len: .word 1024

log: .space 512 # Fiecare item va avea 2 word-uri: LOCATIE_IN_MEM, LUNGIME
log_len: .word 512
log_idx: .word 0 # Pozitia urmatorului 

.text
.globl main
main: 

    li $v0, EXIT_WCODE # exit2 call code
    li $a0, 0
    syscall

# malloc($a0: octeti de alocat) -> $v0 contine adresa sau 0.
# Adresa blocului mem cel mai probabil nu va contine 0.
malloc: 
    # Stack Frame
    addi $sp, $sp, -24
    sw $fp, 20($sp)
    move $fp, $sp # Frame pointer nou
    sw $s0, 16($sp) # Folosesc s-uri pentru mem si log
    sw $s1, 12($sp)
    sw $s2, 8($sp)
    sw $s3, 4($sp)
    sw $s4, 0($sp)

    li $v0, 0 # Default pentru return
    lw $s0, mem_len # VAR: mem len
    lw $s1, log_len # VAR: log len
    lw $s2, log_idx # VAR: first free index
    la $s3, mem # VAR: mem pointer
    la $s4, log # VAR: log pointer
    
    sub $t1, $s0, $a0 # VAR: t1 = index de la care nu mai exista loc de alocare
    add $t1, $t1, 1

    li $t0, 0 # i
    malloc_loop1: 
        bge $t0, $t1, malloc_loop1_end

        # $t0 poate fi o pozitie alocata ca dimensiune, verific daca este si libera
        li $t2, 1 # is_free = true
        li $t3, 0 # j
        malloc_loop2: 
            

        malloc_loop2_end:

        addi $t0, $t0, 1
        b malloc_loop1
    malloc_loop1_end: 

    # Return from malloc call
    lw $s4, 0($sp)
    lw $s3, 4($sp)
    lw $s2, 8($sp)
    lw $s1, 12($sp)
    lw $s0, 16($sp)
    lw $fp, 20($sp)
    addi $sp, $sp, 24
    jr $ra 


free: 
    # Stack Frame
    addi $sp, $sp, -4
    sw $fp, 0($sp)
    move $fp, $sp # Frame pointer nou

    # Return from malloc call
    lw $fp, 0($sp)
    addi $sp, $sp, 4
    jr $ra 

compact: 
    # Stack Frame
    addi $sp, $sp, -4
    sw $fp, 0($sp)
    move $fp, $sp # Frame pointer nou

    # Return from malloc call
    lw $fp, 0($sp)
    addi $sp, $sp, 4
    jr $ra 