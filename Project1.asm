################# Authors #########################
 ####		   Mohammed Owda 1200089	     	####
  ###		   Osaid Hamza   1200875 	   	###
   ############################################
# Title: A Simple Dictionary-based Compression and Decompression Tool in MIPS Assembly	
#Filename:
# Date:
# Description:
# Input:
# Output:
################# Data segment #####################
.data
DBytes: .asciiz " bits"
Ratio: .asciiz "File Compression Ratio:"
Result: .asciiz "This means that the compressed file is smaller than the corresponding uncompressed file by "
Time : .ascii " times\n"
dividend: .float 0.0      # Float to be divided
divisor: .float 0.0       # Float used as the divisor
result: .float 0.0        # Variable to store the result
filename: .asciiz "output.txt"
NumCharactersUncompressedFile: .asciiz "The number of charaters in the uncompressed file is :"
NumCharactersCompressedFile: .asciiz "The number of charaters in the compressed file is :"
UncompressedFileSize: .asciiz "The size of the uncompressed file is :"
CompressedFileSize: .asciiz "The size of the compressed file is :"
string: .space 12
DisplayEnterUncompressedFile: .asciiz "Please enter the path of the file to be compressed:\n"
str1: .space 256 
MaxLength: .word 0
SearchForWord: .space 256
UncompressedFileName: .space 256 #name of the the file to be compressed
SpecialCharacters: .asciiz " ,.\n"
str: .space 10 # array of 10 bytes
DictionaryFile: .asciiz "Dictionary.txt"
filename2: .space 256
NewLine: .asciiz "\\n"
menu: .asciiz "\n1) Enter (c, compress, or compression) for compression.\n2) Enter (d, decompress, decompression) for decompression\n3) Enter (q or quit) to quit the program\nOption: "
isDictExist: .asciiz "Is the dictionary.txt file exist? (type yes or no): "
enterDictPath: .asciiz "Enter the Dictionary file path: "
invalidPath: .asciiz "Invalid path!!!\n"
invalidInput: .asciiz "Invalid Input!!!\n"
option: .space 100
answer: .space 16
yes: .asciiz "yes"
no: .asciiz "no"
compression_keyword: .asciiz "c", "compress", "compression" 
decompression_keyword: .asciiz "d", "decompress", "decompression" 
quit_keyword: .asciiz "q", "quit"
no_of_chars_inDict: .word 0
no_of_words_inDict: .word 0
UncompressedFileData: .space 10000   # 0.5 MB   #this is spaces to load a data from the file
CompressedFileData: .space 10000    # 0.5 MB 
DictionaryData: .space 10000       # 0.5 MB: max number of Bytes in the dictinoray file
file_to_be_decompressed: .space  10000 # 0.5 MB     
decompressed_file: .space 10000     #0.5 MB
enterToBeDecPath: .asciiz "Enter the file to be decompressed: "
decompressed_filename: .asciiz "uncompressed.txt"
code_not_found_msg: .ascii "\"Not Found\"\r\n"
file_decompressed_msg: .ascii "File decompressing done!"
################# Code segment #####################
.text
.globl main		
main: # main program entry

#==========================================

ask_yes_no:
	#ask the user if the dictionary is exist
	la $a0, isDictExist
	li $v0, 4			#print string
	syscall

	#read the string which contain the answer 
	la $a0, answer	# address of input buffer
	li $a1, 16		# maximum number of characters to read
	li $v0, 8		# read string
	syscall
	
	# replace new line with null in the string
	jal replace_newline_with_null
	
	# check if the answer is yes
	la $a1, yes
	la $a0, answer
	jal strings_isEqual
	
	# branch/skip if the answer is not yes
	beqz $v0, check_answer_no
	
	#----------------------------
	# if the dictionary file exist (the answer is yes)
	
Enter_Dict_Path:
	#ask the user to enter the dictionary path
	la $a0, enterDictPath
	li $v0, 4			#print string
	syscall
	
	#read the string which contain the path of the dictionary 
	la $a0, DictionaryFile	# address of input buffer
	li $a1, 256		# maximum number of characters to read
	li $v0, 8		# read string
	syscall
	
	
	jal replace_newline_with_null
	
	# open the dictionary file
	li $v0, 13      # System call 13: Open file
	la $a0, DictionaryFile    # Load the file name into $a0
	li $a1, 0       # Read mode (0 for read, 1 for write)
	li $a2, 0       
	syscall        
	move $s0, $v0
	
	# check if the file is exist
	andi $t1, $v0, 0x80000000
	# branch/skip if there is no error
	beqz $t1, load_dict
	

	# print error message if path invalid
	la $a0, invalidPath
	li $v0, 4			#print string
	syscall
	b Enter_Dict_Path

#---------------------------------------
check_answer_no: 
	# check if the answer is no
	la $a1, no
	la $a0, answer
	jal strings_isEqual
	
	# branch if the answer is no
	bnez $v0, skipError1
	#-----------------------------------
	#if the answer is nither yes nor no
	# print error message
	la $a0, invalidInput
	li $v0, 4			#print string
	syscall
	b ask_yes_no
	
