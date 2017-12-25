.data

header: .space 26

topic: 		.asciiz "Generating Barnsley fern.\n"
ifile: 		.asciiz "input6.bmp"
ofile: 		.asciiz "output.bmp"
ierror:		.asciiz "failed to open input.bmp :( \n"
ierror2:	.asciiz "failed to read input.bmp :( \n"
oerror:		.asciiz "failed to open output.bmp :( \n"
oerror2:	.asciiz "failed to write output.bmp :( \n"
endl:		.asciiz "\n"

.globl main
.text

main:
	li $v0, 4
	la $a0, topic
	syscall			#writing the topic
	
open_file:
	li $v0, 13		#set $v0 to open file
	la $a0, ifile		#set $a0 to input file name
	li $a1, 0		#set $a1 to read only flag: 0
	li $a2, 0		#set $a2 to mode: 0 (mode is ignored)
	syscall			#open file input.bmp
	
	la $t0, ($v0)		#save file descriptor in $t0
	blt $t0, 0, open_error	#branch if descriptor is negative (opening input file failed)
	
read_file:
	li $v0, 14		#set $v0 to read file
	la $a0, ($t0)		#set $a0 to file descriptor
	la $a1, header		#set $a1 to destination adress
	la $a2, 26		#set $a2 to max nubers of chars (14+12)
	syscall			#read file input.bmp
	
	ble $v0, 0, read_error	#branch if number of characters read is less or equal 0
	
	li $v0, 16		#set $v0 to close file
	la $a0, ($t0)		#set $a0 to file descriptor
	syscall			#close file input.bmp
	
	ulw $s0, header+2	#store input.bmp size in $s0
	ulw $s1, header+10	#store input.bmp offset in $s1
	ulw $s2, header+18	#store input.bmp width in $s2
	ulw $s3, header+22	#store input.bmp height in $s3	

open_file2:
	li $v0, 13		#set $v0 to open file
	la $a0, ifile		#set $a0 to input file name
	li $a1, 0		#set $a1 to read only flag: 0
	li $a2, 0		#set $a2 to mode: 0 (mode is ignored)
	syscall			#open file input.bmp
	
	la $t0, ($v0)		#save file descriptor in $t0
	blt $t0, 0, open_error	#branch if descriptor is negative (opening input file failed)
	
read_pixels:
	li $v0, 9		#set $v0 to allocate heap memory
	la $a0, ($s0)		#set $a0 to input.bmp size
	syscall			#allocate memory
	
	la $s4, ($v0)		#set $s4 to memory adress
	
	li $v0, 14		#set $v0 to read file
	la $a0, ($t0)		#set $a0 to file descriptor
	la $a1, ($s4)		#set $a1 to destination adress
	la $a2, ($s0)		#set $a2 to max nubers of chars (size in $s0)
	syscall
	
	li $v0, 16		#set $v0 to close file
	la $a0, ($t0)		#set $a0 to file descriptor
	syscall			#close file input.bmp
	
	ble $v0, 0, read_error	#branch if number of characters read is less or equal 0
	
padding:
	li $s5, 24		#set $s5 to 24	
	mul $s5, $s5, $s2	#multiply $s5 by input.bmp width ($s2)
	addiu $s5, $s5, 31	#add 31 to $s5
#	divu $s5, $s5, 32	#divide $s5 by 32 (sets $s5 to floor)
	srl $s5, $s5, 5
#	mul $s5, $s5, 4		#miltiply $s5 by 4, result is RowSize of the pixel array
	sll $s5, $s5, 2
	
begin:
	li $t0, 0		#store x=0 in $t0, we use x from -3 to 3
	li $t1, 0		#store y=0 in $t1, we use y from 0 to 10
	li $s6, 0		#set $s6 to loop count
	
loop:
	li $v0, 42		#set $v0 to random int range
	la $a0, 6		#set $a0 to 6, just... because
	li $a1, 100		#set $a1 to the upper bound: 100
	syscall
	
	ble $a0, 84, f2		#branch to f2 if random number is less or equall 84 (it will be in 85% of cases)
	b f3			#otherwise branch to f3, where will be chosen between f3, f4 and f1
	
