.include "macros.asm"

main:
	li $s0, 5
	li $s5, 100
	semi_primes($s5, $t6)
	print_str("\n$t6 = ")
	print_int($t6) 
	
	terminate
