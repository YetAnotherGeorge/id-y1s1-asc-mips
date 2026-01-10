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
MEM: .space 1024
MEM_LEN: .word 1024

LOG: .space 512 # Fiecare item va avea 2 word-uri: (LOCATIE_IN_MEM, nr. bytes)
LOG_LEN: .word 512
LOG_USED_COUNT: .word 0 # Pozitia urmatorului 

.text
.globl main
main: 
    li $v0, EXIT_WCODE # exit2 call code
    li $a0, 0
    syscall

# bool log_insert_ordered(int mem_addr, int alloc_size_bytes): 
#   Garanteaza ca log va contine adrese in ordine
log_insert_ordered: 
    # Frame pointer + salvez s-urile
    addi $sp, $sp, -40
    sw $fp, 36($sp) # Frame pointer
    sw $ra, 32($sp) # Return Address

    sw $s0, 28($sp)
    sw $s1, 24($sp)
    sw $s2, 20($sp)
    sw $s3, 16($sp)
    sw $s4, 12($sp)
    sw $s5, 8($sp)
    sw $s6, 4($sp)
    sw $s7, 0($sp)
    move $fp, $sp # Frame pointer nou

    # BODY (mem_addr = $a0, alloc_size = $a1)
 
    # if (MEMLOG_USED_COUNT + 2 > MEMLOG_LEN) return false;
    lw $t0, LOG_USED_COUNT
    addi $t0, $t0, 2
    lw $t1, LOG_LEN
    ble $t0, $t1, log_insert_ordered_1
        li $v0, 0 # false - no space in log
        b log_insert_ordered_end
    log_insert_ordered_1:

    lw $s0, LOG_USED_COUNT # ins_pos (ca index in array); Caut pozitia de inserat ($s0)
    lw $s1, LOG_USED_COUNT # log_used_count; ramane fix, nu este schimbat
    la $s2, LOG # log

    li $t0, 0 # i = 0
    log_insert_ordered_loop1:
        bge $t0, $s1, log_insert_ordered_loop1_end

        la $t1, LOG
        sll $t4, $t0, 2 # i * 4
        add $t1, $t1, $t4
        lw $t1, 0($t1) # int a = MEMLOG[i]
        
        # daca adresa dorita <= MEMLOG[i] -> pozitia de inserare devine i -> $s0
        bgt $a0, $t1, log_insert_ordered_loop1_skip_ins
            move $s0, $t0 # update insert pos
            b log_insert_ordered_loop1_end
        log_insert_ordered_loop1_skip_ins:

        addi $t0, $t0, 2
    log_insert_ordered_loop1_end:

    # Inserare (pozitie de inserat in $s0)
    bge $s0, $s1, log_insert_ordered_shift_end
        # shift la dreapta cu 2
        move $t0, $s1
        subi $t0, $t0, 1 # for (int i = MEMLOG_USED_COUNT - 1; i >= ins_pos; i--)
        log_insert_ordered_shift_loop:
            blt $t0, $s0, log_insert_ordered_shift_end

            # MEMLOG[i + 2] = MEMLOG[i]; memlog = $s2, i = $t0
            sll $t1, $t0, 2 # i * 4
            add $t1, $s2, $t1 # t1 = MEMLOG[i]
            lw $t2, 0($t1)
            sw $t2, 8($t1) 

            subi $t0, $t0, 1
            b log_insert_ordered_shift_loop
    log_insert_ordered_shift_end:

    # MEMLOG[ins_pos] = mem_addr; MEMLOG = $s2, ins_pos = $s1, mem_addr = $a0
    sll $t0, $s0, 2
    add $t0, $s2, $t0 # &log + ins_pos * 4
    sw $a0, 0($t0) # MEMLOG[ins_pos] = mem_addr
    sw $a1, 4($t0) # MEMLOG[ins_pos + 1] = alloc_size

    addi $s1, $s1, 2 # MEMLOG_USED_COUNT += 2
    sw $s1, LOG_USED_COUNT
    li $v0, 1 # return true

    log_insert_ordered_end:
    lw $s7, 0($sp)
    lw $s6, 4($sp)
    lw $s5, 8($sp)
    lw $s4, 12($sp)
    lw $s3, 16($sp)
    lw $s2, 20($sp)
    lw $s1, 24($sp)
    lw $s0, 28($sp)

    lw $ra, 32($sp) # return address
    lw $fp, 36($sp) # Frame pointer
    addi $sp, $sp, 40
    jr $ra # inapoi


