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

# MATRICI INPUT
mat_sz_1: .byte 3 # Nr. Randuri de la #1
mat_sz_2: .byte 4 # Nr. Col de la #1, Nr. Randuri de la #2
mat_sz_3: .byte 5 # Nr. Col de la #2

mat_1: .word 1, 0, 0, 2,
             3, 1, 0, 0,
             0, 0, 1, 0

mat_2: .word 1, 2, 3, 0, 5,
             0, 3, 0, 0, 0,
             0, 0, 3, 1, 0,
             5, 0, 0, 3, 0

.text
.globl main
main: 
    # Afiseaza dimensiuni
    li $v0, PRINT_INT
    lb $a0, mat_sz_1
    syscall
    li $v0, PRINT_CHAR
    li $a0, 'x'
    syscall
    li $v0, PRINT_INT
    lb $a0, mat_sz_2
    syscall
    li $v0, PRINT_CHAR
    li $a0, 'x'
    syscall
    li $v0, PRINT_INT
    lb $a0, mat_sz_3
    syscall
    li $v0, PRINT_CHAR
    li $a0, '\n'
    syscall

    # Pentru dim matrici, folosesc s-urile, deci to stack cu ele
    addi $sp, $sp, -28
    sw $s0, 0($sp) 
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)
    sw $s4, 16($sp)
    sw $s5, 20($sp)
    sw $s6, 24($sp)

    # Matrici: 
    #   MAT   1: $s0 = rows, $s1 = cols; DATA POINTER: $s3 
    #   MAT   2: $s1 = rows, $s2 = cols; DATA POINTER: $s4
    #   MAT RES: $s0 = rows, $s2 = cols; DATA POINTER: $s5 = lungime, $s6 = pointer
    lb $s0, mat_sz_1
    lb $s1, mat_sz_2
    lb $s2, mat_sz_3
    la $s3, mat_1
    la $s4, mat_2
    mul $s5, $s0, $s2

    # Muta stack-ul $s0 x $s2 word-uri mai jos si salveaza valoarea stack pointer in $s6
    mul $t0, $s5, 4
    sub $sp, $sp, $t0 # Creeaza spatiu pe stack pentru matricea rezultat
    la $s6, 0($sp)

    li $t0, 0 # for (i = 0; i < mat1.rows; i++)
    main_loop1:
        li $t1, 0 # for (j = 0; j < mat2.cols; j++)
        main_loop2:
            # ITER BODY
            mul $t2, $t0, $s2 # mat_res[i][j] = i * mat2.cols
            add $t2, $t2, $t1 #                 + j
            mul $t2, $t2, 4   # * sizeof(word)
            add $t2, $t2, $s6 # POINTER + t2 

            # inmultirea mat_1[i][_] cu mat_2[_][j]; t2 = pozitia la care tb stocat rezultatul
            li $t9, 0 # suma in t9
            li $t3, 0 # for (k = 0; k < mat_sz_2; k++)
            main_loop3: 
                # mat_1: mat_1[i][k] in $t4
                mul $t4, $t0, $s1  # mat_1[i][k] = i * mat1.cols
                add $t4, $t4, $t3  #               + k
                mul $t4, $t4, 4    # * sizeof(word)
                add $t4, $t4, $s3  # POINTER + t4
                lw $t4, 0($t4) # and finally, mat_1[i][k]

                # mat_2: mat_2[k][j] in $t5
                mul $t5, $t3, $s2  # mat_2[k][j] = k * mat2.cols
                add $t5, $t5, $t1  #               + j
                mul $t5, $t5, 4    # * sizeof(word)
                add $t5, $t5, $s4  # POINTER + t4
                lw $t5, 0($t5) # mat_2[k][j]

                mul $t6, $t4, $t5
                add $t9, $t9, $t6

                # LOOP STUFF
                addi $t3, $t3, 1
                bge $t3, $s1, main_loop3_end
                b main_loop3
            main_loop3_end:
            
            # Salveaza $t9 in mat_3[i][j]
            sw $t9, 0($t2)

            #region PRINT TARGET POS
            li $v0, PRINT_INT
            move $a0, $t0
            syscall
            li $v0, PRINT_CHAR
            li $a0, ' '
            syscall
            li $v0, PRINT_INT
            move $a0, $t1
            syscall
            li $v0, PRINT_CHAR
            li $a0, ':'
            syscall
            li $v0, PRINT_CHAR
            li $a0, ' '
            syscall
            li $v0, PRINT_INT
            move $a0, $t9
            syscall
            li $v0, PRINT_CHAR
            li $a0, '\n'
            syscall
            #endregion

            addi $t1, $t1, 1
            bge $t1, $s2, main_loop2_end
            b main_loop2
        main_loop2_end:
        li $v0, PRINT_CHAR
        li $a0, '\n'
        syscall

        addi $t0, $t0, 1
        bge $t0, $s0, main_loop1_end
        b main_loop1
    main_loop1_end:

    # MATRICEA REZULTAT SE AFLA IN $s6, de lungime $s5 (liniarizata)    

    # 'Dealoca' din stack matricea rezultat
    mul $t0, $s5, 4
    add $sp, $sp, $t0

    # Restore s-registers
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $s4, 16($sp)
    lw $s5, 20($sp)
    lw $s6, 24($sp)
    addi $sp, $sp, 28

    li $v0, EXIT_WCODE # exit2 call code
    li $a0, 0
    syscall