do:

	la $t2, ($t0)		#store x in $t2 ($t2 pixel x coordinate)
	la $t3, ($t1)		#store y in $t3 ($t3 pixel y coordinate)
	
	li $t7, 0x18000000
	add $t2, $t2, $t7	#add 3 to $t2
	mul $t2, $t2, $s2	#multiply $t2 by input.bmp width
	mfhi $t6
	sll $t6, $t6, 5
	srl $t2, $t2, 27
	add $t2, $t2, $t6
	div $t2, $t2, 6		#divide by 6, now $t2 is the x pixel coordinate
	mul $t2, $t2, 3		#set $t2 to the actual pixel x index (first byte of the pixel)
	
	mul $t3, $t3, $s3	#multiply $t3 by input.bmp height
	mfhi $t6
	sll $t6, $t6, 5
	srl $t3, $t3, 27
	add $t3, $t3, $t6
	div $t3, $t3, 10	#divide by 10, now $t3 is the y pixel coordinate
	mul $t3, $t3, $s5	#set $t3 to the distance form (X,0) pixel to (X,Y) pixel
	
	la $t4, ($s4)		#set $t4 to allocated memory adress
	add $t4, $t4, $s1	#set $t4 to adress of first pixel
	add $t4, $t4, $t2	#set $t4 to the actual byte in x plane
	add $t4, $t4, $t3	#set $t4 to the actual pixel adress (first byte)
	
	#BGR codes:
	#pink (180, 105, 255)
	#darkyellow1 (204, 204, 0)
	#darkyellow2 (153, 153, 0)
	#darkyellow3 (102, 102, 0)
	
	li $t5, 204		#set $t5 to 0 (blue)
	sb $t5, ($t4)		#store in pixel array
	
	li $t5, 204		#set $t5 to 255 (green)
	addiu $t4, $t4, 1	#increment pointer to next pixel color
	sb $t5, ($t4)		#store in pixel array
	
	li $t5, 0		#set $t5 to 0 (red)
	addiu $t4, $t4, 1	#increment pointer to next pixel color
	sb $t5, ($t4)		#store in pixel array
	
	addiu $s6, $s6, 1
	blt $s6, 1000000, loop
	
open_file_write:
	li $v0, 13		#set $v0 to open file
	la $a0, ofile		#set $a0 to output file name
	li $a1, 1		#set $a1 to write only with create
	li $a2, 0		#set $a2 to mode: 0 (mode is ignored)
	syscall			#open file output.bmp
	
	la $t0, ($v0)		#save file descriptor in $t0
	blt $t0, 0, open_errorw	#branch if descriptor is negative (opening output file failed)
	
write_file:
	li $v0, 15		#set $v0 to write to file
	la $a0, ($t0)		#set $a0 to file descriptor
	la $a1, ($s4)		#set $a1 to allocated memory adress
	la $a2, ($s0)		#set $a2 to input.bmp size
	syscall
	
	ble $v0, 0, write_error
	
	li $v0, 16		#set $v0 to close file
	la $a0, ($t1)		#set $a0 to file descriptor
	syscall			#close output.bmp

	b exit
	

f2:
	li $t7, 0x06cccccd
	mul $t2, $t0, $t7	#set $t2 to 0,85 xn (low order 32bits)
	mfhi $t6					#set $t6 to 0,85 xn (hi order 32bits)
	sll $t6, $t6, 5					#shift hi part left by 5 bits
	srl $t2, $t2, 27				#shift lo part right by 27 bits
	add $t2, $t2, $t6
					#connect both parts
	li $t7, 0x0051eb85				
	mul $t3, $t1, $t7	#set $t3 to 0,04 yn (low order 32bits)
	mfhi $t6					#set $t6 to 0,04 yn (hi order 32bits)
	sll $t6, $t6, 5					#shift hi part left by 5 bits
	srl $t3, $t3, 27				#shift lo part right by 27 bits
	add $t3, $t3, $t6				#connect both parts
	
	li $t7, 0xffae147b
	mul $t4, $t0, $t7	#set $t4 to -0,04 xn (low order 32bits)
	mfhi $t6					#set $t6 to -0,04 xn (hi order 32bits)
	sll $t6, $t6, 5					#shift hi part left by 5 bits
	srl $t4, $t4, 27				#shift lo part roght by 27 bits
	add $t4, $t4, $t6				#connect both parts
	
	li $t7, 0x06cccccd
	mul $t5, $t1, $t7	#set $t4 to 0,85 yn (low order 32bits)
	mfhi $t6					#set $t6 to 0,85 yn (hi order 32 bits)
	sll $t6, $t6, 5					#shift hi part left by 5 bits
	srl $t5, $t5, 27				#shift lo part right by 27 bits
	add $t5, $t5, $t6				#connect both parts 
	
	add $t0, $t2, $t3				#set $t0 to 0,85 xn + 0,04 yn
	
	li $t7, 0x0ccccccd
	add $t1, $t4, $t5				#set $t1 to -0,04 xn + 0,85 yn
	add $t1, $t1, $t7	#add 1,6 to $t1
	
	b do			#branch to do (the "rest" of the loop)
	