# IntPtr malloc(alloc_bytes = $s0)
malloc: 
    addi $sp, $sp, -40
    sw $fp, 36($sp) # Frame pointer
    sw $ra, 32($sp) # Return Address

    sw $s0, 28($sp)
    sw $s1, 24($sp)
    sw $s2, 20($sp)
    sw $s3, 16($sp)
    sw $s4, 12($sp)
    sw $s5, 8($sp)
    sw $s6, 4($sp)
    sw $s7, 0($sp)
    move $fp, $sp # Frame pointer nou

    # Body ($v0 = requested bytes to allocate)
    move $s6, $a0 # ALLOC_BYTES requested

    la $s5, MEM
    lw $s0, MEM_LEN

    li $v0, 0 # default: nu s-a putut aloca memoria
    ble $a0, 0, malloc_end # if (alloc_bytes <= 0) return 0;
    bgt $a0, $s0, malloc_end  # if (alloc_bytes > MEM_LEN) return 0;

    la $s1, MEM # alloc_addr
    add $s2, $s1, $a0 # alloc_addr_end = alloc_addr + alloc_bytes
    lw $s3, LOG_USED_COUNT
    la $s4, LOG

    # caut un block de memorie de dimensiune alloc_sz ($a0)
    li $t0, 0
    malloc_loop1:
        bge $t0, $s3, malloc_loop1_end

        sll $t1, $t0, 2 # i * sizeof(byte)
        add $t1, $s4, $t1 # &LOG + i * sizeof(byte)

        lw $t2, 0($t1) # int a = MEMLOG[i]
        lw $t3, 4($t1) # int s = MEMLOG[i + 1]

        ble $s2, $t2, malloc_loop1_end # if (alloc_addr_end <= a) break;

        add $s1, $t2, $t3 # alloc_addr = a + s
        add $s2, $s1, $a0 # alloc_addr_end = alloc_addr + alloc_bytes;

        addi $t0, $t0, 2
        b malloc_loop1
    malloc_loop1_end:

    # Verific daca de la $s2 pana la final este suficient spatiu
    sub $t0, $s2, $s5 # alloc_addr_end - &MEM
    bgt $t0, $s0, malloc_end

    move $a0, $s1
    move $a1, $s6
    jal log_insert_ordered #  bool could_insert = log_insert_ordered(alloc_addr, alloc_bytes);

    bne $v0, 0,  malloc_2
        li $v0, 0
        b malloc_end
    malloc_2:
        move $v0, $s1

    malloc_end:
    # End
    lw $s7, 0($sp)
    lw $s6, 4($sp)
    lw $s5, 8($sp)
    lw $s4, 12($sp)
    lw $s3, 16($sp)
    lw $s2, 20($sp)
    lw $s1, 24($sp)
    lw $s0, 28($sp)

    lw $ra, 32($sp) # return address
    lw $fp, 36($sp) # Frame pointer
    addi $sp, $sp, 40
    jr $ra # inapoi

# void free(int ptr)
free: 
    addi $sp, $sp, -40
    sw $fp, 36($sp) # Frame pointer
    sw $ra, 32($sp) # Return Address

    sw $s0, 28($sp)
    sw $s1, 24($sp)
    sw $s2, 20($sp)
    sw $s3, 16($sp)
    sw $s4, 12($sp)
    sw $s5, 8($sp)
    sw $s6, 4($sp)
    sw $s7, 0($sp)
    move $fp, $sp # Frame pointer nou

    # Body
    lw $s0, LOG_USED_COUNT
    la $s1, LOG
    lw $s2, MEM_LEN
    la $s3, MEM

    li $t0, 0 # i
    free_loop1:
        bge $t0, $s0, free_loop1_end

        sll $t1, $t0, 2
        add $t1, $s1, $t1 # &LOG + i * sizeof(int) 
    
        la $t2, 0($t1) # a = MEMLOG[i]
        bne $t2, $a0, free_loop1_ptr_neq # if (a == ptr) ... else goto free_loop1_ptr_neq
            # sterge pozitia i ($t0) prin shift stanga
            move $t3, $t0 # j = i
            sub $t4, $s0, 2 # stop la LOG_USED_COUNT - 2
            free_loop2:
                bge $t3, $t4, free_loop2_end


            free_loop2_end:

            # MEMLOG_USED_COUNT -= 2;
            # return;

        free_loop1_ptr_neq:
        addi $t0, $t0, 2
        b free_loop1
    free_loop1_end:

    # End
    lw $s7, 0($sp)
    lw $s6, 4($sp)
    lw $s5, 8($sp)
    lw $s4, 12($sp)
    lw $s3, 16($sp)
    lw $s2, 20($sp)
    lw $s1, 24($sp)
    lw $s0, 28($sp)

    lw $ra, 32($sp) # return address
    lw $fp, 36($sp) # Frame pointer
    addi $sp, $sp, 40
    jr $ra # inapoi