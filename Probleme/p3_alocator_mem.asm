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

# Text pentru demo
str_malloc:   .asciiz "Alocat bloc: "
str_free:     .asciiz "\nStergere bloc din mijloc...\n"
str_compact:  .asciiz "compact()...\n"
str_log_pos:  .asciiz "LOG - Addr: "
str_log_size: .asciiz " Lungime: "
str_nl:       .asciiz "\n"

.text
.globl main
main: 
    # 1. Bloc A (64 octeti)
    li $a0, 64
    jal malloc
    move $s0, $v0 
    
    la $a0, str_malloc
    li $v0, PRINT_STR
    syscall
    move $a0, $s0
    li $v0, PRINT_INT
    syscall

    # 2. Bloc B (128 octeti)
    li $a0, 128
    jal malloc
    move $s1, $v0
    
    la $a0, str_nl
    li $v0, PRINT_STR
    syscall
    la $a0, str_malloc
    syscall
    move $a0, $s1
    li $v0, PRINT_INT
    syscall

    # 3. Bloc C (32 octeti)
    li $a0, 32
    jal malloc
    move $s2, $v0
    
    la $a0, str_nl
    li $v0, PRINT_STR
    syscall
    la $a0, str_malloc
    syscall
    move $a0, $s2
    li $v0, PRINT_INT
    syscall

    # 4. free(B)
    la $a0, str_free
    li $v0, PRINT_STR
    syscall
    move $a0, $s1
    jal free

    # 5. compact()
    la $a0, str_compact
    li $v0, PRINT_STR
    syscall
    jal compact

    # 6. print_log()
    jal print_log

    # Exit
    li $v0, EXIT_WCODE
    li $a0, 0
    syscall

# print_log(): afiseaza elementele din log
print_log:
    lw $t8, LOG_USED_COUNT
    la $t9, LOG
    li $t0, 0
    print_log_loop:
        bge $t0, $t8, print_log_end
        
        la $a0, str_log_pos
        li $v0, PRINT_STR
        syscall
        
        sll $t1, $t0, 2
        add $t1, $t9, $t1
        lw $a0, 0($t1) # LOG[i]
        li $v0, PRINT_INT
        syscall
        
        la $a0, str_log_size
        li $v0, PRINT_STR
        syscall
        
        lw $a0, 4($t1) # LOG[i+1]
        li $v0, PRINT_INT
        syscall
        
        la $a0, str_nl
        li $v0, PRINT_STR
        syscall
        
        addi $t0, $t0, 2
        j print_log_loop
    print_log_end:
    jr $ra

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
        lw $t2, 0($t1) # a = MEMLOG[i]
    
        bne $t2, $a0, free_loop1_ptr_neq # if (a == ptr) ... else goto free_loop1_ptr_neq
            # sterge pozitia i ($t0) prin shift stanga
            move $t3, $t0 # j = i
            sub $t4, $s0, 2 # stop la LOG_USED_COUNT - 2
            free_loop2:
                bge $t3, $t4, free_loop2_end

                sll $t5, $t3, 2 # t3 = j * 4
                add $t5, $s1, $t5 # &LOG + j * sizeof(int)
                lw $t6, 8($t5) # LOG[j + 2]

                sw $t6, 0($t5) # LOG[j] = LOG[j+2]

                addi $t3, $t3, 1
                b free_loop2
            free_loop2_end:

            sub $s0, $s0, 2
            sw $s0, LOG_USED_COUNT
            b free_loop1_end

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

# void compact()
compact: 
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
    la $s1, MEM
    la $s2, LOG
    lw $s3, LOG_USED_COUNT
    move $s4, $s1 # ultima adresa utilizabila pentru compactare (apu)

    li $t0, 0 # i
    compact_loop1: 
        bge $t0, $s3, compact_loop1_end

        sll $t1, $t0, 2 
        add $t1, $s2, $t1 # &LOG + i * 4
        lw $t2, 0($t1) # a = addr
        lw $t3, 4($t1) # s = alloc size

        bge $s4, $t2, compact_after_move # daca apu < a -> exista spatiu gol
            li $t4, 0 # j
            compact_loop2:
                bge $t4, $t3, compact_loop2_end

                add $t5, $t2, $t4 # t5 = a + j
                add $t6, $s4, $t4 # t6 = apu + j

                lb $t7, 0($t5) # char ch = *(a + j)
                sb $t7, 0($t6)

                addi $t4, $t4, 1
                b compact_loop2
            compact_loop2_end:
            sw $s4, 0($t1) # updateaza adresa de start in LOG[i]
        compact_after_move:
        add $s4, $s4, $t3 # apu += s

        addi $t0, $t0, 2
        b compact_loop1
    compact_loop1_end:

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