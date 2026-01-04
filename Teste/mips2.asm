.data                  # Directive: Start the data segment
counter:  .word 0                # Directive: Allocate 4 bytes and initialize to 0

          .text                  # Directive: Start the code segment
          .globl main            # Directive: Make 'main' label global
main:
    # 1. Load the initial value into a register
    lw $t0, counter              # $t0 = 0

loop:
    # 2. Check if we have reached 10
    li $t1, 10                   # Load immediate value 10 into $t1
    beq $t0, $t1, end_loop       # If $t0 == 10, jump to end_loop

    # 3. Increment the value by 2
    addi $t0, $t0, 2             # $t0 = $t0 + 2
    j loop                       # Jump back to the start of the loop

end_loop:
    # 4. Print the result
    li $v0, 1                    # System call code for print_int
    move $a0, $t0                # Move the value to $a0 for printing
    syscall

    # 5. Exit the program
    li $v0, 10                   # System call code for exit
    syscall