skipError1:
	#-----------------------------------------
	# if the answer is no (the dictionary not exist)
	# open the dictionary file
	li $v0, 13      # System call 13: Open file
	la $a0, DictionaryFile    # Load the file name into $a0
	li $a1, 1       # Read mode (0 for read, 1 for write)
	li $a2, 0       
	syscall
	move $s0, $v0
	
	# make the file empty
	move $a0, $s0 			# File descriptor
	la $a1, DictionaryData 	# address of buffer
	li $a2,	0 			# number of characters to write
	li $v0, 15
	syscall
	#Return number of characters written in $v0
	
	# close the file
	move $a0, $s0
	li $v0, 16
	syscall
	
	j menuLoop
	
#----------------------------------------------	 
# load the Dictionary file 
load_dict: 

	#read the file
	li $v0, 14		# read_file syscall code = 14
	move $a0,$s0		# file descriptor
	la $a1, DictionaryData 	# The buffer that holds the string of the WHOLE file
	la $a2, 10000		# hardcoded buffer length
	syscall
	sb $v0, no_of_chars_inDict	# number of chars in the file
	
	# close the file
	move $a0, $s0
	li $v0, 16
	syscall
	
	# find the number of words in the dictionary
	move $t2, $zero		# initalize counter to zero
find_no_word_inDict:
	lb $t3, ($a1)
	beq $t3, '\0', finish_counting
	addi $t2, $t2, 1
	jal point_next_string_cr
	j find_no_word_inDict
	
finish_counting:
	sb $t2, no_of_words_inDict
	
	
#---------------------------------	
	# print whats in the file
	li $v0, 4		# read_string syscall code = 4
	la $a0,DictionaryData
	syscall

	
#----------------------------------------------
	
#================================
# 	start of menu loop
menuLoop:
	#print the menu
	la $a0, menu
	li $v0, 4
	syscall
	
read_menu_option:
	#read the option
	la $a0, option
	li $a1, 50
	li $v0, 8
	syscall
	
	
	# replace the \n with \0 after reading the option
	jal replace_newline_with_null
	
	#check if the input equal to one of the compresstion key words	
	#check for the first key word
	la $a0, option
	la $a1, compression_keyword
	jal strings_isEqual
	bnez $v0, compression
	
	#check for the second key word
	la $a0, option
	jal point_next_string_null		# make a1 point to the next string of the array
	jal strings_isEqual			# check if the two strings are equal
	bnez $v0, compression
	
	#check for the third key word
	la $a0, option
	jal point_next_string_null		# make a1 point to the next string of the array
	jal strings_isEqual			# check if the two strings are equal
	bnez $v0, compression
	
	j check_option_decompression

#-----------------------------------------------
# compression
compression:

AskUserEnterUncompressedFile:
	#ask the user to enter a file to be compressed
	la $a0,DisplayEnterUncompressedFile
	li $v0,4
	syscall
#-------------------------------------------
	#Read a file name from the user to be compressed
	la $a0,UncompressedFileName
	li $a1,3000
	li $a2,0
	li $v0,8
	syscall
	jal replace_newline_with_null #after read a file name from the user we need to replace the new line to null
#-------------------------------------------
	# Open the file which needs to be compressed
	li $v0, 13      # System call 13: Open file
	la $a0, UncompressedFileName    # Load the file name into $a0
	li $a1, 0       # Read mode (0 for read, 1 for write)
	li $a2, 0       
	syscall        
	move $s0,$v0
	andi $t1, $v0, 0x80000000 # check if the file is exist
	beqz $t1, Read_From_UncompressedFile	# branch/skip if there is no error
	la $a0, invalidPath	# Display error message if path invalid
	li $v0, 4			#print the file name entered by the user
	syscall
	b AskUserEnterUncompressedFile # After the file name is not found, return to prompt the user to enter a new file name

#-----------------------------------------------------
# after the file name is found,then go reads from the file
Read_From_UncompressedFile:
	#read from the file
	li $v0, 14		# read_file syscall code = 14
	move $a0,$s0		# file descriptor
	la $a1,UncompressedFileData  	# The buffer that holds the string of the WHOLE file
	la $a2,3000		# hardcoded buffer length
	syscall
#-------------------------------------------
	#print number of characters in the file to be compressed
	move $s1,$v0
	la $a0,NumCharactersUncompressedFile
	li $v0,4
	syscall	
	la $t0,UncompressedFileData
	jal Count_Number_Of_Characters_In_File
	move $a0,$t1
	li $v0,1
	syscall
	jal PrintNewLine
	#print the uncompressed file size
	mul $t1,$t1,16
	mtc1 $t1, $f0        # Move the value from $t0 to $f0

    cvt.s.w $f1, $f0     # Convert the integer value in $f0 to a float, and store the result in $f1


    mov.s $f12, $f1      # Move the float value from $f1 to $f12


	swc1 $f1,dividend
	la $a0,UncompressedFileSize
	li $v0,4
	syscall
	jal Print_Size_Of_File
	jal PrintNewLine
#-------------------------------------------
	#Close the file
    li $v0, 16         		# close_file syscall code
    move $a0,$s0      		# file descriptor to close
    syscall
