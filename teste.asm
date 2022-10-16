.include "macros.asm"

main:
	li $s0, 12
	semi_primes($s0, $t6)
	print_str("\n$t6 = ")
	print_int($t6) 
	
	terminate
