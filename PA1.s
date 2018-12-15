

.text
.global main

main:

	#Prompts the user to input a wtring
	ldr x0,=inputForm
	ldr x1, = prompt
	bl printf

	#Gets the user's input
	ldr x0, = inputForm
	ldr x1, =stringInput
	bl scanf
	
	#Anounces that the length will be anounces
	ldr x0, = lengthprompt
	ldr x1, = stringInput
	bl printf

	
	
	# Initailizes counter for counting length of string. Will be counted in register x2
	mov x2, #0

	#Branch to getlengthString
	b getlengthString

#Gets the length of the string using stack
getlengthString:
	
	#store counter on the stack
	sub sp, sp, #16
	str x2, [sp,#0]


	#First character or byte is loaded onto w1
	ldr x0, =charForm
	ldr x5, = stringInput
	ldrb w4, [x5,x2]
	
	#Compares if char is 0. If so code will branch to lengthOutput
	cbz w4,lengthOutput
	
	#pop x2 off stack
	ldr x2, [sp,#0]
	add sp, sp,#16
	
	#increases x1
	add x2, x2, #1

    #branch back to start of function
    b getlengthString

lengthOutput:

	#stores the length of the string to the stack and prints the length
	ldr x3, = checkLength
	str x2, [x3,#0]

	ldr x0, =numForm
	mov x1,x2
	bl printf

	#get lengths the length then divides by two. Stores in X5
	ldr x2, =checkLength
	ldr x5, [x2, #0]
	lsr x5, x5, #1

	#Stores middle
	ldr x2, = middle
	str x5, [x2, #0]

	#Initial index stored at x4
	mov x4, #0

	#Allocate space on stack for solution as it will return through each frame
	sub sp, sp, #16

	#Recursive Call
	bl checkPalindrome

	#Base case has been reached
	#Loads result into x15 and checks if it is true or false
	#If false it branches to notPalindrome and vice versa
	ldr x15, [sp, #0]
	add sp, sp, #16
	cmp x15, #1
	beq isPalindrome

notPalindrome:
	#Notify User
	ldr x0, = inputForm
	ldr x1, = palnotFound
	bl printf
	b kill

isPalindrome:
	#Notify User
	ldr x0, = inputForm
	ldr x1, = palFound
	bl printf
	b kill


checkPalindrome:
	
	#Allcate space for return address, frame pointer, and paramaters
	sub sp, sp, #16
	str x29, [sp,#8] 
	str x30, [sp, #0]
	sub sp, sp, #16
	str x4, [sp, #8]

	#Frame pointer to stack
	add x29, sp, #24

	#Check
	ldr x2, = middle
	ldr x3, [x2,#0]
	cmp x4, x3

	#Brance if equal. base case
	b.eq baseSuccess

	#Left index calculation
	add x6, x4, #0

	#character at left bound
	ldr x2, = stringInput
	ldrb w7, [x2,x6] 

	#right index. length-1-index
	ldr x2, = checkLength
	ldr x3, [x2,#0]
	sub x3,x3,#1
	sub x3,x3,x4

	#right character
	ldr x2, = stringInput
	ldrb w6, [x2, x3]

	#Compares both characters. if they're equal it will branch to stillPalindrome
	cmp w7,w6
	b.eq stillPalindrome

baseFailed:
	mov x15, #0
	str x15, [sp,#0]
	b Done

baseSuccess:
	mov x15, #1
	str x15, [sp,#0]
	b Done


stillPalindrome:
	add x4, x4, #1

	bl checkPalindrome

Done:
	#Return frame pointer, index, return address and outcome and clear
	ldr x15, [sp,#0]
	ldr x4, [sp, #8]
	ldr x30, [sp, #16]
	ldr x29, [sp, #24]
	add sp, sp, #32

	#Place into prev frame
	str x15, [sp, #0]

	#Return prev address
	br x30 

	b kill

#exit program
kill:
	mov x8, #93
	mov x0, #42
	svc #0
	

ret

.section .data


.data
#Formats
inputForm:	.asciz "%s"
numForm:		.asciz "%d"
charForm:		.asciz 	"%c"

# Needed strings and Prompts
prompt:			.asciz "input a string\n"
lengthprompt:	.asciz "The length of the entered string is "
palFound: 			.asciz "\nThe entered string is a palindrome\n"
palnotFound: 			.asciz "\nThe entered string is NOT a palindrome\n"


#Creates new line or enter
flush: .asciz "\n"

#Space for Variables
checkLength: .space 1000
stringInput: .space 100
middle: .space 100