#------------------------------------------- 	
	
	#This function creates a dictionary file if the user does not have a dictionary file, and if it does, it will complete it
Create_Dictionary:
	li $s7,10 #
	li $t1,0 #(boolean type) to the special characters(0:means the previous byte is not a specail cahr)
	la $t0,UncompressedFileData # to load a data from the file was entered by user to be compressesd 	
	la $t4,DictionaryData # dict file
	jal GetNumCharactersInDictionary
	move $a0,$t5
	li $v0,1
	syscall
	jal PrintNewLine
	move $t7,$t5 #maximum length of loaded data to store in a the dictionary file
	add $t4,$t4,$t5

	jal AddNewLineInDictionary    #add new line(if there is a characters)
	#addiu $t0,$t0,-1 
	la $t5,str1 # the word needs to check if it is in the file (if it is not in the file ,it will add it )
	
while:	
	#addiu $t0,$t0,1 #read next byte from string which loaded from the file 
	lb $a0,($t0) # load the byte from the file needs to be compressed
	addiu $t0,$t0,1 #read next byte from string which loaded from the file 
	beqz $a0,END #reaches to the end of the file(then go check the last word if was added)
	beq $a0,'\r',while # do nothing
	beq $a0,'\n',AddNLine # it is a sepcial character so needs to check if was added into the dictionary
	jal isSpecialCharacter # checks if the byte which loded if special character
	bnez $t3,CheckExsitSpecial #equals to one(it is special char)
	sb $a0,($t5) #store the character to (str1) that need to search about
	addiu $t1,$zero,0
	addiu $t5,$t5,1
	j while

CheckExsitSpecial:
	lb $t9,($t8) # checks if special in loaded Data(found) 
	beqz $t9,addSpecial #add the special character(not found) first time 
	beq $t9,$a0,foundSpecial # the special is found (so check if needs to a new line or not)
	addi $t8,$t8,1
	j CheckExsitSpecial
	
addSpecial:
	sb $zero,($t5)
	la $t5,str1
	beqz $t1,CheckExistWord
back2:
	sb $a0 ,($t4) # addd the specail char
	addiu $t4,$t4,1
	li $s7,13 # \r
	sb $s7 ,($t4) #add new line to the dic file
	addiu $t4,$t4,1
	li $s7,10	#\n
	sb $s7 ,($t4) #add new line to the dic file
	addiu $t4,$t4,1
	addiu $t7,$t7,3
	lw $s4, no_of_words_inDict
	addi $s4, $s4, 1 # increment the number of words in the dictionary
	sw $s4, no_of_words_inDict # save it back in the memory
	addiu $t1,$zero,1
	j while
	
CheckExistWord:
	la $a1,DictionaryData
	la $t9,str1
	jal strings_isEqual_Sen
	bnez $v0,back2 #The word was exist so go back to add the special character
	la $a1,str1 # The word need to added
	jal AddWord
	li $s7,13 # \r
	sb $s7 ,($t4) #add new line to the dic file
	addiu $t4,$t4,1
	li $s7,10 # \n
	sb $s7 ,($t4) #add new line to the dic file
	addiu $t4,$t4,1
	addi $t7,$t7,2
	lw $s4, no_of_words_inDict
	addi $s4, $s4, 1 # increment the number of words in the dictionary
	sw $s4, no_of_words_inDict # save it back in the memory
	j back2
	
foundSpecial:
	sb $zero,($t5) # add null to the word that needs to be added
	la $t5,str1
	bnez $t1,while # the pre is a special char(do nothing) go back
#check exist the word
	la $a1,DictionaryData
	la $t9,str1
	jal strings_isEqual_Sen
	la $a1,str1
	addiu $t1,$zero,1
	bnez $v0,while
	jal AddWord
	
	li $s7,13
	sb $s7 ,($t4) #add new line to the dic file
	addiu $t4,$t4,1
	li $s7,10
	sb $s7 ,($t4) #add new line to the dic file
	addi $t4,$t4,1
	addi $t7,$t7,2
	lw $s4, no_of_words_inDict
	addi $s4, $s4, 1 # increment the number of words in the dictionary
	sw $s4, no_of_words_inDict # save it back in the memory

	j while
		
AddNLine:
#Add \n to the dictinory file
	sb $zero,($t5) # add null to the word that needs to be added
	la $t5,str1
	bnez $t1,NN # the pre is a special char(so don't need to adds the word)then go check if the new line was added to the loaded data 
	la $a1,DictionaryData
	la $t9,str1
	jal strings_isEqual_Sen
	la $a1,str1
	bnez $v0,NN # the worde is found
	jal AddWord
	
	li $s7, 10 # \n
	sb $s7 ,($t4) #add new line to the dic file
	addi $t4,$t4,1
	addi $t7,$t7,1	
	addi $t1,$zero,0
	lw $s4, no_of_words_inDict
	addi $s4, $s4, 1 # increment the number of words in the dictionary
	sw $s4, no_of_words_inDict # save it back in the memory
