.data
main_str_1: .asciiz ", and sum is: "
.text 
.globl main
main: 
	li $t0, 777 # want to keep 
	
	# Call: sum: Save t0 
	addi $sp, $sp, -4 # make room in stack
	sw $t0, 0($sp) # store t0
	
	li $a0, 5  # Load args
	li $a1, 10 # Load args
	jal test_sum
	move $t1, $v0 # Save result 
	
	lw $t0, 0($sp) # load $t0 from stack 
	addi $sp, $sp, 4 # Restore stack
	
	li $v0, 1
	move $a0, $t0
	syscall # Print $t0 (777)
	
	li $v0, 4
	la $a0, main_str_1
	syscall
	
	li $v0, 1
	move $a0, $t1
	syscall # Print $t1 (result of test_sum)
	
	# Return 0
	li $v0, 17
	li $a0, 0
	syscall

# test_sum($a0 = word, $a1 = word) -> $v0 = $a0 + $a1
test_sum: 
	# Establish the stack frame
	addi $sp, $sp, -8
	sw $fp, 4($sp) # Push old frame pointer
	sw $s0, 0($sp) # Push $s0
	
	move $fp, $sp # Setup new frame pointer
	
	# Body
	add $s0, $a0, $a1
	move $v0, $s0
	
	# End
	lw $s0, 0($sp) # Pop $s0
	lw $fp, 4($sp) # Pop old frame pointer
	addi $sp, $sp, 8
	jr $ra # return
	