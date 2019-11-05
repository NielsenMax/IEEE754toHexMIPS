.data 
hex: .asciiz "xxxxxxxx" #just to reserve memory
ent: .asciiz "Entre un numero: "
fullnum: .asciiz "El numero en hexa es: 0x"
sign: .asciiz "El signo es: "
expe: .asciiz "El exponente en exceso: 0x"
exp: .asciiz "El exponente: 0x"
mant: .asciiz "La mantisa: 0x"
enter: .asciiz "\n"

.text
main:
#print first
li $v0, 4
la $a0,ent
syscall

#get float in s0 
li $v0, 6
syscall
mfc1 $s0, $f0

#get adr to save chars
la $s1, hex

#float to hexchar and save the bin in s2
move $a0, $s1
move $a1, $s0
jal fullhex
move $s2, $v0


#print full number in hex
li $v0, 4
la $a0,fullnum
syscall
li $v0, 4
la $a0,hex
syscall
li $v0, 4
la $a0,enter
syscall

#print number sign
li $v0, 4
la $a0,sign
syscall
and $t2, $s0, 0x80000000
srl $t2, $t2, 31
li $v0, 1
move $a0,$t2
syscall
li $v0, 4
la $a0,enter
syscall

#print exponent with excess


#get only the exp bits
and $s3, $s0, 0x7F800000
srl $s3, $s3, 23

#convert to hexa and save it to hex
move $a1, $s3
la $a0, hex
jal fullhex

#print it
li $v0, 4
la $a0,expe
syscall
li $v0, 4
la $a0,hex
syscall
li $v0, 4
la $a0,enter
syscall

#print real exponent
#get bits
and $s3, $s0, 0x7F800000
srl $s3, $s3, 23
addi $s3, -127

#convert to hex
move $a1, $s3
la $a0, hex
jal fullhex

#print it
li $v0, 4
la $a0,exp
syscall
li $v0, 4
la $a0,hex
syscall
li $v0, 4
la $a0,enter
syscall

#print mantisa
#get bits
and $s3, $s0, 0x007FFFFF

#convert to hex
move $a1, $s3
la $a0, hex
jal fullhex

#print it
li $v0, 4
la $a0,mant
syscall
li $v0, 4
la $a0,hex
syscall
li $v0, 4
la $a0,enter
syscall

#end all
li $v0, 10
syscall




fullhex:
#a0 address to save string
#a1 number to convert
#v0 chars
li $t1, 0   #iterator
li $t2, 8   #max
li $t3, 0   #number in hex
move $t4, $a1 #number
move $t5, $a0 #string addr
FOR:
    beq $t2,$t1,ENDFOR  #loop 8 times 32/4

    and $t6, $t4, 4026531840    #get last 4 bits
    srl $t6, $t6, 28 #move last 4 bits to right

    bge $t6,10, LETTERS #if hexa letter jump
    addi $t6, 48 #num to charnum
    j endtohex
    LETTERS:
    addi $t6,55 #convert to ascii letters 
    endtohex:

    sb $t6, ($t5) #save current digit
    
    mul $t7, $t1, 4 #save char to register
    sll $t3, $t3, $t7
    add $t3, $t3,$t6

    addi $t5,1 #jump to next char in string
    sll $t4, $t4, 4 #move to next 4bits in number
    addi $t1,1 #iterator+1
    j FOR
ENDFOR:
move $v0, $t3
jr $ra