NN:
	la $s2,NewLine
	jal StoreWordInStr1s
	la $t9,str1
	la $a1,DictionaryData
	jal strings_isEqual_Sen
	bnez $v0,while # the new line was added(do nothing)
	#add \n
	la $a0,NewLine
	lb $a1,($a0)
	sb $a1,($t4)
	addiu $t4,$t4,1
	addiu $a0,$a0,1
	lb $a1,($a0)	
	sb $a1,($t4)
	addiu $t4,$t4,1
	li $s7,13
	sb $s7 ,($t4) #add new line to the dic file
	addiu $t4,$t4,1
	li $s7, 10
	sb $s7 ,($t4) #add new line to the dic file
	addiu $t4,$t4,1
	addi $t7,$t7,4
	lw $s4, no_of_words_inDict
	addi $s4, $s4, 1 # increment the number of words in the dictionary
	sw $s4, no_of_words_inDict # save it back in the memory
	addi $t1,$zero,1
	la $t5,str1
	j while					

END:
	bnez $t1,DeleteNewLine
	sb $zero,($t5)
	la $a1,DictionaryData
	la $t9,str1
	jal strings_isEqual_Sen 
	bnez $v0,DeleteNewLine
	la $a1,str1
	jal AddWord
	#li $s7,13 # \r
	#sb $s7 ,($t4) #add new line to the dic file
	#addiu $t4,$t4,1
	#li $s7, 10 # \n
	#sb $s7,($t4) #add new line to the dic file
	#addi $t4,$t4,1
	#addi $t7,$t7,2
	lw $s4, no_of_words_inDict
	addi $s4, $s4, 1 # increment the number of words in the dictionary
	sw $s4, no_of_words_inDict # save it back in the memory
D:
	sb $t7,MaxLength

#loads the data into the Dictinoray file

#open the dictionary file 
    li $v0,13           	# open_file syscall code = 13
    la $a0,DictionaryFile     	# get the file name
    li $a1,1           	# file flag = write (1)
    syscall
    move $s1,$v0        	# save the file descriptor. $s0 = file	
#Write into the dictionary file
    li $v0,15		# write_file syscall code = 15
    move $a0,$s1		# file descriptor
    la $a1,DictionaryData		# the string that will be written
    la $a2,1000		# length of the toWrite string
    syscall  	
#Close the dictionry file
    li $v0,16         		# close_file syscall code
    move $a0,$s1      		# file descriptor to close
    syscall
    
    
#========================================================

la $t1,UncompressedFileData
la $t2,str1
li $s5,1
la $t0,CompressedFileData
addi $s6,$zero,0
li $a3,0
Create_Compressed_File:
	lb $a0,($t1)
	addi $t1,$t1,1
	
	beqz $a0,GetIndexOfWordInDictionaryFile #reaches to the end of the file(then go check the last word if was added)
	beq $a0,'\r',Create_Compressed_File # do nothing
	#beq $a0,'\n',index_new_line # it is a sepcial character so needs to check if was added into the dictionary
	jal isSpecialCharacter # checks if the byte which loded if special character
	bnez $t3,GetIndexOfWordInDictionaryFile #equals to one(it is special char)
	
	sb $a0,($t2)
	addi $t2,$t2,1
	addi $s5,$zero,0
	j Create_Compressed_File


GetIndexOfWordInDictionaryFile:
	sb $zero,($t2)
	move $s7,$a0	
	bnez $s5,Index_Special
	la $a1,DictionaryData
	la $t9,str1
	li $t6,0 #index
	jal strings_isEqual_Sen

#print index
	jal MakeStringEmpty
	la $a1,string
	addiu $a1,$a1,5
	move $a0,$t6
	jal int2str
	jal LoadString
	li $a0,10
	sb $a0,($t0)
	addi $a3,$a3,1
	addi $t0,$t0,1
	addiu $s6,$s6,1
	beqz $s7,Finish
Index_Special:	
#get index of special character
	beqz $s7,Finish
	beq $s7,'\n',index_new_line	
	la $t2,str1
	sb $s7,($t2)
	addi $t2,$t2,1
	sb $zero,($t2)
	la $a1,DictionaryData
	la $t9,str1
	li $t6,0 #index
	jal strings_isEqual_Sen
#print index
	jal MakeStringEmpty	
	la $a1,string
	addiu $a1,$a1,5
	move $a0,$t6
	jal int2str	
	jal LoadString
	li $a0,10
	sb $a0,($t0)
	addi $a3,$a3,1
	addi $t0,$t0,1
	addiu $s6,$s6,1	

	la $t2,str1
	addi $s5,$zero,1

	j Create_Compressed_File
	
Finish:

	



	addi $a3,$a3,-1 #dlete new line in output.txt(comprssed)

    # Open the file for writing
    li $v0, 13      # syscall code for opening a file (sys_open)
    la $a0, filename    # address of the filename string
    li $a1, 1       # file flags: 1 = write mode
    li $a2, 0       # file permission: not used for writing
    syscall         # call the system call
	move $s0,$v0  
    # Write hexadecimal value to the file
    li $v0,15		# write_file syscall code = 15
    move $a0,$s0		# file descriptor
    la $a1,CompressedFileData		# the string that will be written
    la $a2,($a3)		# length of the toWrite string
    syscall  	

    # Close the file
    move $a0, $s0   # file handle
    li $v0, 16      # syscall code for closing a file (sys_close)
    syscall         # call the system call

