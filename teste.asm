.include "macros.asm"
.data
	vet: .space 256
.text

main:
	li $s0, 5
	li $s1, 3
	scan_array(vet, $s0)
	has_element(vet, $s0, $s1, $t1) 
	print_str("\n$t1 = ")
	print_int($t1) 
	
	terminate
