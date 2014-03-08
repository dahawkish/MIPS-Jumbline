	.data
	prompt: .asciiz  "Choose the number of characters to play with. The choices are 5, 6, and 7\n"
	Num: .word 5
	NUMBERS: 
		.word 12616
		.word 25414
 		.word 38926
	Filein: .space 19  
	Buffer:
		.space 4096
	QuestionString: 
		.space 8
	AnswerString:
		.space 4096
		

	
	.text
	
main:
	li $v0, 4
	la $a0, prompt #show the prompt
	syscall
	
	li $v0, 5
	syscall
	move $t2, $v0
	
	la $t1, Num
	sw $t2, 0($t1)
	
	addi $t0, $t2, 48
	la $t1, Filein
	sb $t0, 0($t1)
	
	li $t0, 92	# $t2 = '\'
	addi $t1, $t1, 1
	sb $t0, 0($t1)
	addi $t1, $t1, 1
	sb $t0, 0($t1)	# Filein = '{5,6,7}\\'
	
	la $t3, NUMBERS
	addi $t2, $t2, -5
	sll $t2, $t2, 2
	add $t3, $t3, $t2
	lw $a1, 0($t3)
	li $a0, 100
	li $v0, 42
	syscall
	li $v0, 1
	syscall
	
	addi $t1, $t1, 1  
	move $a1, $t1
	jal ItoA 	# convert random number in $a0 to string
	
	addi $t1, $t1, 1  
	
	# Open (for writing) a file that does not exist
  	li   $v0, 13       # system call for open file
  	la   $a0, Filein     # input file name
  	li   $a1, 0        # Open for reading (flags are 0: read, 1: write)
 	li   $a2, 0        # mode is ignored
 	syscall            # open a file (file descriptor returned in $v0)
  	move $s6, $v0      # save the file descriptor 
  	
  	  # Write to file just opened
  	li   $v0, 14       # system call for read to file
  	move $a0, $s6      # file descriptor 
  	la   $a1, Buffer   # address of buffer from which to read
 	li   $a2, 4096       # hardcoded buffer length
  	syscall            # write to file
  	
	 # Close the file 
  	li   $v0, 16       # system call for close file
 	move $a0, $s6      # file descriptor to close
  	syscall            # close file
  	
  	la $a0, Buffer
  	la $a1, QuestionString
  	jal STRCOPY
  	move $a0, $v0
  	la $a1, AnswerString
  	jal STRCOPY
  	#################################################
  	#################################################
  	
  	#Jun and Kai's code goes here!!
  	
  	#################################################
  	#################################################
  	
  	
  	
  	li $v0, 10	#system call for termination
  	syscall
  	
#end of main function  	

#######################################################################################################
## int ItoA(int, char*)	
## arguments:
##    $a0 - integer to convert
##    $a1 - character buffer to write to
## return:  number of characters in converted string
##
#######################################################################################################
ItoA:
  	bnez $a0, ItoA.non_zero  # first, handle the special case of a value of zero
  	nop
  	li   $t0, '0'
  	sb   $t0, 0($a1)
  	sb   $zero, 1($a1)
  	li   $v0, 1
  	jr   $ra
ItoA.non_zero:
  	addi $t0, $zero, 10     # now check for a negative value
  	li $v0, 0
  	bgtz $a0, ItoA.recurse
  	nop
  	li   $t1, '-'
  	sb   $t1, 0($a1)
  	addi $v0, $v0, 1
  	neg  $a0, $a0
ItoA.recurse:
  	addi $sp, $sp, -24
  	sw   $fp, 8($sp)
  	addi $fp, $sp, 8
  	sw   $a0, 4($fp)
 	sw   $a1, 8($fp)
  	sw   $ra, -4($fp)
  	sw   $s0, -8($fp)
  	sw   $s1, -12($fp)
   
  	div  $a0, $t0       # $a0/10
  	mflo $s0            # $s0 = quotient
  	mfhi $s1            # s1 = remainder  
  	beqz $s0, ItoA.write
ItoA.continue:
  	move $a0, $s0  
  	jal ItoA.recurse
  	nop
ItoA.write:
  	add  $t1, $a1, $v0
  	addi $v0, $v0, 1    
  	addi $t2, $s1, 0x30 # convert to ASCII
  	sb   $t2, 0($t1)    # store in the buffer
  	sb   $zero, 1($t1)
  
ItoA.exit:
  	lw   $a1, 8($fp)
  	lw   $a0, 4($fp)
  	lw   $ra, -4($fp)
  	lw   $s0, -8($fp)
  	lw   $s1, -12($fp)
  	lw   $fp, 8($sp)    
  	addi $sp, $sp, 24
  	jr $ra
  	nop	
 ####################################################################################################### 	
 # String copier function
 ####################################################################################################### 	
STRCOPY:
	or $t0, $a0, $zero # Source
	or $t1, $a1, $zero # Destination
	li $t3, '\r'

LOOP:
	lb $t2, 0($t0)
	beq $t2, $t3, END
	addiu $t0, $t0, 1
	sb $t2, 0($t1)
	addiu $t1, $t1, 1
	b LOOP
	nop
END:
	sb $zero, 0($t1)
	addi $t0, $t0, 2
	or $v0, $t0, $zero # Return last position on source buffer
	jr $ra
	nop
	