#-----------------------------------------------------------

#*****************************************************************

	la $a0,NumCharactersCompressedFile
	li $v0,4
	syscall	
	move $t1,$s6
	move $a0,$t1
	li $v0,1
	syscall
	jal PrintNewLine
	#print the uncompressed file size
	mul $t1,$t1,16
	mtc1 $t1, $f0        # Move the value from $t0 to $f0

    cvt.s.w $f1, $f0     # Convert the integer value in $f0 to a float, and store the result in $f1


    mov.s $f12, $f1      # Move the float value from $f1 to $f12


	swc1 $f1,divisor
	la $a0,CompressedFileSize
	li $v0,4
	syscall
	jal Print_Size_Of_File
	jal PrintNewLine

#print the ratio
	la $a0,Ratio
	li $v0,4
	syscall

	lwc1 $f0, dividend     # Load dividend into $f0 register
    lwc1 $f1, divisor      # Load divisor into $f1 register

    div.s $f2, $f0, $f1    # Divide $f0 by $f1, store result in $f2
    li $v0, 2              # Set the service number for printing a float (2)
    mov.s $f12, $f2      # Move the float value from $f1 to $f12
    syscall     
    
 	jal PrintNewLine   
	la $a0,Result
	li $v0,4
	syscall

	
	
  # Print the result
    li $v0, 2              # Set the service number for printing a float (2)
    mov.s $f12, $f2      # Move the float value from $f1 to $f12
    syscall                # Perform the syscall to print the float

	la $a0,Time
	li $v0,4
	syscall


#******************************************************************

	j menuLoop


	
	
index_new_line:
	la $s2,NewLine
	jal StoreWordInStr1s	
	la $a1,DictionaryData
	la $t9,str1
	li $t6,0 #index
	jal strings_isEqual_Sen
#print index
	jal MakeStringEmpty
	la $a1,string
	addiu $a1,$a1,5
	move $a0,$t6
	jal int2str	
	jal LoadString
	li $a0,10
	sb $a0,($t0)
	addi $t0,$t0,1
	addi $a3,$a3,1
	addiu $s6,$s6,1	
		
				
	la $t2,str1
	addi $s5,$zero,1
	j Create_Compressed_File
	
#-----------------------------------------------------------
	
	
	j menuLoop

#------------------------------------------------

check_option_decompression:

	#check if the input equal to one of the decompresstion key words
	
	#check for the first key word
	la $a0, option
	la $a1, decompression_keyword
	jal strings_isEqual
	bnez $v0, decompression
	
	#check for the second key word
	la $a0, option
	jal point_next_string_null		# make a1 point to the next string of the array
	jal strings_isEqual			# check if the two strings are equal
	bnez $v0, decompression
	
	#check for the third key word
	la $a0, option
	jal point_next_string_null		# make a1 point to the next string of the array
	jal strings_isEqual			# check if the two strings are equal
	bnez $v0, decompression
	
	j check_option_quit
	
	
#------------------------------------------------------------
# decomposition
decompression:
	#ask the user to enter the dictionary path
	la $a0, enterToBeDecPath
	li $v0, 4			#print string
	syscall
	
	#read the string which contain the path of the to be decompressed file 
	la $a0, filename2	# address of input buffer
	li $a1, 10000		# maximum number of characters to read
	li $v0, 8		# read string
	syscall
	
	
	jal replace_newline_with_null
	
	# open the to be decompressed file
	li $v0, 13      # System call 13: Open file
	la $a0, filename2    # Load the file name into $a0
	li $a1, 0       # Read mode (0 for read, 1 for write)
	li $a2, 0       
	syscall        
	move $s0, $v0
	
	# check if the file is exist
	andi $t1, $v0, 0x80000000
	# branch/skip if there is no error
	beqz $t1, load_to_be_decompressed
	

	# print error message if path invalid
	la $a0, invalidPath
	li $v0, 4			#print string
	syscall
	b decompression
	
load_to_be_decompressed:
	#read the file
	li $v0, 14		# read_file syscall code = 14
	move $a0,$s0		# file descriptor
	la $a1, file_to_be_decompressed 	# The buffer that holds the string of the WHOLE file
	la $a2, 10000		# hardcoded buffer length
	syscall
	
	# close the file
	move $a0, $s0  # File descriptor
	li $v0, 16
	syscall
	
	la $a2, decompressed_file # the address of the decompressed file
	li $s7, 0 		# initialize number of chars in decompressed file to zero
loop_decompress:
	lb $t1, ($a1)
	beq $t1, '\0', end_decompress
	move $v0, $zero
	#addiu $a1, $a1, 2 # skip the "0x"
	jal convert_hexString_to_integer  # convert hex string to integer
	move $s1, $v0					#move the result to $s1
	jal point_next_string_newLine 	# move the pointer to the next element of the array
	
	move $s0, $a1		# save the address of the pointer in $s0
	
	la $t5, no_of_words_inDict
	lw $t5, ($t5)
	bge $s1, $t5, code_not_found	
	la $a1, DictionaryData		# load the address of the dictionary