f3:
	bgt $a0, 91, f4		#branch to f4 if none of the seven reserved values for f3 is in $a0
	
	li $t7, 0x0199999A
	mul $t2, $t0, $t7	#set $t2 to 0,2 xn (low order 32bits)
	mfhi $t6					#set $t6 to 0,2 xn (hi order 32bits)
	sll $t6, $t6, 5					#shift hi part left by 5 bits
	srl $t2, $t2, 27				#shift lo part right by 27 bits
	add $t2, $t2, $t6				#connect both parts
	
	li $t7, 0xFDEB851F
	mul $t3, $t1, $t7	#set $t3 to -0,26 yn (low order 32bits)
	mfhi $t6					#set $t6 to -0,26 yn (hi order 32 bits)
	sll $t6, $t6, 5					#shift hi part left by 5 bits
	srl $t3, $t3, 27				#shift lo part right by 27 bits
	add $t3, $t3, $t6				#connect both parts
	
	li $t7, 0x01D70A3D
	mul $t4, $t0, $t7	#set $t4 to 0,23 xn (low order 32bits)
	mfhi $t6					#set $t6 to 0,23 xn (hi order 32bits)
	sll $t6, $t6, 5					#shift hi part left by 5 bits
	srl $t4, $t4, 27				#shift lo part right by 27 bits
	add $t4, $t4, $t6				#connect both parts
	
	li $t7, 0x01C28F5C
	mul $t5, $t1, $t7	#set $t5 to 0,22 yn (low order 32bits)
	mfhi $t6					#set $t6 to 0,22 yn (hi order 32bits)
	sll $t6, $t6, 5					#shift hi part left by 5 bits
	srl $t5, $t5, 27				#shift lo part right by 27 bits
	add $t5, $t5, $t6				#connect both parts
	
	add $t0, $t2, $t3				#set $t0 to 0,2 xn - 0,26 yn
	
	li $t7, 0x0CCCCCCD
	add $t1, $t4, $t5				#set $t1 to 0,23 xn + 0,22 yn
	add $t1, $t1, $t7	#add 1,6 to $t1
	
	b do			#branch to do (the "rest" of the loop)
	
f4:
	beq $a0, 99, f1
	
	li $t7, 0xFECCCCCD
	mul $t2, $t0, $t7	#set $t2 to -0,15 xn (low order 32bits)
	mfhi $t6					#set $t6 to -0,15 xn (hi order 32bits)
	sll $t6, $t6, 5					#shift hi part left by 5 bits
	srl $t2, $2, 27					#shift lo part right by 27 bits
	add $t2, $t2, $t6				#connect both parts
	
	li $t7, 0x023D70A4
	mul $t3, $t1, $t7	#set $t3 to 0,28 yn (low order 32bits)
	mfhi $t6
	sll $t6, $t6, 5
	srl $t3, $t3, 27
	add $t3, $t3, $t6
	
	li $t7, 0x02147AE1
	mul $t4, $t0, $t7	#set $t4 to 0,26 xn (low order 32bits)
	mfhi $t6
	sll $t6, $t6, 5
	srl $t4, $t4, 27
	add $t4, $t4, $t6
	
	li $t7, 0x01EB851F
	mul $t5, $t1, $t7	#set $t5 to 0,24 yn
	mfhi $t6
	sll $t6, $t6, 5
	srl $t5, $t5, 27
	add $t5, $t5, $t6
	
	add $t0, $t2, $t3				#set $t0 to -0,15 xn + 0,28 yn
	
	li $t7, 0x03851EB8
	add $t1, $t4, $t5				#set $t1 to 0,26 xn + 0,24 yn
	add $t1, $t1, $t7	#add 0,44 to $t1
	
	b do			#branch to do (the "rest" of the loop)
	
f1:
	li $t0, 0		#set $t0 to 0
	
	li $t7, 0x0147AE14
	mul $t1, $t1, $t7	#set $t1 to 0,16 yn
	mfhi $t6
	sll $t6, $t6, 5
	srl $t1, $1, 27
	add $t1, $t1, $t6
		
	b do			#branch to do (the "rest" of the loop)
	
open_error:
	li $v0, 4
	la $a0, ierror
	syscall			#write ierror
	b exit			#branch to exit
	
open_errorw:
	li $v0, 4
	la $a0, oerror
	syscall			#write oerror
	b exit			#branch to exit
	
read_error:
	li $v0, 4
	la $a0, ierror2
	syscall			#write ierror2
	b exit			#branch to exit
	
write_error:
	li $v0, 4
	la $a0, oerror2
	syscall			#write oerror2
	b exit			#branch to exit
	
exit:
	li $v0, 10
	syscall
