.include "macros.asm"

main:
	li $s0, 13
	fatorial($s0, $t6)
	print_str("\n$t6 = ")
	print_int($t6) 
	
	terminate