loop_on_dict:		# loop s1 times to get the index of the code
	beqz $s1, found_code		#  if reached the desired code
	addi $s1, $s1, -1 	
	jal point_next_string_cr	#make the pointer point to the next string in the dictionary
	j loop_on_dict
found_code:
	jal copy_string
	move $a1, $s0
	j loop_decompress
code_not_found:
	la $a1, code_not_found_msg
	jal copy_string
	move $a1, $s0
	j loop_decompress
end_decompress:
	# print done messsage
	la $a0, file_decompressed_msg
	li $v0, 4			#print string
	syscall
	
	# open the decompressed file
	li $v0, 13      # System call 13: Open file
	la $a0, decompressed_filename    # Load the file name into $a0
	li $a1, 1       # Read mode (0 for read, 1 for write)
	li $a2, 0       
	syscall  

	# print the decompressed words in the file
	move $a0, $v0
	li $v0, 15		# write to file
	la $a1, decompressed_file
	move $a2, $s7
	syscall
	
	# close the file
	li $v0, 16
	syscall
	
	
	j menuLoop
#--------------------------------------------------------------
	
check_option_quit:
	
	#check if the input equal to one of the quit key words

	#check for the first key word
	la $a0, option
	la $a1, quit_keyword
	jal strings_isEqual
	bnez $v0, quit
	
	#check for the second key word
	la $a0, option
	jal point_next_string_null		# make a1 point to the next string of the array
	jal strings_isEqual			# check if the two strings are equal
	bnez $v0, quit
	b invalid_option
#----------------------------------------------
# Quit the program
quit:
	li $v0, 10 # Exit program
	syscall
#----------------------------------------------

invalid_option:
	# print error message
	la $a0, invalidInput
	li $v0, 4			#print string
	syscall
	
	j menuLoop
	



#====================================================================
#All Functions
#====================================================================

#===============================================================
# Function strings_isEqual: check if two strings are equal or not with case insensitivity
# Input: $a0, $a1 = address of input buffer for the two strings
# Output: $v0 = (1 if equals, 0 if not)
#---------------------------------------------------------------
strings_isEqual:
    add $t0, $zero, $zero   # initialize counter to 0
loop_si:
    lbu $t1, ($a0)          # load byte from s1
    lbu $t2, ($a1)          # load byte from s2
    beq $t1, $zero, done    # end of s1
    beq $t2, $zero, done    # end of s2
    addiu $t0, $t0, 1       # increment counter
    addi $a0, $a0, 1        # increment pointer for s1
    addi $a1, $a1, 1        # increment pointer for s2
    andi $t1, $t1, 0xDF     # convert t1 to uppercase (ASCII code)
    andi $t2, $t2, 0xDF     # convert t2 to uppercase (ASCII code)
    bne $t1, $t2, not_equal # case-insensitive comparison
    j loop_si
not_equal:
    add $v0, $zero, 0       # set return value to 0
    jr $ra
done:
    beq $t1, $t2, equal     # s1 and s2 have the same length
    add $v0, $zero, 0       # set return value to 0
    jr $ra
equal:
    add $v0, $zero, 1       # set return value to 1
    jr $ra
        
#====================================================================
# function : replace the newline character with null terminator
# input    : $a0 = address of input buffer
# output   : no output
#---------------------------------------------------------------------
replace_newline_with_null:
    # loop through the buffer
loop_rnwn:
    lbu $t0, ($a0)       # load byte at current offset
    beq $t0, '\n', end    # exit loop if newline found
    beq $t0, $zero, end  # exit loop if null terminator is reached
    addi $a0, $a0, 1     # increment buffer address
    j loop_rnwn

    # replace the newline with null terminator
end:
    sb $zero, ($a0)      # replace newline with null terminator
    jr $ra               # return from the function

#======================================================================
# function to make the pointer a1 point to the next string of the array according to \0
# input 	 : $a1: the pointer 
# output : $a1 will point to the next string of the array
#--------------------------------------------------------
point_next_string_null:
	lbu $t0, ($a1)
	addi $a1, $a1, 1
	bne $t0, '\0', point_next_string_null #check if reached the end of the string
	
	# end of stinrg
	jr $ra
	
#======================================================================
# function to make the pointer a1 point to the next string of the array according to \n
# input	 : $a1: the pointer 
# output : $a1 will point to the next string of the array
#--------------------------------------------------------
point_next_string_newLine:
	lbu $t0, ($a1)
	beq $t0, '\0', end_of_array_nl
	addi $a1, $a1, 1
	bne $t0, '\n', point_next_string_newLine #check if reached the end of the string
end_of_array_nl:
	# end of array
	jr $ra
#===============================================================
# Function PrintNewLine: Print a new line in Run I/O
# Input: there is no input
# Output: a newline in Run I/O
#---------------------------------------------------------------
PrintNewLine:
	li $a0,10
	li $v0,11
	syscall
	jr $ra	
	
#=======================================================================
# Function Print_Size_Of_File: Prints the size of the last opened file
# Input: $t1=numbers of charaters in the file
# Output: Print the size of the last opened file in Run I/O
#---------------------------------------------------------------
Print_Size_Of_File:	
	
	mfc1 $a0, $f1 
	li $v0,2	
	syscall
	la $a0,DBytes	    #Displays the string "bytes" end with new line
	li $v0,4
	syscall
	jr $ra
	
