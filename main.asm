#class: 2340.501
#members: Rishi Bhojwani,Lauren Nguyen,Sharmin Gaziani

.data
	# Print instructions
	selectNumPrompt: .asciiz  "Select a number from 1 and 63, and the mind reader will reveal your number.\n"
	isNumberPresent: 	.asciiz "If your number is displayed enter y, if not, enter n\n"
	startGamePrompt:		.asciiz "\nDo you want to play a game (y / n): "
	isNumOnCard:		.asciiz "Is the number on this card? (y / n): "
	wrongInput:	.asciiz "Inocrrect input\n\n"
	result: 	.asciiz "You number is: "

	# Helper print staments
	spaceBetweenNums: .asciiz " | "
	newLine:	 .asciiz "\n"

	# Holds numbers 
	answer:		.space 256
	buffer: 	.word 0


.text
	mainFunction:
		
		jal startPro#start of the program

		li $v0, 4
		la $a0, selectNumPrompt#prompt user for to think of a number
		syscall
		
		la $a0,newLine
		li $v0, 4
		syscall


		li $a1, 7
		li $v0,42
		syscall # In order to create random number (1,2,3,4,5,6)
		
		addi $t1, $a0,1
		li $a1,2 					
		li $v0, 42
		syscall 	#output random generated numbers
		
		li $t2, 5
		beq $a0, $zero, cardLogic
		

	next:
		move $t1, $a0 #copy value to new register
		and $t2, $a0, $a1 		
		beq $t2, $zero, toNext
		beq $t2, $a1, toNext
		addi $t1, $t1,8 		
	
	
	toNext:
		srl $v0, $t1, 1 		
		jr $ra
		
	
	
	cardLogic:
		li $t2, 3
		move $a0, $t1
		move $a1,$t2
		jal order
		move $t9, $v0
	
	
	
 
	finalPredic:#shows final card prediction
		la $a0,newLine
		li $v0, 4
		syscall

		li $v0, 4
		la $a0,result #num user thinks of
		syscall

		move $a0,$t9
		li $v0,1
		syscall

		
		la $a0,newLine	
		li $v0,4
		syscall
		
		j mainFunction	

	
	
	
	order:#has to iterate seven times and registers filled
		add $t2, $zero, $zero
		move $t3, $a0 				
		move $t4, $a1 				
		add $t5, $zero, $zero
		
	
	
	
	begin:#when loop has iterated several times, it will halt and move on
		add $t1,$zero,7
		beq $t2, $t1, end
		addiu $sp,$sp,-20 		
		sw $ra, 16($sp) 			
		sw $t2,12($sp) 			
		sw $t3,8($sp)			
		sw $t4,4($sp)			
		sw $t5,($sp) 			
		move $a0,$t3 
		move $a1,$t4 
		jal next #save return address
		sw  $v0,8($sp) 					
		move $t3, $v0
		add $t1, $zero, 7
		beq $t3, $t1,add

		# Need to ask user if number is displayed
		li $v0, 4
		la $a0,isNumberPresent #output number
		syscall
		
		la $a0,newLine
		li $v0,4
		syscall #newline
	
		addi $t1, $zero, 1
		addi $t3, $t3, 	-1 			
		sllv $t1,$t1,$t3 	#shift reg val
		
		# Finally print card
		move $a0, $t1
		jal showCard
		la $a0,newLine
		li $v0,4
		syscall

		
		la $a0,answer #users answer
		li $a1,3
		li $v0,8
		syscall#get users num
		
		lb $t5,0($a0)
		bne $t5,'y', add #yes if num is present
		
		
		lw $t3,8($sp)
		addi $t1,$zero, 1
		addi $t3,$t3, -1 
		sllv $t1,$t1, $t3 #pass user num to card math
		
		
		lw $t5,($sp) 			
		add $t5,$t5, $t1
		sw $t5, ($sp) #add crd num to user sum
		
	
	
	add:
		lw $ra,16($sp)
		lw $t2, 12($sp)
		lw $t3, 8($sp) #store user num
		lw $t4, 4($sp)
		lw $t5,($sp)
		addiu $sp, $sp,20
		addi $t2, $t2, 1
		j begin
		
	
	
	end:
		move $v0, $t5
		jr $ra
	
	
	
	showCard: #function used to display cards
		move $s0, $a0 	
		li $s1, 64 
		move $t2, $a0 	
		move $t6, $zero 
		addi $t2, $t2, -1
		

	NewLine: #newline
		la $a0,newLine
		li $v0,4
		syscall
		
		j cardLoop
		
	
	
	cardLoop: #card loop
		addi $t2,$t2,1
		slt $t4,$t2, $s1
		beq $t4,$zero,return
		and $t3, $t2, $s0
		bne $t3,$s0,cardLoop
		move $a0,$t2
		li $v0,1
		syscall
		
		addi $t6, $t6,1 #display
		andi $t5, $t6, 7
		beq $t5, $zero, NewLine
		la $a0,spaceBetweenNums
		li $v0,4
		syscall
		
		j cardLoop #create new cards and show the user

	
	exit:	#exit commnd
		li $v0,10
		syscall
	
	
	
	
	checkerErrors:	
		li $v0, 4	
		la $a0, wrongInput	#checks for incorrect error		
		syscall					
		j mainFunction	
		
		
		
		
	startPro:
		li $v0,4			
		la $a0,startGamePrompt	#ask to play game	
		syscall


		sw $zero, buffer #buf hold data
		li $v0, 8				
		la $a0,	buffer				
		li $a1, 20				
		syscall
		
		addi $t1, $zero, 110			
		addi $t7,$zero, 121			
		lb $t2,($a0)
		beq $t2,$t1, exit#check if user wants to play the game 			
		bne $t2,$t7, checkerErrors  #check user input
		jr $ra
	
	
	
	
	return: 
		jr $ra #return control

				