#=======================================================================
# Function Count_Number_Of_Characters_In_File: Prints the exact number of characters(without count \n and \r) in the last opened file
# Input: $t0=address of the file buffer
# Output: $t1=The exact number of characters in the file
#---------------------------------------------------------------
Count_Number_Of_Characters_In_File:
loop:	
	lb $a0,($t0)
	addiu $t0,$t0,1
	beq $a0,$zero,BreaksFunction #if null found then the file was end
	#beq $a0,10,loop # if \n is found don't count it and continue
	#beq $a0,13,loop # if \r is found don't count it and continue
	addiu $t1,$t1,1
	j loop
	
#=======================================================================
# Function isSpecialCharacter:checks if the last character is a "special" character or not
# Input: $a0=Contains the character that needs to be checked if it is special or not
# Output: $t3=(1 if found ,0 if not)
#---------------------------------------------------------------
isSpecialCharacter:
	la $a1,SpecialCharacters
	la $t8,DictionaryData
loop2:	
	lb $s0,($a1)
	addi $a1,$a1,1
	beq $s0,$a0,Special
	beqz $s0,NotSpecial
	j loop2
	
NotSpecial:
	addi $t3,$zero,0
	jr $ra
Special:
	addi $t3,$zero,1
	jr $ra
	
	
#===============================================================
# Function strings_isEqual_Sen: check if two strings are equal or not with case sensitivity
# Input: $t9, $a1 = address of input buffer for the two strings
# $t9:contains address of the word that wants to search for in the other words
# $a1:contains address of the DictionaryData that loaded from the dictionay

# Output: $v0 = (1 if equals, 0 if not)
#---------------------------------------------------------------
strings_isEqual_Sen:

loops_si:
    lbu $s1, ($t9)     # load byte from word that wants to search for
    lbu $s2, ($a1)     # load byte from Dictionary Data
    beqz $s2,done_s	   #reaches to the end of the Dictionary data(check if the word is found or not then return the value in $v0)
    beq $s2, 13, ReplaceToNull    # if \r is found replace it to the null then compares
    beq $s2, 10, ReplaceToNull    # if \n is found replace it to the null then compares
CheckEqual:
    addi $t9, $t9, 1        # increment pointer for s1
    addi $a1, $a1, 1        # increment pointer for s2
    bne $s1, $s2, not_equal_s # case-sensitive comparison (if not equal go to the next word in the dictionary file)
    beqz $s1,equal_s			#reaches to the end of the word(that wants to search for)and it is found(return 1 in $v0)
    j loops_si
not_equal_s:
    add $v0, $zero, 0       # set return value to 0
  	la $t9,str1 		#loads the address of the word again to search again in other word in the dictionary file
    addi $t6,$t6,1 
    j point_next_string
done_s:
    beq $s1, $s2, equal_s     # s1 and s2 have the same length
    add $v0, $zero, 0       # set return value to 0
    addi $t6,$zero,0
    jr $ra
equal_s:
    add $v0, $zero, 1       # set return value to 1
    jr $ra
    
ReplaceToNull:	
	move $s2,$zero
	j CheckEqual
	
#======================================================================
# function to make the pointer a1 point to the next string of the array according to \n
# input	 : $a1: the pointer 
# output : $a1 will point to the next string of the array
#--------------------------------------------------------
point_next_string:
	lbu $s0, ($a1)
	beqz $s0,done_s
	addi $a1, $a1, 1
	bne $s0, '\n', point_next_string #check if reached the end of the string
	j loops_si	

#========================================================
# function AddWord to laod the word into the dictionary file(if it is not foind)
# input	 : $a1: the pointer 
# output : adds the word into the dictionary file if it is not found
#--------------------------------------------------------
AddWord: 
	bnez $v0,BreaksFunction #$v0 :has the value of the return from the function strings_isEqual_Sen
l1:
	lb $s0,($a1)
	beqz $s0,BreaksFunction
	sb $s0,($t4)
	addi $a1,$a1,1
	addi $t4,$t4,1
	addiu $t7,$t7,1
	j l1
	
#==============================
GetNumCharactersInDictionary:
#open the dictionary file
	li $v0, 13      # System call 13: Open file
	la $a0, DictionaryFile    # Load the file name into $a0
	li $a1, 0      # Read mode (0 for read, 1 for write)
	li $a2, 0       
	syscall
	move $s1,$v0
#read from the dictionary file
	move $a0,$s1		# file descriptor
	la $a1,DictionaryData 	# The buffer that holds the string of the WHOLE file
	la $a2,10000		# hardcoded buffer length
	li $v0, 14		# read_file syscall code = 14
	syscall
	move $t5,$v0
#Close the dictionry file
    li $v0,16         		# close_file syscall code
    move $a0,$s1      		# file descriptor to close
    syscall
	jr $ra
	
#=================================================
AddNewLineInDictionary:
	beqz $t5,BreaksFunction
	li $t9,13
	sb $t9,($t4)
	addi $t4,$t4,1
	li $t9,10
	sb $t9,($t4)
	addi $t4,$t4,1
	addi $t7,$t7,2
	jr $ra	

#=================================================
#This Function exits any Functions
#Refer to the following instructions after calling the function
BreaksFunction:
	jr $ra	

#================================
# function StoreNewLineInStr1: this function store \n in the str1 to search for in the dictionary file 
# input	 : $a1: no input
# output : stored \n in the str1
#--------------------------------------------------------
StoreWordInStr1s:
	la $t6,str1
A:	
	lb $s3,($s2)
	
	sb $s3,($t6)
	beqz $s3,BreaksFunction
	addi $t6,$t6,1
	addi $s2,$s2,1
	j A

#----------------------------------------------------------
# int2str: Converts an unsigned integer into a string
# Input: $a0 = value, $a1 = buffer address (12 bytes)
# Output: $v0 = address of converted string in buffer
#----------------------------------------------------------
int2str:
	li $s0, 10 # $t0 = divisor = 10

L2: 
	
	divu $a0, $s0 # LO = value/10, HI = value%10

	mflo $a0 # $a0 = value/10
	mfhi $s2 # $t1 = value%10
	addiu $s2, $s2, 48 # convert digit into ASCII

	sb $s2, ($a1) # store character in memory
	addiu $a1, $a1, -1 # point to previous byte
	addi $a3,$a3,1
	bnez $a0, L2 # loop if value is not 0
	jr $ra # return to caller
	
	
	
#-----------------------------------------------------------------

LoadString:
	la $a1,string
FF:
	lb $a0,($a1)
	addi $a1,$a1,1
	beqz $a0,FF
	addi $a1,$a1,-1
	
AA:
	lb $a0,($a1)
	beqz $a0,BreaksFunction	
	sb $a0,($t0)
	addi $t0,$t0,1
	addi $a1,$a1,1
	j AA
	
#======================================================================
# function to make the pointer a1 point to the next string of the array was read from file according to \r 
# input 	 : $a1: the pointer 
# output : $a1 will point to the next string of the array
#--------------------------------------------------------
point_next_string_cr:
	lbu $t0, ($a1)
	beq $t0, '\0', end_of_array
	addi $a1, $a1, 1
	bne $t0, '\r', point_next_string_cr #check if reached the end of the string
	
	addi $a1, $a1, 1
	
end_of_array:
	# end of array
	jr $ra
#=======================================================================
# function to convert string to integer
# input: a1: address of the string
# output: v0: the integer value
#-------------------------------------------
convert_hexString_to_integer:
    lbu $t3, 0($a1)  # load byte
    beqz $t3, end_of_hex   # if end of string, done
    beq $t3, 10, end_of_hex  # if '\n', done
    beq $t3, 13, end_of_hex  # if '\r', done
    subu $t3, $t3, '0' # subtract ASCII '0'
    #bltu $t3, 10, digit # if less than 10, it's a digit
    #subu $t3, $t3, 7  # subtract 7 to convert 'a'-'f' to 10-15
digit:
	mul $v0, $v0, 10
    #sll $v0, $v0, 4  # shift left 4 bits (multiply by 16)
    add $v0, $v0, $t3 # add new digit
    addiu $a1, $a1, 1 # increment pointer
    j convert_hexString_to_integer         # repeat

end_of_hex:
    jr $ra

#================================================================
# Function to copy string from memory location to another memory location
# inputs : a1 : the address of the string to be copied
#		  a2 : the address of the destination memory location
# outputs: the string stored the destination memory location
#----------------------------------------------
copy_string:

	# check if found "\n" string and store \n (new line) instead of "\n" string
	#move $s3, $a0    # save the address in a0
	#move $s4, $a1	# save the address in a1

	lb $t7, 0($a1)
	bne $t7, '\\', copy_loop
	lb $t7, 1($a1)
	bne $t7, 'n', copy_loop
	lb $t7, 2($a1)
	beq $t7, '\r', print_new_line_uncompressed
	beq $t7, '\0', print_new_line_uncompressed
	b copy_loop
print_new_line_uncompressed:
	li $t9, '\n'		
	sb $t9, 0($a2)  	  # add a new line to the destination string
    addiu $s7, $s7, 1 # increment the number of character in decompressed file
    addiu $a2, $a2, 1 # increment destination pointer
	jr $ra
copy_loop:	
    lbu $t9, 0($a1)   # load byte from source
    beq $t9,'\r', end_copy    # if end of string, done
    beq $t9,'\0', end_copy
    sb $t9, 0($a2)    # store byte in destination
    addiu $s7, $s7, 1 # increment the number of character in decompressed file
    addiu $a1, $a1, 1 # increment source pointer
    addiu $a2, $a2, 1 # increment destination pointer
    j copy_loop       # repeat

end_copy:
    jr $ra

#==============================
DeleteNewLine:
	addi $t7,$t7,-2
	j D

#---------------------------------------------------------------
MakeStringEmpty:
	la $a1,string
	li $s5,0
St:
	sb $zero,($a1)
	addi $a1,$a1,1
	addi $s5,$s5,1
	bne $s5,13,St
	jr $ra
#--------------------------------------------------------------
